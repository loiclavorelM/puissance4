import 'dart:convert';
import 'dart:io';

import 'package:mcp_dart/mcp_dart.dart';
import 'package:puissance4_server/src/assistant/mcp/mcp_dev_server.dart';
import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:puissance4_server/src/profile/user_provisioning.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Given the assistant MCP dev server',
    // Le serveur ouvre ses propres sessions (une par requête) : elles ne
    // verraient pas les données d'une transaction de test.
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late McpDevServer server;
      late Uri url;

      Future<String> tokenFor(String username) async {
        final session = sessionBuilder.build();
        final authUser = await AuthServices.instance.authUsers.create(session);
        await User.db.updateWhere(
          session,
          columnValues: (t) => [t.username(username)],
          where: (t) => t.authUserId.equals(authUser.id),
        );
        return (await AuthServices.instance.tokenManager.issueToken(
          session,
          authUserId: authUser.id,
          method: 'email',
        )).token;
      }

      Future<McpClient> connect(String token) async {
        final client = McpClient(
          const Implementation(name: 'test', version: '0'),
        );
        await client.connect(
          StreamableHttpClientTransport(
            url,
            opts: StreamableHttpClientTransportOptions(
              requestInit: {
                'headers': {'Authorization': 'Bearer $token'},
              },
            ),
          ),
        );
        return client;
      }

      Future<HttpClientResponse> post(
        String token,
        Object body, {
        String? sessionId,
      }) async {
        final http = HttpClient();
        final request = await http.postUrl(url);
        request.headers
          ..contentType = ContentType.json
          ..set(HttpHeaders.acceptHeader, 'application/json, text/event-stream')
          ..set(HttpHeaders.authorizationHeader, 'Bearer $token');
        if (sessionId != null) {
          request.headers
            ..set('mcp-session-id', sessionId)
            ..set('mcp-protocol-version', '2025-06-18');
        }
        request.write(jsonEncode(body));
        final response = await request.close();
        http.close();
        return response;
      }

      setUp(() async {
        AuthServices.set(
          tokenManagerBuilders: [
            JwtConfig(
              algorithm: JwtAlgorithm.hmacSha512(
                SecretKey('test-mcp-secret-key'),
              ),
              refreshTokenHashPepper: 'test-pepper',
            ),
          ],
          identityProviderBuilders: [],
          authUsersConfig: const AuthUsersConfig(
            onAfterAuthUserCreated: createUserForAuthUser,
          ),
        );
        server = await McpDevServer.start(Serverpod.instance, port: 0);
        url = Uri.parse('http://127.0.0.1:${server.port}/mcp');
      });

      tearDown(() async {
        await server.close();
        final session = sessionBuilder.build();
        await UserDashboard.db.deleteWhere(
          session,
          where: (t) => t.id.notEquals(null),
        );
        await AuthUser.db.deleteWhere(
          session,
          where: (t) => t.id.notEquals(null),
        );
      });

      test(
        'when the token is valid then the tools act as that player',
        () async {
          final client = await connect(await tokenFor('alice'));
          final added = await client.callTool(
            CallToolRequest(
              name: 'add_widget',
              arguments: {
                'type': 'kpi',
                'title': 'Taux',
                'source': 'games.summary',
              },
            ),
          );
          expect(added.isError, isFalse);
          await client.close();

          final alice = await User.db.findFirstRow(
            sessionBuilder.build(),
            where: (t) => t.username.equals('alice'),
          );
          final dashboard = await UserDashboard.db.findFirstRow(
            sessionBuilder.build(),
            where: (t) => t.userId.equals(alice!.id),
          );
          expect(dashboard?.version, 1);
        },
      );

      test(
        'when the token is missing or forged then the request is refused',
        () async {
          final response = await post('forged', {
            'jsonrpc': '2.0',
            'id': 1,
            'method': 'ping',
          });
          expect(response.statusCode, HttpStatus.unauthorized);
        },
      );

      test(
        'when another player reuses a session then it is forbidden',
        () async {
          final init = await post(await tokenFor('bob'), {
            'jsonrpc': '2.0',
            'id': 1,
            'method': 'initialize',
            'params': {
              'protocolVersion': '2025-06-18',
              'capabilities': {},
              'clientInfo': {'name': 'curl', 'version': '0'},
            },
          });
          final sessionId = init.headers.value('mcp-session-id');
          expect(sessionId, isNotNull);
          await init.drain<void>();

          final stolen = await post(
            await tokenFor('eve'),
            {'jsonrpc': '2.0', 'id': 2, 'method': 'tools/list'},
            sessionId: sessionId,
          );
          expect(stolen.statusCode, HttpStatus.forbidden);
        },
      );
    },
  );
}
