import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:test/test.dart';

void main() {
  group('Given Connect4Rules', () {
    test('when no move is played then rouge plays and nothing is decided', () {
      expect(Connect4Rules.discToPlay([]), Disc.rouge);
      expect(Connect4Rules.outcome([]), isNull);
    });

    test('when rouge stacks four in a column then rouge wins', () {
      expect(
        Connect4Rules.outcome([0, 1, 0, 1, 0, 1, 0]),
        Connect4Outcome.rouge,
      );
    });

    test('when jaune aligns four in a row then jaune wins', () {
      expect(
        Connect4Rules.outcome([6, 0, 6, 1, 5, 2, 6, 3]),
        Connect4Outcome.jaune,
      );
    });

    test('when rouge completes a diagonal then rouge wins', () {
      // Rouge : (0,0) (1,1) (2,2) (3,3).
      expect(
        Connect4Rules.outcome([0, 1, 1, 2, 2, 3, 2, 3, 3, 6, 3]),
        Connect4Outcome.rouge,
      );
    });

    test('when the last move completes an anti-diagonal then it wins', () {
      // Rouge : (3,0) (2,1) (1,2) (0,3) — le dernier coup est en colonne 0.
      expect(
        Connect4Rules.outcome([3, 2, 2, 1, 1, 0, 1, 0, 0, 6, 0]),
        Connect4Outcome.rouge,
      );
    });

    test('when a column is full then it no longer accepts a move', () {
      final moves = [0, 0, 0, 0, 0, 0];
      expect(Connect4Rules.isValidMove(moves, 0), isFalse);
      expect(Connect4Rules.isValidMove(moves, 1), isTrue);
      expect(Connect4Rules.isValidMove(moves, 7), isFalse);
      expect(Connect4Rules.isValidMove(moves, -1), isFalse);
    });

    test('when the board fills up without alignment then it is a draw', () {
      // Partie complète sans aucun alignement (générée puis vérifiée).
      const moves = [
        5, 4, 5, 0, 6, 2, 4, 5, 5, 0, 4, 1, 1, 0, 4, 5, 6, 5, 3, 1, 1, //
        2, 2, 6, 2, 6, 6, 3, 6, 2, 0, 3, 0, 3, 3, 4, 3, 1, 4, 2, 1, 0,
      ];
      expect(moves, hasLength(42));
      for (var i = 1; i < moves.length; i++) {
        expect(
          Connect4Rules.outcome(moves.sublist(0, i)),
          isNull,
          reason: 'after $i moves',
        );
      }
      expect(Connect4Rules.outcome(moves), Connect4Outcome.draw);
    });
    test(
      'when rouge has three in a row then winningMoveFor finds the fourth',
      () {
        const moves = [0, 0, 1, 1, 2];
        expect(Connect4Rules.winningMoveFor(moves, Disc.rouge), 3);
        expect(Connect4Rules.winningMoveFor(moves, Disc.jaune), isNull);
      },
    );

    test(
      'when the game is won then winningCells returns the aligned cells',
      () {
        final cells = Connect4Rules.winningCells([0, 1, 0, 1, 0, 1, 0]);
        expect(cells, unorderedEquals([(0, 0), (0, 1), (0, 2), (0, 3)]));
        expect(Connect4Rules.winningCells([0, 1]), isNull);
      },
    );

    test('when a column is full then validMoves leaves it out', () {
      expect(Connect4Rules.validMoves([0, 0, 0, 0, 0, 0]), [1, 2, 3, 4, 5, 6]);
    });
  });
}
