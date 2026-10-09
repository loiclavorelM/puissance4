import 'dart:convert';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:puissance4_server/src/assistant/assistant_config.dart';
import 'package:puissance4_server/src/assistant/orchestrator/chat_model.dart';
import 'package:puissance4_server/src/assistant/orchestrator/orchestrator.dart';
import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:puissance4_server/src/review/review_config.dart';
import 'package:test/test.dart';

import 'assistant_test_helpers.dart';
import 'test_tools/serverpod_test_tools.dart';

/// LLM scripté : chaque tour renvoie la réponse suivante, et toutes les
/// requêtes sont gardées pour vérifier ce qui serait parti vers Ollama.
class ScriptedModel implements ChatModel {
  ScriptedModel(this.replies);

  final List<ChatMessage Function(List<ChatMessage> sent)> replies;
  final requests = <List<ChatMessage>>[];
  final tools = <List<ToolSpec>>[];

  @override
  Future<ChatResponse> getResponse(
    List<ChatMessage> messages,
    ChatOptions options,
  ) async {
    requests.add(messages);
    tools.add(options.tools);
    if (requests.length > replies.length) throw StateError('no more replies');
    return ChatResponse(
      replies[requests.length - 1](messages),
      const ChatUsage(100, 10),
    );
  }

  /// Tout ce qui est parti vers le « LLM », en un texte.
  String get sentText => jsonEncode([
    for (final request in requests) [for (final m in request) m.toJson()],
  ]);
}

ChatMessage call(String name, Map<String, Object?> args) => ChatMessage(
  ChatRole.assistant,
  '',
  toolCalls: [ToolCall(id: 'call_$name', name: name, arguments: args)],
);

ChatMessage say(String text) => ChatMessage(ChatRole.assistant, text);

void main() {
  withServerpod('Given the assistant endpoint', (sessionBuilder, endpoints) {
    late TestPlayer alice;
    late ScriptedModel model;

    Future<List<AssistantEvent>> chat(
      String text, {
      String? conversationId,
      List<Mention> mentions = const [],
    }) async => [
      await for (final json in endpoints.assistant.chat(
        alice.session,
        conversationId,
        jsonEncode(ChatInput(text: text, mentions: mentions).toJson()),
      ))
        AssistantEvent.fromJson((jsonDecode(json) as Map).cast()),
    ];

    void script(List<ChatMessage Function(List<ChatMessage>)> replies) {
      model = ScriptedModel(replies);
      AssistantConfig.chatModel = (_) => model;
    }

    setUp(() async {
      ReviewConfig.apiKey = (_) => 'test-key';
      AssistantConfig.now = () => DateTime(2026, 10, 9);
      AssistantConfig.maxRequestsPerHour = 30;
      alice = await createTestPlayer(sessionBuilder, 'alice');
      final kevin = await createTestPlayer(sessionBuilder, 'Kevin42');
      await createFinishedPartie(
        sessionBuilder,
        me: alice.player,
        opponent: kevin.player,
        type: EnumType.multi,
        winner: EnumOutcome.rouge,
      );
    });

    test(
      'when asked to add a widget then the tool runs and the dashboard changes',
      () async {
        script([
          (_) => call('add_widget', {
            'type': 'kpi',
            'title': 'Taux de victoire',
            'source': 'games.summary',
          }),
          (_) => say("C'est fait : ton **taux de victoire** est en haut."),
        ]);
        final events = await chat('Ajoute mon taux de victoire');

        expect(events.map((e) => e.toJson()['event']), [
          'started',
          'toolStatus',
          'toolStatus',
          'dashboardChanged',
          'text',
          'done',
        ]);
        expect((events[2] as ToolStatusEvent).state, ToolState.done);
        expect((events[3] as DashboardChangedEvent).version, 1);
        expect((events.last as DoneEvent).inputTokens, 200);

        final dashboard = jsonDecode(
          await endpoints.dashboard.get(alice.session),
        );
        expect(
          (dashboard['widgets'] as List).single['title'],
          'Taux de victoire',
        );

        // Les outils envoyés au LLM sont ceux des contrats, sans identité.
        expect(model.tools.first.map((t) => t.name), contains('add_widget'));
        expect(
          jsonEncode(model.tools.first.map((t) => t.parameters).toList()),
          isNot(contains('userId')),
        );
        // Contexte variable dans le message du joueur, prompt système stable.
        expect(
          model.requests.first.first.content,
          AssistantOrchestrator.systemPrompt,
        );
        expect(model.requests.first[1].content, contains('Friday 2026-10-09'));
      },
    );

    test(
      'when a player is named then the LLM never sees the name, the answer does',
      () async {
        script([
          (_) => call('query_data', {
            'source': 'games.recent',
            'opponent': '[Player:1]',
          }),
          (sent) {
            final result = sent.last.content;
            return say(
              result.contains('[Player:1]')
                  ? 'Oui, tu as battu [Player:1] une fois.'
                  : 'raté',
            );
          },
        ]);
        final events = await chat("Est-ce que j'ai déjà battu kevin 42 ?");

        expect(
          (events.whereType<TextEvent>().single).text,
          'Oui, tu as battu Kevin42 une fois.',
        );
        expect(model.sentText, isNot(contains('Kevin42')));
        expect(model.sentText.toLowerCase(), isNot(contains('kevin 42')));
        expect(model.sentText, isNot(contains('user:'))); // ni les références
        // Ce qui est enregistré est la version avec jetons.
        final stored = await AssistantMessage.db.find(sessionBuilder.build());
        expect(
          stored.map((m) => m.contentJson).join(),
          isNot(contains('Kevin42')),
        );
        expect(stored.map((m) => m.contentJson).join(), contains('[Player:1]'));
      },
    );

    test(
      'when the conversation continues then history and tokens are kept',
      () async {
        script([(_) => say('Bonjour [Me] !')]);
        final first = await chat('Salut, je suis alice');
        final conversationId = (first.first as StartedEvent).conversationId;
        expect(first.whereType<TextEvent>().single.text, 'Bonjour alice !');

        script([(_) => say('Toujours là.')]);
        final second = await chat(
          'Et maintenant ?',
          conversationId: conversationId,
        );
        expect((second.first as StartedEvent).conversationId, conversationId);
        // system + 2 messages du 1er échange + nouvelle question
        expect(model.requests.single, hasLength(4));
        expect(model.requests.single[1].content, contains('je suis [Me]'));
      },
    );

    test('when proposing a widget then a block reaches the app', () async {
      script([
        (_) => call('propose_widget', {
          'type': 'chart',
          'title': 'Où je joue',
          'source': 'moves.byCell',
        }),
        (_) => say('Voici la carte.'),
      ]);
      final events = await chat('Montre où je joue');
      final block = events.whereType<BlockEvent>().single.definition;
      expect(block.chart!.mark, ChartMark.heatmap);
      expect(events.whereType<DashboardChangedEvent>(), isEmpty);
    });

    test(
      'when a tool fails then the error goes back to the LLM, which can fix it',
      () async {
        script([
          (_) => call('add_widget', {
            'type': 'chart',
            'title': 'X',
            'source': 'results.byOpponent',
            'mark': 'line',
          }),
          (sent) {
            expect(sent.last.content, contains('use a bar chart'));
            return call('add_widget', {
              'type': 'chart',
              'title': 'X',
              'source': 'results.byOpponent',
            });
          },
          (_) => say('Corrigé.'),
        ]);
        final events = await chat('Courbe par adversaire');
        expect(
          events.whereType<ToolStatusEvent>().map((e) => e.state),
          [
            ToolState.started,
            ToolState.failed,
            ToolState.started,
            ToolState.done,
          ],
        );
      },
    );

    test(
      'when the model loops then it stops after the maximum of turns',
      () async {
        script(
          List.filled(
            AssistantConfig.maxTurns,
            (_) => call('get_dashboard', {}),
          ),
        );
        final events = await chat('Boucle');
        expect(
          (events.last as ErrorEvent).code,
          AssistantErrorCode.tooManySteps,
        );
        final log = await AssistantRequestLog.db.findFirstRow(
          sessionBuilder.build(),
        );
        expect(log?.errorCode, 'tooManySteps');
        expect(log?.turns, AssistantConfig.maxTurns);
      },
    );

    test(
      'when there is no API key or too many requests then a code comes back',
      () async {
        ReviewConfig.apiKey = (_) => null;
        expect((await chat('Salut')).single.toJson(), {
          'event': 'error',
          'code': 'notConfigured',
        });

        ReviewConfig.apiKey = (_) => 'test-key';
        AssistantConfig.maxRequestsPerHour = 1;
        script([(_) => say('ok')]);
        await chat('Une');
        expect((await chat('Deux')).single.toJson(), {
          'event': 'error',
          'code': 'rateLimited',
        });
      },
    );

    test(
      "when continuing someone else's conversation then it is refused",
      () async {
        script([(_) => say('ok')]);
        final id = ((await chat('Salut')).first as StartedEvent).conversationId;
        final bob = await createTestPlayer(sessionBuilder, 'bob');
        final events = [
          await for (final json in endpoints.assistant.chat(
            bob.session,
            id,
            jsonEncode(const ChatInput(text: 'Coucou').toJson()),
          ))
            jsonDecode(json),
        ];
        expect(events.single, {'event': 'error', 'code': 'invalidInput'});
      },
    );
  });
}
