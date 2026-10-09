import 'dart:convert';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:mcp_dart/mcp_dart.dart' as mcp;
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../assistant_config.dart';
import '../mcp/assistant_mcp.dart';
import '../privacy/exposure_policy.dart';
import '../privacy/privacy_filter.dart';
import '../privacy/token_map.dart';
import 'chat_model.dart';

/// La boucle de l'assistant : le LLM décide, le backend exécute.
///
/// 1. La question est pseudonymisée, puis envoyée avec le prompt système,
///    l'historique (déjà pseudonymisé) et les outils MCP.
/// 2. Le LLM répond par du texte ou par des appels d'outils.
/// 3. Chaque appel passe par le client MCP **en mémoire**, lié au joueur :
///    arguments rétablis, résultat protégé, renvoyé au LLM ; et ainsi de
///    suite, [AssistantConfig.maxTurns] fois au plus.
/// 4. Pendant ce temps, des événements partent vers l'app : statut des
///    outils, tableau de bord modifié, blocs, texte avec les vraies valeurs.
///
/// Tout ce qui est enregistré (messages, journal) est la version avec
/// jetons, celle qu'a vue le LLM.
final class AssistantOrchestrator {
  AssistantOrchestrator(this.session, this.user);

  final Session session;
  final User user;

  Stream<AssistantEvent> chat(String? conversationId, ChatInput input) async* {
    final watch = Stopwatch()..start();
    final tools = <String>[];
    var usage = ChatUsage.zero;
    var turns = 0;
    AssistantErrorCode? failure;
    AssistantConversation? conversation;

    if (!input.isValid) {
      yield const ErrorEvent(AssistantErrorCode.invalidInput);
      return;
    }
    final apiKey = AssistantConfig.apiKey(session);
    if (apiKey == null || apiKey.isEmpty) {
      yield const ErrorEvent(AssistantErrorCode.notConfigured);
      return;
    }
    if (await _recentRequests() >= AssistantConfig.maxRequestsPerHour) {
      yield const ErrorEvent(AssistantErrorCode.rateLimited);
      return;
    }
    conversation = await _conversation(conversationId);
    if (conversation == null) {
      yield const ErrorEvent(AssistantErrorCode.invalidInput);
      return;
    }
    yield StartedEvent(conversation.id!.uuid);

    final policy = ExposurePolicy.standard;
    final tokens = await TokenMap.load(session, conversation.id!);
    final privacy = PrivacyFilter(
      policy: policy,
      index: await NameDirectory.index(session, policy),
      tokens: tokens,
      selfRef: 'user:${user.id}',
      selfName: user.username,
      labels: await NameDirectory.labels(session, [
        for (final token in tokens.tokens) ?tokens.refOf(token),
      ]),
    );

    final history = await _history(conversation.id!);
    final question = ChatMessage.user(
      '${_context(input.language)}\n\n${privacy.pseudonymizeInput(input)}',
    );
    final fresh = <ChatMessage>[question];
    final model = AssistantConfig.chatModel(apiKey);
    final modelId = AssistantConfig.model(session);

    // Outils MCP liés au joueur ; la session de l'endpoint sert à chaque appel.
    final client = await connectInMemory(
      buildAssistantMcpServer(user, <R>(work) => work(session)),
    );
    try {
      final toolSpecs = [
        for (final tool in (await client.listTools()).tools)
          ToolSpec(
            tool.name,
            tool.description ?? '',
            tool.inputSchema.toJson(),
          ),
      ];

      for (turns = 1; turns <= AssistantConfig.maxTurns; turns++) {
        final ChatResponse response;
        try {
          response = await model.getResponse(
            privacy.guardEgress([
              ChatMessage.system(AssistantContracts.systemPrompt),
              ...history,
              ...fresh,
            ]),
            ChatOptions(model: modelId, tools: toolSpecs),
          );
        } on Object catch (error) {
          session.log(
            'Assistant model call failed: $error',
            level: LogLevel.warning,
          );
          failure = AssistantErrorCode.unavailable;
          yield ErrorEvent(failure);
          return;
        }
        usage += response.usage;
        final reply = privacy.guardEgress([response.message]).single;
        fresh.add(reply);

        if (reply.toolCalls.isEmpty) {
          yield TextEvent(privacy.restoreText(reply.content));
          yield DoneEvent(
            inputTokens: usage.inputTokens,
            outputTokens: usage.outputTokens,
          );
          return;
        }

        for (final call in reply.toolCalls) {
          yield ToolStatusEvent(call.name, ToolState.started);
          final result = await client.callTool(
            mcp.CallToolRequest(
              name: call.name,
              arguments: privacy.restoreArguments(call.arguments),
            ),
          );
          final text = result.content
              .whereType<mcp.TextContent>()
              .map((c) => c.text)
              .join();
          final protected = privacy.protectResult(_decodeObject(text));
          fresh.add(
            ChatMessage.toolResult(call.id, call.name, jsonEncode(protected)),
          );
          tools.add('${call.name}:${result.isError ? 'failed' : 'done'}');
          yield ToolStatusEvent(
            call.name,
            result.isError ? ToolState.failed : ToolState.done,
          );

          if (result.meta?[dashboardVersionMeta] case final int version) {
            yield DashboardChangedEvent(version);
          }
          if (result.meta?[blockMeta] case final Map<dynamic, dynamic> block) {
            yield BlockEvent(WidgetDefinition.fromJson(block.cast()));
          }
        }
      }
      turns = AssistantConfig.maxTurns;
      failure = AssistantErrorCode.tooManySteps;
      yield ErrorEvent(failure);
    } finally {
      await client.close();
      await _save(conversation.id!, fresh);
      await tokens.save(session);
      await _log(conversation.id, usage, tools, turns, watch, failure);
    }
  }

  /// Contexte variable, dans le message du joueur et pas dans le prompt
  /// système : celui-ci reste stable (cache de prompt chez les fournisseurs).
  static String _context(String language) {
    final now = AssistantConfig.now();
    final day = now.toIso8601String().substring(0, 10);
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '[Context] Today is ${weekdays[now.weekday - 1]} $day. '
        'Answer in ${language == 'en' ? 'English' : 'French'}. '
        'The player is [Me].';
  }

  static Json _decodeObject(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) return decoded.cast();
    } on FormatException {
      // Erreur de validation de mcp_dart : texte brut.
    }
    return {'error': text};
  }

  Future<int> _recentRequests() => AssistantRequestLog.db.count(
    session,
    where: (t) =>
        t.userId.equals(user.id) &
        (t.createdAt >
            DateTime.now().toUtc().subtract(const Duration(hours: 1))),
  );

  /// La conversation [id] du joueur, ou une nouvelle ; `null` si [id]
  /// n'est pas à lui.
  Future<AssistantConversation?> _conversation(String? id) async {
    if (id == null) {
      return AssistantConversation.db.insertRow(
        session,
        AssistantConversation(userId: user.id!),
      );
    }
    final UuidValue uuid;
    try {
      uuid = UuidValue.withValidation(id);
    } on FormatException {
      return null;
    }
    return AssistantConversation.db.findFirstRow(
      session,
      where: (t) => t.id.equals(uuid) & t.userId.equals(user.id),
    );
  }

  Future<List<ChatMessage>> _history(UuidValue conversationId) async {
    final rows = await AssistantMessage.db.find(
      session,
      where: (t) => t.conversationId.equals(conversationId),
      orderBy: (t) => t.position,
    );
    final messages = [
      for (final row in rows)
        ChatMessage.fromJson((jsonDecode(row.contentJson) as Map).cast()),
    ];
    // Les plus récents, en commençant par une question (jamais par un
    // résultat d'outil orphelin).
    var start = messages.length - AssistantConfig.historyMessages;
    if (start <= 0) return messages;
    while (start < messages.length && messages[start].role != ChatRole.user) {
      start++;
    }
    return messages.sublist(start);
  }

  Future<void> _save(
    UuidValue conversationId,
    List<ChatMessage> messages,
  ) async {
    final last = await AssistantMessage.db.findFirstRow(
      session,
      where: (t) => t.conversationId.equals(conversationId),
      orderBy: (t) => t.position.desc(),
    );
    var position = (last?.position ?? -1) + 1;
    await AssistantMessage.db.insert(session, [
      for (final message in messages)
        AssistantMessage(
          conversationId: conversationId,
          position: position++,
          contentJson: jsonEncode(message.toJson()),
        ),
    ]);
    await AssistantConversation.db.updateWhere(
      session,
      columnValues: (t) => [t.updatedAt(DateTime.now().toUtc())],
      where: (t) => t.id.equals(conversationId),
    );
  }

  Future<void> _log(
    UuidValue? conversationId,
    ChatUsage usage,
    List<String> tools,
    int turns,
    Stopwatch watch,
    AssistantErrorCode? failure,
  ) async {
    // Journal sans texte : modèle, tokens, outils, durée, erreur.
    await AssistantRequestLog.db.insertRow(
      session,
      AssistantRequestLog(
        userId: user.id!,
        conversationId: conversationId,
        model: AssistantConfig.model(session),
        inputTokens: usage.inputTokens,
        outputTokens: usage.outputTokens,
        toolsJson: jsonEncode(tools),
        turns: turns,
        durationMs: watch.elapsedMilliseconds,
        errorCode: failure?.name,
      ),
    );
  }
}
