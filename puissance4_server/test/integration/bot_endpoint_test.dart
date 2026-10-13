import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given the bot endpoint (Normal mode on the web)', (
    sessionBuilder,
    endpoints,
  ) {
    final signedIn = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        '11111111-1111-4111-8111-111111111111',
        {},
      ),
    );

    test(
      'when the bot is asked to play, then it returns a legal column',
      () async {
        final moves = [3, 3, 2];
        final column = await endpoints.bot.chooseColumn(
          signedIn,
          BotLevel.moyen.id,
          moves,
        );
        expect(Connect4Rules.isValidMove(moves, column), isTrue);
      },
    );

    test('when the bot can block a win, then it blocks it', () async {
      final column = await endpoints.bot.chooseColumn(
        signedIn,
        BotLevel.moyen.id,
        [0, 6, 1, 6, 2],
      );
      expect(column, 3);
    });

    test('when a column overflows, then the move is refused', () async {
      await expectLater(
        endpoints.bot.chooseColumn(signedIn, BotLevel.moyen.id, [
          0, 0, 0, 0, 0, 0, 0, //
        ]),
        throwsA(
          isA<GameException>().having(
            (e) => e.reason,
            'reason',
            EnumGameError.invalidMove,
          ),
        ),
      );
    });

    test('when the game is already won, then the move is refused', () async {
      await expectLater(
        endpoints.bot.chooseColumn(signedIn, BotLevel.moyen.id, [
          0, 6, 1, 6, 2, 6, 3, 5, //
        ]),
        throwsA(
          isA<GameException>().having(
            (e) => e.reason,
            'reason',
            EnumGameError.gameOver,
          ),
        ),
      );
    });

    test('when the bot id is unknown, then it is refused', () async {
      await expectLater(
        endpoints.bot.chooseColumn(signedIn, 'nope', const []),
        throwsA(isA<GameException>()),
      );
    });

    test('when not signed in, then it is refused', () async {
      await expectLater(
        endpoints.bot.chooseColumn(sessionBuilder, BotLevel.moyen.id, const []),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });
}
