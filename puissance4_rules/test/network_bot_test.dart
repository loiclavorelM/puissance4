import 'dart:math';

import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:test/test.dart';

/// Faux réseau : toujours la même politique (colonnes pleines à 0), valeur
/// nulle.
NetworkEvaluator fixedPolicy(List<double> policy) => (board) {
  final top = board.sublist(0, Connect4Rules.columns);
  return (
    policy: [for (var c = 0; c < 7; c++) top[c] == 0 ? policy[c] : 0.0],
    value: 0.0,
  );
};

void main() {
  const prefersSix = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0];

  group('Given encodeBoard', () {
    test('when discs are played then rows start at the top, seen by the '
        'player to move', () {
      // Rouge en 3, Jaune en 3 au-dessus : Rouge au trait.
      final board = encodeBoard([3, 3]);
      expect(board[5 * 7 + 3], 1); // rangée du bas : jeton de Rouge
      expect(board[4 * 7 + 3], -1);
      expect(board.where((v) => v != 0), hasLength(2));
      // Jaune au trait : les signes s'inversent.
      expect(encodeBoard([3])[5 * 7 + 3], -1);
    });
  });

  group('Given a NetworkBot', () {
    test('when the level is guarded then it wins before following the '
        'network', () {
      final bot = NetworkBot(BotLevel.moyen, fixedPolicy(prefersSix));
      expect(bot.chooseColumn([0, 0, 1, 1, 2, 5]), 3);
    });

    test('when the level is guarded then it blocks', () {
      final bot = NetworkBot(BotLevel.moyen, fixedPolicy(prefersSix));
      expect(bot.chooseColumn([0, 5, 1, 5, 2]), 3);
    });

    test('when the network prefers a losing column then a guarded level '
        'plays the best safe one', () {
      final bot = NetworkBot(
        BotLevel.moyen,
        fixedPolicy([0.0, 0.0, 0.0, 0.0, 1.0, 0.5, 0.0]),
      );
      expect(bot.chooseColumn([3, 1, 3, 5, 5, 6, 6]), 5);
    });

    test('when the level is not guarded then it can miss a win', () {
      // Facile : température 1, tire selon la politique — ici toujours 6.
      final bot = NetworkBot(
        BotLevel.facile,
        fixedPolicy(prefersSix),
        random: Random(1),
      );
      expect(bot.chooseColumn([0, 0, 1, 1, 2, 5]), 6);
    });

    test('when the best column is full then it is skipped', () {
      final bot = NetworkBot(BotLevel.moyen, fixedPolicy(prefersSix));
      expect(bot.chooseColumn([6, 6, 6, 6, 6, 6]), isNot(6));
    });

    test('when the level searches then the network is called once per '
        'simulation', () {
      var calls = 0;
      final policy = fixedPolicy(List.filled(7, 1 / 7));
      final bot = NetworkBot(BotLevel.difficile, (board) {
        calls++;
        return policy(board);
      });
      final column = bot.chooseColumn([]);
      expect(Connect4Rules.validMoves([]), contains(column));
      // Racine + au plus une feuille par simulation.
      expect(calls, lessThanOrEqualTo(BotLevel.difficile.simulations + 1));
    });
  });

  group('Given an Mcts', () {
    test('when the thinking time is up then it stops early', () {
      final visits = Mcts((board) {
        // Faux réseau lent : 1 ms par évaluation.
        final clock = Stopwatch()..start();
        while (clock.elapsedMicroseconds < 1000) {}
        return fixedPolicy(List.filled(7, 1 / 7))(board);
      }).visitCounts([], 10000, maxDuration: const Duration(milliseconds: 50));
      final total = visits.fold<double>(0, (a, b) => a + b);
      expect(total, greaterThan(0));
      expect(total, lessThan(200));
    });

    test('when a move wins at once then the search finds it even against '
        'the network', () {
      // Le réseau conseille la colonne 6 ; la recherche voit la victoire en 3.
      final visits = Mcts(
        fixedPolicy(prefersSix.map((p) => p == 0 ? 0.05 : p).toList()),
      ).visitCounts([0, 0, 1, 1, 2, 5], 200);
      final best = visits.indexOf(visits.reduce(max));
      expect(best, 3);
    });

    test('when the opponent threatens to win then the search blocks', () {
      final visits = Mcts(
        fixedPolicy(List.filled(7, 1 / 7)),
      ).visitCounts([0, 5, 1, 5, 2], 400);
      expect(visits.indexOf(visits.reduce(max)), 3);
    });

    test('when it searches then the root visits add up to the simulations', () {
      final visits = Mcts(
        fixedPolicy(List.filled(7, 1 / 7)),
      ).visitCounts([], 50);
      expect(visits.fold<double>(0, (a, b) => a + b), 50);
    });
  });

  test('every BotLevel has a unique id and model', () {
    expect(BotLevel.values.map((b) => b.id).toSet(), hasLength(5));
    expect(BotLevel.values.map((b) => b.model).toSet(), hasLength(5));
    expect(BotLevel.byId(BotLevel.expert.id), BotLevel.expert);
  });
}
