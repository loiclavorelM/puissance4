import 'dart:async';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:mcp_dart/mcp_dart.dart';
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../tools/assistant_tools.dart';
import '../tools/tool_context.dart';

/// Comment un outil obtient sa session : celle de l'endpoint qui porte la
/// conversation (orchestrateur), ou une session neuve par appel (serveur
/// HTTP de développement).
typedef SessionRunner = Future<R> Function<R>(Future<R> Function(Session) work);

/// Méta-données ajoutées au résultat MCP pour l'orchestrateur (ignorées par
/// les autres clients).
const dashboardVersionMeta = 'puissance4/dashboardVersion';
const blockMeta = 'puissance4/block';

/// Serveur MCP **lié à [user]** : aucun outil n'a de paramètre d'identité,
/// et les schémas exposés sont ceux des contrats, tels quels.
McpServer buildAssistantMcpServer(User user, SessionRunner withSession) {
  final server = McpServer(
    const Implementation(name: 'puissance4', version: '0.1.0'),
  );
  for (final tool in AssistantContracts.tools) {
    server.registerTool(
      tool.name,
      title: tool.title,
      description: tool.description,
      inputSchema: JsonSchema.fromJson(tool.inputSchema) as ToolInputSchema,
      annotations: ToolAnnotations(
        readOnlyHint: tool.annotations['readOnlyHint']!,
        destructiveHint: tool.annotations['destructiveHint']!,
        idempotentHint: tool.annotations['idempotentHint']!,
        openWorldHint: tool.annotations['openWorldHint']!,
      ),
      callback: (args, extra) => withSession((session) async {
        final outcome = await AssistantTools.call(
          ToolContext(session, user),
          tool.name,
          args,
        );
        return CallToolResult(
          content: [TextContent(text: outcome.text)],
          isError: outcome.isError,
          meta: {
            dashboardVersionMeta: ?outcome.dashboardVersion,
            if (outcome.block case final block?) blockMeta: block.toJson(),
          },
        );
      }),
    );
  }
  return server;
}

/// Client MCP relié en mémoire à [server] : le protocole MCP de bout en
/// bout, sans réseau ni port (utilisé par l'orchestrateur).
Future<McpClient> connectInMemory(McpServer server) async {
  final toServer = StreamController<List<int>>();
  final toClient = StreamController<List<int>>();
  await server.connect(
    IOStreamTransport(stream: toServer.stream, sink: toClient.sink),
  );
  final client = McpClient(
    const Implementation(name: 'puissance4-orchestrator', version: '0.1.0'),
  );
  await client.connect(
    IOStreamTransport(stream: toClient.stream, sink: toServer.sink),
  );
  return client;
}
