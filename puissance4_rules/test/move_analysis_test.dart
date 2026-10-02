import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:test/test.dart';

void main() {
  group('Given a MoveAnalysis', () {
    test('when a winning move was missed then the Expert recommends it', () {
      // Rouge (coup d'indice 6) pouvait gagner en 3, a joué en 5.
      final analysis = MoveAnalysis.of([0, 0, 1, 1, 2, 6, 5], 6);
      expect(analysis.played, 5);
      expect(analysis.recommended, 3);
      expect(analysis.isBest, isFalse);
      expect(analysis.recommendedVerdict, MoveVerdict.forcedWin);
    });

    test('when a threat was not blocked then the played move loses', () {
      // Jaune (coup d'indice 5) devait bloquer en 3, a joué en 6.
      final analysis = MoveAnalysis.of([0, 6, 1, 6, 2, 6], 5);
      expect(analysis.recommended, 3);
      expect(analysis.playedVerdict, MoveVerdict.forcedLoss);
      expect(MoveAnalysis.playerOf(5), Disc.jaune);
    });

    test('when the best move was played then it is marked as best', () {
      final analysis = MoveAnalysis.of([0, 0, 1, 1, 2, 6, 3], 6);
      expect(analysis.isBest, isTrue);
    });

    test('when analysed twice then the recommendation is the same', () {
      const moves = [3, 3, 2, 4];
      expect(
        MoveAnalysis.of(moves, 0).recommended,
        MoveAnalysis.of(moves, 0).recommended,
      );
    });
  });
}
