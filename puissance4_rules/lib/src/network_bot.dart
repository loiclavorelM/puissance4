import 'dart:math';
import 'dart:typed_data';

import 'connect4_rules.dart';
import 'bot_level.dart';
import 'tactical_guard.dart';

/// Sortie du réseau pour une position, du point de vue du joueur au trait :
/// une probabilité par colonne (0 pour une colonne pleine) et une valeur
/// dans [-1, 1].
typedef NetworkOutput = ({List<double> policy, double value});

/// Le réseau, quelle que soit la façon de l'exécuter (TFLite dans l'app,
/// faux réseau dans les tests). Synchrone : la recherche appelle le réseau
/// des centaines de fois par coup, depuis un isolate de calcul.
typedef NetworkEvaluator = NetworkOutput Function(Float32List board);

/// Entrée du modèle exporté par le notebook (section 9) : le plateau 6×7,
/// rangée 0 en haut, 1 = jeton du joueur au trait, -1 = adversaire, 0 = vide.
Float32List encodeBoard(List<int> moves) {
  final board = Float32List(Connect4Rules.rows * Connect4Rules.columns);
  final me = Connect4Rules.discToPlay(moves);
  final stacks = Connect4Rules.stacks(moves);
  for (var c = 0; c < Connect4Rules.columns; c++) {
    for (var h = 0; h < stacks[c].length; h++) {
      final row = Connect4Rules.rows - 1 - h;
      board[row * Connect4Rules.columns + c] = stacks[c][h] == me ? 1 : -1;
    }
  }
  return board;
}

/// Choix du coup d'un niveau [BotLevel] à partir de son réseau, comme
/// `choose_move` du notebook.
class NetworkBot {
  NetworkBot(this.level, this.evaluate, {this.maxThinkingTime, Random? random})
    : _random = random ?? Random();

  final BotLevel level;
  final NetworkEvaluator evaluate;

  /// Arrête la recherche plus tôt que `level.simulations` si elle dure plus
  /// longtemps — pour le web, où le réseau tourne en JavaScript sur le
  /// thread de l'interface. `null` : toutes les simulations.
  final Duration? maxThinkingTime;
  final Random _random;

  int chooseColumn(List<int> moves) {
    final valid = Connect4Rules.validMoves(moves);
    if (valid.isEmpty) {
      throw StateError('No move left: the board is full.');
    }
    if (level.guarded) {
      final forced = TacticalGuard.forcedMove(moves);
      if (forced != null) return forced;
    }
    final scores = level.simulations > 0
        ? Mcts(evaluate).visitCounts(
            moves,
            level.simulations,
            maxDuration: maxThinkingTime,
          )
        : evaluate(encodeBoard(moves)).policy;
    final candidates = level.guarded ? TacticalGuard.safeMoves(moves) : valid;
    return _pick(candidates, scores);
  }

  int _pick(List<int> candidates, List<double> scores) {
    if (level.temperature == 0) {
      var best = candidates.first;
      for (final column in candidates.skip(1)) {
        if (scores[column] > scores[best]) best = column;
      }
      return best;
    }
    final weights = [
      for (final c in candidates) pow(scores[c], 1 / level.temperature),
    ];
    final total = weights.fold<num>(0, (a, b) => a + b);
    if (total <= 0) return candidates[_random.nextInt(candidates.length)];
    var pick = _random.nextDouble() * total;
    for (var i = 0; i < candidates.length; i++) {
      pick -= weights[i];
      if (pick < 0) return candidates[i];
    }
    return candidates.last;
  }
}

/// Recherche arborescente Monte-Carlo guidée par le réseau (PUCT, à la
/// AlphaZero) — portage de `run_mcts` du notebook, sans bruit de Dirichlet
/// (réservé à l'entraînement).
class Mcts {
  Mcts(this.evaluate);

  final NetworkEvaluator evaluate;

  /// Poids de l'exploration (prior du réseau) face à la valeur mesurée.
  static const cPuct = 1.5;

  /// Visites de chaque colonne après [simulations] simulations depuis
  /// [moves] (moins si [maxDuration] est atteinte avant) : la colonne la
  /// plus visitée est le meilleur coup.
  List<double> visitCounts(
    List<int> moves,
    int simulations, {
    Duration? maxDuration,
  }) {
    final clock = Stopwatch()..start();
    final root = _Node(List.of(moves));
    _expand(root);
    for (var i = 0; i < simulations; i++) {
      if (maxDuration != null && clock.elapsed >= maxDuration) break;
      final path = <(_Node, int)>[];
      var node = root;
      while (node.expanded && node.terminalValue == null) {
        final column = node.select();
        path.add((node, column));
        node = node.child(column);
      }
      final value = node.terminalValue ?? _expand(node);
      _backpropagate(path, value);
    }
    return [for (final n in root.visits) n.toDouble()];
  }

  /// Évalue [node] avec le réseau et renvoie sa valeur (joueur au trait).
  double _expand(_Node node) {
    final output = evaluate(encodeBoard(node.moves));
    var total = 0.0;
    for (var c = 0; c < Connect4Rules.columns; c++) {
      final p = node.valid[c] ? output.policy[c] : 0.0;
      node.priors[c] = p;
      total += p;
    }
    for (var c = 0; c < Connect4Rules.columns; c++) {
      node.priors[c] = total > 0
          ? node.priors[c] / total
          : (node.valid[c] ? 1.0 : 0.0);
    }
    node.expanded = true;
    return output.value;
  }

  /// [value] est vue par le joueur au trait de la feuille : elle change de
  /// signe à chaque coup en remontant.
  void _backpropagate(List<(_Node, int)> path, double value) {
    var v = value;
    for (final (node, column) in path.reversed) {
      v = -v;
      node.visits[column]++;
      node.totalValue[column] += v;
    }
  }
}

class _Node {
  _Node(this.moves, {this.terminalValue})
    : valid = [
        for (var c = 0; c < Connect4Rules.columns; c++)
          Connect4Rules.isValidMove(moves, c),
      ];

  final List<int> moves;
  final List<bool> valid;

  /// Valeur d'une position finale pour le joueur au trait : -1 (le coup
  /// précédent a gagné) ou 0 (nulle) ; `null` si la partie continue.
  final double? terminalValue;

  final priors = List<double>.filled(Connect4Rules.columns, 0);
  final visits = List<int>.filled(Connect4Rules.columns, 0);
  final totalValue = List<double>.filled(Connect4Rules.columns, 0);
  final _children = <int, _Node>{};
  bool expanded = false;

  int select() {
    final sqrtTotal = sqrt(visits.fold<int>(0, (a, b) => a + b));
    var best = -1;
    var bestScore = double.negativeInfinity;
    for (var c = 0; c < Connect4Rules.columns; c++) {
      if (!valid[c]) continue;
      final n = visits[c];
      final q = n == 0 ? 0.0 : totalValue[c] / n;
      final score = q + Mcts.cPuct * priors[c] * sqrtTotal / (1 + n);
      if (score > bestScore) {
        bestScore = score;
        best = c;
      }
    }
    return best;
  }

  _Node child(int column) => _children.putIfAbsent(column, () {
    final next = [...moves, column];
    final outcome = Connect4Rules.outcome(next);
    return _Node(
      next,
      terminalValue: switch (outcome) {
        null => null,
        Connect4Outcome.draw => 0,
        _ => -1,
      },
    );
  });
}
