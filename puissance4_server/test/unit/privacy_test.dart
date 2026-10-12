import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:puissance4_server/src/assistant/orchestrator/chat_model.dart';
import 'package:puissance4_server/src/assistant/privacy/exposure_policy.dart';
import 'package:puissance4_server/src/assistant/privacy/name_index.dart';
import 'package:puissance4_server/src/assistant/privacy/privacy_filter.dart';
import 'package:puissance4_server/src/assistant/privacy/token_map.dart';
import 'package:test/test.dart';

void main() {
  const kevin = 'user:00000000-0000-7000-8000-00000000000k';
  const lina = 'user:00000000-0000-7000-8000-00000000000l';
  const me = 'user:00000000-0000-7000-8000-0000000000me';
  final policy = ExposurePolicy.standard;

  NameIndex index() => NameIndex(
    {'Kevin42': kevin, 'Léa_Ninja': lina, 'Max': 'user:max', 'alice': me},
    minLength: policy.minLength,
    commonWords: policy.commonWords,
  );

  PrivacyFilter filter() => PrivacyFilter(
    policy: policy,
    index: index(),
    tokens: TokenMap.memory(),
    selfRef: me,
    selfName: 'alice',
  );

  group('Given the name index', () {
    test('then typed variants of a name are found, as whole words', () {
      final found = index().find(
        "J'ai battu kevin 42 et KEVIN42, pas kevin420.",
      );
      expect(found.map((m) => m.ref), [kevin, kevin]);
    });

    test('then accents and case do not matter', () {
      expect(index().find('contre lea_ninja hier').single.ref, lina);
    });

    test('then short or common names are left to mentions', () {
      expect(index().find('le max de parties'), isEmpty);
    });
  });

  group('Given the privacy filter', () {
    test('when a question names a player then the LLM only sees a token', () {
      final privacy = filter();
      expect(
        privacy.pseudonymizeInput(
          const ChatInput(
            text: "Est-ce que j'ai déjà battu kevin 42 ce mois-ci ?",
          ),
        ),
        "Est-ce que j'ai déjà battu [Player:1] ce mois-ci ?",
      );
    });

    test(
      'when a mention is chosen then its token is used even for an odd spelling',
      () {
        final privacy = filter();
        final text = privacy.pseudonymizeInput(
          const ChatInput(
            text: 'Compare-moi à Max',
            mentions: [Mention(ref: 'user:max', label: 'Max')],
          ),
        );
        expect(text, 'Compare-moi à [Player:1]');
      },
    );

    test(
      'when restoring arguments then a lone token becomes the reference',
      () {
        final privacy = filter();
        privacy.pseudonymizeText('Kevin42');
        expect(
          privacy.restoreArguments({
            'opponent': '[Player:1]',
            'title': 'Contre [Player:1]',
            'nested': {'who': '[Me]'},
          }),
          {
            'opponent': kevin,
            'title': 'Contre Kevin42',
            'nested': {'who': me},
          },
        );
      },
    );

    test(
      'when protecting rows then refs are hidden and humans tokenized, bots kept',
      () {
        final privacy = filter();
        final protected = privacy.protectResult({
          'kind': 'rows',
          'fields': [
            {'name': 'opponent', 'type': 'category'},
            {'name': 'opponentKind', 'type': 'category'},
            {'name': 'count', 'type': 'number'},
            {'name': 'opponentRef', 'type': 'category'},
          ],
          'rows': [
            ['Kevin42', 'human', 3, kevin],
            ['Expert', 'bot', 2, 'bot:x'],
            ['Inconnu-1234', 'human', 1, 'user:other'],
          ],
        });
        expect(protected['fields'], hasLength(3));
        expect(protected['rows'], [
          ['[Player:1]', 'human', 3],
          ['Expert', 'bot', 2],
          ['[Player:2]', 'human', 1],
        ]);
        // La réponse affichée retrouve les vrais noms, même hors dictionnaire.
        expect(
          privacy.restoreText('Tu bats souvent [Player:2], moins [Player:1].'),
          'Tu bats souvent Inconnu-1234, moins Kevin42.',
        );
      },
    );

    test(
      'when the player is named then it becomes [Me] and comes back as their name',
      () {
        final privacy = filter();
        expect(privacy.pseudonymizeText('Bravo alice !'), 'Bravo [Me] !');
        expect(privacy.restoreText('Bravo [Me] !'), 'Bravo alice !');
      },
    );

    test(
      'when formats appear then friend codes get a token and room codes are hidden',
      () {
        final privacy = filter();
        expect(
          privacy.pseudonymizeText('Mon code P4-ABC234, salle K7XQ2M, MAISON'),
          'Mon code [FriendCode:1], salle [RoomCode], MAISON',
        );
      },
    );

    test(
      'when sending then the last check catches names anywhere, even in tool arguments',
      () {
        final privacy = filter();
        final guarded = privacy.guardEgress([
          const ChatMessage.system('Kevin42 stays in the stable system prompt'),
          const ChatMessage(
            ChatRole.assistant,
            'Je regarde Kevin42',
            toolCalls: [
              ToolCall(
                id: '1',
                name: 'query_data',
                arguments: {'opponent': 'Kevin42'},
              ),
            ],
          ),
        ]);
        expect(guarded.last.content, 'Je regarde [Player:1]');
        expect(guarded.last.toolCalls.single.arguments, {
          'opponent': '[Player:1]',
        });
        // Le prompt système est constant et ne contient pas de données.
        expect(guarded.first.content, startsWith('Kevin42'));
      },
    );
  });
}
