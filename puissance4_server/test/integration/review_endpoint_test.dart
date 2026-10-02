import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:puissance4_server/src/review/review_config.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// LLM factice : compte les appels, renvoie le prompt reçu.
class _FakeLlm implements LlmClient {
  int calls = 0;
  String? lastUser;
  Object? error;

  @override
  Future<String> chat({
    required String apiKey,
    required String model,
    required String system,
    required String user,
    required Duration timeout,
  }) async {
    calls++;
    lastUser = user;
    if (error != null) throw error!;
    return 'Explication n°$calls';
  }
}

void main() {
  withServerpod('Given Review endpoint', (sessionBuilder, endpoints) {
    late _FakeLlm llm;
    final defaultLlm = ReviewConfig.llm;
    final defaultApiKey = ReviewConfig.apiKey;
    final defaultLimit = ReviewConfig.maxGenerationsPerHour;

    setUp(() {
      llm = _FakeLlm();
      ReviewConfig.llm = llm;
      ReviewConfig.apiKey = (_) => 'test-key';
    });

    tearDown(() {
      ReviewConfig.llm = defaultLlm;
      ReviewConfig.apiKey = defaultApiKey;
      ReviewConfig.maxGenerationsPerHour = defaultLimit;
    });

    Future<TestSessionBuilder> signedIn() async {
      final authUser = await const AuthUsers().create(sessionBuilder.build());
      return sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUser.id.uuid,
          {},
        ),
      );
    }

    // Rouge pouvait gagner en colonne 4 (indice 3), a joué en 6 (indice 5).
    const missedWin = [0, 0, 1, 1, 2, 6, 5];

    test(
      'when explaining a move then the prompt carries the engine facts',
      () async {
        final alice = await signedIn();

        final text = await endpoints.review.explainMove(
          alice,
          moves: missedWin,
          moveIndex: 6,
          language: 'fr',
        );

        expect(text, 'Explication n°1');
        expect(llm.lastUser, contains('Played: column 6'));
        expect(llm.lastUser, contains('Engine recommendation: column 4'));
        expect(llm.lastUser, contains('could win immediately in column 4'));
      },
    );

    test(
      'when the same position is asked again then Ollama is not called',
      () async {
        final alice = await signedIn();
        final bob = await signedIn();

        final first = await endpoints.review.explainMove(
          alice,
          moves: missedWin,
          moveIndex: 6,
          language: 'fr',
        );
        // Même position via une autre partie (coups suivants différents).
        final second = await endpoints.review.explainMove(
          bob,
          moves: [...missedWin, 3],
          moveIndex: 6,
          language: 'fr',
        );

        expect(second, first);
        expect(llm.calls, 1);

        await endpoints.review.explainMove(
          alice,
          moves: missedWin,
          moveIndex: 6,
          language: 'en',
        );
        expect(llm.calls, 2);
      },
    );

    test('when the moves are invalid then it is refused', () async {
      final alice = await signedIn();

      for (final (moves, index) in [
        (missedWin, 7),
        (missedWin, -1),
        ([0, 0, 0, 0, 0, 0, 0], 6), // colonne pleine
        ([0, 1, 0, 1, 0, 1, 0, 1], 7), // après la victoire de Rouge
        ([9], 0),
      ]) {
        await expectLater(
          endpoints.review.explainMove(
            alice,
            moves: moves,
            moveIndex: index,
            language: 'fr',
          ),
          throwsA(
            isA<ReviewException>().having(
              (e) => e.reason,
              'reason',
              EnumReviewError.invalidMove,
            ),
          ),
        );
      }
      expect(llm.calls, 0);
    });

    test(
      'when no API key is configured then it reports notConfigured',
      () async {
        ReviewConfig.apiKey = (_) => null;
        final alice = await signedIn();

        await expectLater(
          endpoints.review.explainMove(
            alice,
            moves: missedWin,
            moveIndex: 6,
            language: 'fr',
          ),
          throwsA(
            isA<ReviewException>().having(
              (e) => e.reason,
              'reason',
              EnumReviewError.notConfigured,
            ),
          ),
        );
      },
    );

    test(
      'when Ollama fails then it reports unavailable and caches nothing',
      () async {
        llm.error = Exception('timeout');
        final alice = await signedIn();

        await expectLater(
          endpoints.review.explainMove(
            alice,
            moves: missedWin,
            moveIndex: 6,
            language: 'fr',
          ),
          throwsA(
            isA<ReviewException>().having(
              (e) => e.reason,
              'reason',
              EnumReviewError.unavailable,
            ),
          ),
        );
        expect(
          await MoveExplanation.db.count(sessionBuilder.build()),
          0,
        );
      },
    );

    test('when a player exceeds the hourly limit then it is refused', () async {
      ReviewConfig.maxGenerationsPerHour = 2;
      final alice = await signedIn();

      await endpoints.review.explainMove(
        alice,
        moves: missedWin,
        moveIndex: 0,
        language: 'fr',
      );
      await endpoints.review.explainMove(
        alice,
        moves: missedWin,
        moveIndex: 1,
        language: 'fr',
      );
      await expectLater(
        endpoints.review.explainMove(
          alice,
          moves: missedWin,
          moveIndex: 2,
          language: 'fr',
        ),
        throwsA(
          isA<ReviewException>().having(
            (e) => e.reason,
            'reason',
            EnumReviewError.rateLimited,
          ),
        ),
      );
      // Une position déjà expliquée reste lisible.
      expect(
        await endpoints.review.explainMove(
          alice,
          moves: missedWin,
          moveIndex: 0,
          language: 'fr',
        ),
        'Explication n°1',
      );
    });

    test('when not signed in then it is refused', () async {
      await expectLater(
        endpoints.review.explainMove(
          sessionBuilder,
          moves: missedWin,
          moveIndex: 6,
          language: 'fr',
        ),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });
}
