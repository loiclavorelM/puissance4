import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:test/test.dart';

void main() {
  group('Given a TacticalGuard', () {
    test('when the player to move can win then that move is forced', () {
      // Rouge (au trait) a 0,1,2 en bas.
      expect(TacticalGuard.forcedMove([0, 0, 1, 1, 2, 5]), 3);
    });

    test('when the opponent threatens to win then the block is forced', () {
      // Jaune au trait, Rouge menace en colonne 3.
      expect(TacticalGuard.forcedMove([0, 5, 1, 5, 2]), 3);
    });

    test('when it can both win and block then winning comes first', () {
      // Rouge au trait : 0,1,2 en bas pour lui, trois Jaunes en colonne 6.
      const moves = [0, 6, 1, 6, 2, 6];
      expect(Connect4Rules.winningMoveFor(moves, Disc.jaune), 6);
      expect(TacticalGuard.forcedMove(moves), 3);
    });

    test('when a column offers the opponent a win then it is not safe', () {
      // Jaune au trait ; jouer en colonne 4 laisserait Rouge gagner juste
      // au-dessus.
      const moves = [3, 1, 3, 5, 5, 6, 6];
      expect(TacticalGuard.forcedMove(moves), isNull);
      expect(TacticalGuard.safeMoves(moves), [0, 1, 2, 3, 5, 6]);
    });

    test('when nothing is threatened then every column is safe', () {
      expect(TacticalGuard.forcedMove([]), isNull);
      expect(TacticalGuard.safeMoves([]), Connect4Rules.validMoves([]));
    });
  });
}
