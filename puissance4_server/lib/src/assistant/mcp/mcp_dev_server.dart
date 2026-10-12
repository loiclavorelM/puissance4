import 'dart:convert';
import 'dart:io';

import 'package:mcp_dart/mcp_dart.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../../generated/protocol.dart';
import 'assistant_mcp.dart';

/// Serveur MCP HTTP **de développement**, pour tester les outils sans LLM
/// depuis Claude Code ou MCP Inspector. Démarré par `server.dart` en mode
/// `development` seulement, sur 127.0.0.1.
///
/// Chaque requête est authentifiée par un jeton Serverpod (`Authorization:
/// Bearer …`, validé comme pour un endpoint) puis servie par un `McpServer`
/// lié à ce joueur. Deux chemins, vérifiés au lot 0 :
/// - MCP 2025-11-25 (`initialize`) : une session, liée au joueur qui l'a
///   ouverte — une session présentée avec le jeton d'un autre joueur est
///   refusée (403) ;
/// - MCP 2026-07-28 : sans état, un serveur pour la seule requête.
///
/// `StreamableMcpServer` ne convient pas : il ne transmet pas l'identité
/// authentifiée jusqu'aux outils.
final class McpDevServer {
  McpDevServer._(this._http);

  static const defaultPort = 8095;

  final HttpServer _http;
  final _sessions =
      <String, ({StreamableHTTPServerTransport transport, UuidValue userId})>{};

  static Future<McpDevServer> start(
    Serverpod pod, {
    int port = defaultPort,
  }) async {
    final http = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    final server = McpDevServer._(http);
    http.listen((request) => server._handle(pod, request));
    return server;
  }

  int get port => _http.port;

  Future<void> close() => _http.close(force: true);

  Future<void> _handle(Serverpod pod, HttpRequest request) async {
    try {
      if (request.uri.path != '/mcp') {
        return await _reply(request, HttpStatus.notFound);
      }
      final user = await pod.withSession(
        (session) => authenticateMcpRequest(session, request),
      );
      if (user == null) return await _reply(request, HttpStatus.unauthorized);

      final sessionId = request.headers.value('mcp-session-id');
      if (sessionId != null) {
        final session = _sessions[sessionId];
        if (session == null) return await _reply(request, HttpStatus.notFound);
        if (session.userId != user.id) {
          return await _reply(request, HttpStatus.forbidden);
        }
        return await session.transport.handleRequest(request);
      }

      final Object? body = request.method == 'POST'
          ? jsonDecode(await utf8.decodeStream(request))
          : null;
      final server = buildAssistantMcpServer(
        user,
        <R>(work) => pod.withSession(work),
      );

      if (body is Map && body['method'] == 'initialize') {
        late final StreamableHTTPServerTransport transport;
        transport = StreamableHTTPServerTransport(
          options: _options(
            sessionIdGenerator: generateUUID,
            onsessioninitialized: (sid) =>
                _sessions[sid] = (transport: transport, userId: user.id!),
          ),
        );
        await server.connect(transport);
        // connect() remplace transport.onclose : on nettoie via le serveur.
        final previous = server.server.onclose;
        server.server.onclose = () {
          previous?.call();
          _sessions.removeWhere((_, s) => identical(s.transport, transport));
        };
        return await transport.handleRequest(request, body);
      }

      final transport = StreamableHTTPServerTransport(
        options: _options(
          sessionIdGenerator: () => null,
          enableJsonResponse: true,
        ),
      );
      await server.connect(transport);
      try {
        await transport.handleRequest(request, body);
      } finally {
        await server.close();
      }
    } on FormatException {
      return await _reply(request, HttpStatus.badRequest);
    }
  }

  static StreamableHTTPServerTransportOptions _options({
    required String? Function() sessionIdGenerator,
    void Function(String sessionId)? onsessioninitialized,
    bool enableJsonResponse = false,
  }) => StreamableHTTPServerTransportOptions(
    sessionIdGenerator: sessionIdGenerator,
    onsessioninitialized: onsessioninitialized,
    enableJsonResponse: enableJsonResponse,
    enableDnsRebindingProtection: true,
    allowedHosts: const {'127.0.0.1', 'localhost'},
  );

  static Future<void> _reply(HttpRequest request, int status) async {
    request.response.statusCode = status;
    await request.response.close();
  }
}

/// Le joueur dont le jeton Serverpod accompagne [request], validé par le
/// même chemin que les endpoints ; `null` si absent ou invalide.
Future<User?> authenticateMcpRequest(
  Session session,
  HttpRequest request,
) async {
  final header = request.headers.value(HttpHeaders.authorizationHeader);
  if (header == null || !header.startsWith('Bearer ')) return null;
  final info = await AuthServices.instance.authenticationHandler(
    session,
    header.substring('Bearer '.length).trim(),
  );
  if (info == null) return null;
  return User.db.findFirstRow(
    session,
    where: (t) =>
        t.authUserId.equals(UuidValue.withValidation(info.userIdentifier)),
  );
}
