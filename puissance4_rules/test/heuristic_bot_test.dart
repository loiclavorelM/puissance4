import 'dart:math';

import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:test/test.dart';

void main() {
  group('Given a HeuristicBot', () {
    HeuristicBot bot(BotStrength strength) =>
        HeuristicBot(strength, random: Random(42));

    test('when its elo is known then its strength follows the thresholds', () {
      expect(BotStrength.fromElo(800), BotStrength.beginner);
      expect(BotStrength.fromElo(1200), BotStrength.medium);
      expect(BotStrength.fromElo(1600), BotStrength.expert);
    });

    for (final strength in [BotStrength.medium, BotStrength.expert]) {
      test('when it can win at once then the $strength bot wins', () {
        // Rouge (au trait) a 0,1,2 en bas.
        expect(bot(strength).chooseColumn([0, 0, 1, 1, 2, 6]), 3);
      });

      test(
        'when the opponent threatens to win then the $strength bot blocks',
        () {
          // Jaune au trait, Rouge menace en colonne 3.
          expect(bot(strength).chooseColumn([0, 6, 1, 6, 2]), 3);
        },
      );
    }

    test('when the medium bot has a choice then it never offers a win', () {
      // Rouge au trait ; jouer en colonne 1 laisserait Jaune gagner en
      // diagonale au-dessus.
      const moves = [3, 2, 4, 2, 2, 1, 6, 1];
      for (var seed = 0; seed < 20; seed++) {
        final column = HeuristicBot(
          BotStrength.medium,
          random: Random(seed),
        ).chooseColumn(moves);
        expect(
          Connect4Rules.winningMoveFor([...moves, column], Disc.jaune),
          isNull,
          reason: 'seed $seed played $column',
        );
      }
    });

    test('when bots play a whole game then every move is valid', () {
      final players = [bot(BotStrength.expert), bot(BotStrength.beginner)];
      final moves = <int>[];
      while (Connect4Rules.outcome(moves) == null) {
        final column = players[moves.length % 2].chooseColumn(moves);
        expect(Connect4Rules.isValidMove(moves, column), isTrue);
        moves.add(column);
      }
    });

    test('when expert plays beginner then expert wins most games', () {
      var expertWins = 0;
      for (var seed = 0; seed < 10; seed++) {
        final expert = HeuristicBot(BotStrength.expert, random: Random(seed));
        final beginner = HeuristicBot(
          BotStrength.beginner,
          random: Random(seed + 100),
        );
        final moves = <int>[];
        Connect4Outcome? outcome;
        while ((outcome = Connect4Rules.outcome(moves)) == null) {
          final player = moves.length.isEven ? expert : beginner;
          moves.add(player.chooseColumn(moves));
        }
        if (outcome == Connect4Outcome.rouge) expertWins++;
      }
      expect(expertWins, greaterThanOrEqualTo(9));
    });
  });
}
