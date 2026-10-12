@Tags(['eval'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:puissance4_server/src/assistant/assistant_config.dart';
import 'package:puissance4_server/src/assistant/orchestrator/chat_model.dart';
import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:puissance4_server/src/review/review_config.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../integration/assistant_test_helpers.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

/// Rejoue `contracts/evals/requests.yaml` sur le vrai modèle Ollama : appels
/// d'outils attendus (arguments comparés partiellement), aucune valeur
/// sensible dans ce qui part vers le LLM, tokens et durée par demande.
///
///   dart test -t eval --run-skipped
///   ASSISTANT_EVAL_MODEL=qwen3-coder:480b dart test -t eval --run-skipped
///
/// Clé : `ollamaApiKey` de la section `development` de config/passwords.yaml.
void main() {
  const opponent = 'Kevin42';
  final cases = (loadYaml(AssistantContracts.evalsYaml) as YamlList)
      .cast<YamlMap>();
  final report = <String>[];

  withServerpod('Assistant evals', (sessionBuilder, endpoints) {
    late TestPlayer me;
    late _RecordingModel model;
    late ChatModel Function(String) realModel;

    setUpAll(() {
      final passwords =
          loadYaml(File('config/passwords.yaml').readAsStringSync()) as YamlMap;
      final key =
          (passwords['development'] as YamlMap)['ollamaApiKey'] as String;
      final modelId = Platform.environment['ASSISTANT_EVAL_MODEL'];
      ReviewConfig.apiKey = (_) => key;
      if (modelId != null) AssistantConfig.model = (_) => modelId;
      realModel = AssistantConfig.chatModel;
      AssistantConfig.maxRequestsPerHour = 1000;
    });

    setUp(() async {
      me = await createTestPlayer(sessionBuilder, 'alice');
      final kevin = await createTestPlayer(sessionBuilder, opponent);
      final bot = await Bot.db.insertRow(
        sessionBuilder.build(),
        Bot(botName: 'Expert', elo: 1500, pathModel: '', description: ''),
      );
      final botPlayer = await Player.db.insertRow(
        sessionBuilder.build(),
        Player(botId: bot.id),
      );
      for (final (opp, winner) in [
        (kevin.player, EnumOutcome.rouge),
        (kevin.player, EnumOutcome.jaune),
        (botPlayer, EnumOutcome.jaune),
        (botPlayer, EnumOutcome.rouge),
      ]) {
        await createFinishedPartie(
          sessionBuilder,
          me: me.player,
          opponent: opp,
          type: opp == botPlayer ? EnumType.classe : EnumType.multi,
          winner: winner,
        );
      }
      model = _RecordingModel(
        realModel(ReviewConfig.apiKey(sessionBuilder.build())!),
      );
      AssistantConfig.chatModel = (_) => model;
    });

    tearDownAll(() {
      stdout.writeln(
        '\n| demande | outils appelés | ok | tokens in/out | durée |',
      );
      stdout.writeln('|---|---|---|---|---|');
      report.forEach(stdout.writeln);
    });

    for (final evalCase in cases) {
      final request = (evalCase['request'] as String).replaceAll(
        '{opponent}',
        opponent,
      );
      test(request, () async {
        final watch = Stopwatch()..start();
        final events = [
          await for (final json in endpoints.assistant.chat(
            me.session,
            null,
            jsonEncode(
              ChatInput(
                text: request,
                // Langue de l'app (« en » pour une demande en anglais).
                language: evalCase['language'] as String? ?? 'fr',
              ).toJson(),
            ),
          ))
            AssistantEvent.fromJson((jsonDecode(json) as Map).cast()),
        ];
        final calls = [for (final r in model.responses) ...r.message.toolCalls];
        final done = events.whereType<DoneEvent>().firstOrNull;
        final expected = [
          for (final e in (evalCase['expect'] as YamlList? ?? YamlList()))
            e as YamlMap,
        ];
        final ok = _matches(calls, expected);
        report.add(
          '| $request | ${calls.map((c) => '${c.name}(${jsonEncode(c.arguments)})').join('<br>')} '
          '| ${ok ? '✓' : '✗'} | ${done?.inputTokens ?? '-'}/${done?.outputTokens ?? '-'} '
          '| ${watch.elapsedMilliseconds} ms |',
        );

        final forbidden = [
          for (final value
              in (evalCase['llm_input_must_not_contain'] as YamlList? ??
                  YamlList()))
            (value as String).replaceAll('{opponent}', opponent),
        ];
        for (final value in forbidden) {
          expect(
            model.sentText.toLowerCase(),
            isNot(contains(value.toLowerCase())),
            reason: 'leaked $value',
          );
        }
        if (evalCase['answer_must_match'] case final String pattern) {
          final answer = events
              .whereType<TextEvent>()
              .map((e) => e.text)
              .join();
          expect(
            answer,
            matches(RegExp(pattern, caseSensitive: false)),
            reason: 'answer: $answer',
          );
        }
        expect(events.whereType<ErrorEvent>(), isEmpty);
        expect(
          ok,
          isTrue,
          reason:
              'calls: ${calls.map((c) => '${c.name} ${c.arguments}').join(', ')}',
        );
      });
    }
  });
}

/// Les appels attendus apparaissent dans l'ordre (d'autres peuvent
/// s'intercaler, comme list_data_sources), arguments comparés partiellement.
bool _matches(List<ToolCall> calls, List<YamlMap> expected) {
  var i = 0;
  for (final call in calls) {
    if (i == expected.length) break;
    final want = expected[i];
    if (call.name != want['tool']) continue;
    final args = (want['args'] as YamlMap?) ?? YamlMap();
    // Une liste attendue (columns) doit être contenue, dans n'importe quel
    // ordre ; le reste est comparé tel quel.
    final fits = args.entries.every(
      (e) => switch ((e.value, call.arguments[e.key])) {
        (final YamlList want, final List<Object?> got) => want.every(
          (item) => got.map((g) => '$g').contains('$item'),
        ),
        (final want, final got) => '$got' == '$want',
      },
    );
    if (fits) i++;
  }
  return i == expected.length;
}

class _RecordingModel implements ChatModel {
  _RecordingModel(this._inner);

  final ChatModel _inner;
  final requests = <List<ChatMessage>>[];
  final responses = <ChatResponse>[];

  String get sentText => jsonEncode([
    for (final request in requests) [for (final m in request) m.toJson()],
  ]);

  @override
  Future<ChatResponse> getResponse(
    List<ChatMessage> messages,
    ChatOptions options,
  ) async {
    requests.add(messages);
    final response = await _inner.getResponse(messages, options);
    responses.add(response);
    return response;
  }
}
