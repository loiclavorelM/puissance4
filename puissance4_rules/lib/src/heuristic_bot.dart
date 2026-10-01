import 'dart:math';

import 'connect4_rules.dart';

/// Niveau de jeu d'un bot.
enum BotStrength {
  beginner,
  medium,
  expert;

  /// Niveau d'un bot d'après son Elo virtuel (`botSeeds` du serveur : 800 /
  /// 1200 / 1600) — mêmes seuils que le choix du bot en Classé.
  static BotStrength fromElo(int elo) => elo < 1000
      ? BotStrength.beginner
      : elo < 1400
      ? BotStrength.medium
      : BotStrength.expert;
}

/// IA de remplacement en attendant les modèles RL (E5) : même interface
/// d'usage (une position → une colonne), utilisée par le téléphone (Normal)
/// comme par le serveur (Classé).
///
/// - Débutant : joue au hasard, voit une victoire immédiate une fois sur deux.
/// - Medium : gagne, bloque, évite d'offrir la victoire, préfère le centre.
/// - Expert : recherche négamax à profondeur 5 avec élagage alpha-bêta.
class HeuristicBot {
  HeuristicBot(this.strength, {Random? random}) : _random = random ?? Random();

  final BotStrength strength;
  final Random _random;

  static const _expertDepth = 5;
  static const _win = 1000000;

  /// Colonnes du centre vers les bords : meilleur ordre d'exploration.
  static const _centerFirst = [3, 2, 4, 1, 5, 0, 6];

  int chooseColumn(List<int> moves) {
    final valid = Connect4Rules.validMoves(moves);
    if (valid.isEmpty) {
      throw StateError('No move left: the board is full.');
    }
    final me = Connect4Rules.discToPlay(moves);

    switch (strength) {
      case BotStrength.beginner:
        final win = Connect4Rules.winningMoveFor(moves, me);
        if (win != null && _random.nextBool()) return win;
        return valid[_random.nextInt(valid.length)];
      case BotStrength.medium:
        final forced =
            Connect4Rules.winningMoveFor(moves, me) ??
            Connect4Rules.winningMoveFor(moves, me.other);
        if (forced != null) return forced;
        final safe = valid
            .where((c) => !_givesWin(moves, c, me.other))
            .toList();
        return _centerWeighted(safe.isEmpty ? valid : safe);
      case BotStrength.expert:
        final forced =
            Connect4Rules.winningMoveFor(moves, me) ??
            Connect4Rules.winningMoveFor(moves, me.other);
        if (forced != null) return forced;
        return _bestByNegamax(moves);
    }
  }

  /// `true` si jouer [column] permet à [opponent] de gagner juste après.
  bool _givesWin(List<int> moves, int column, Disc opponent) =>
      Connect4Rules.winningMoveFor([...moves, column], opponent) != null;

  int _centerWeighted(List<int> columns) {
    // Poids 4 au centre, 1 sur les bords.
    final weights = [for (final c in columns) 4 - (c - 3).abs()];
    var pick = _random.nextInt(weights.reduce((a, b) => a + b));
    for (var i = 0; i < columns.length; i++) {
      pick -= weights[i];
      if (pick < 0) return columns[i];
    }
    return columns.last;
  }

  int _bestByNegamax(List<int> moves) {
    final work = [...moves];
    var bestScore = -_win * 2;
    final best = <int>[];
    for (final column in _centerFirst) {
      if (!Connect4Rules.isValidMove(work, column)) continue;
      work.add(column);
      final score = -_negamax(work, _expertDepth - 1, -_win * 2, _win * 2);
      work.removeLast();
      if (score > bestScore) {
        bestScore = score;
        best
          ..clear()
          ..add(column);
      } else if (score == bestScore) {
        best.add(column);
      }
    }
    return best[_random.nextInt(best.length)];
  }

  /// Score de la position pour le joueur au trait.
  int _negamax(List<int> moves, int depth, int alpha, int beta) {
    final outcome = Connect4Rules.outcome(moves);
    if (outcome == Connect4Outcome.draw) return 0;
    // Le coup précédent a gagné : perdu pour le joueur au trait. Plus la
    // défaite est lointaine, moins elle coûte (on retarde l'inévitable).
    if (outcome != null) return -_win - depth;
    if (depth == 0) return _evaluate(moves);

    var value = -_win * 2;
    for (final column in _centerFirst) {
      if (!Connect4Rules.isValidMove(moves, column)) continue;
      moves.add(column);
      final score = -_negamax(moves, depth - 1, -beta, -alpha);
      moves.removeLast();
      if (score > value) value = score;
      if (value > alpha) alpha = value;
      if (alpha >= beta) break;
    }
    return value;
  }

  /// Évaluation statique pour le joueur au trait : fenêtres de 4 cases
  /// encore gagnables, plus un bonus pour la colonne centrale.
  int _evaluate(List<int> moves) {
    final me = Connect4Rules.discToPlay(moves);
    final board = Connect4Rules.stacks(moves);
    Disc? at(int c, int r) => r < board[c].length ? board[c][r] : null;

    var score = 0;
    for (final disc in board[3]) {
      score += disc == me ? 3 : -3;
    }
    const directions = [(1, 0), (0, 1), (1, 1), (1, -1)];
    for (var c = 0; c < Connect4Rules.columns; c++) {
      for (var r = 0; r < Connect4Rules.rows; r++) {
        for (final (dc, dr) in directions) {
          final endC = c + dc * 3;
          final endR = r + dr * 3;
          if (endC >= Connect4Rules.columns ||
              endR < 0 ||
              endR >= Connect4Rules.rows) {
            continue;
          }
          var mine = 0;
          var theirs = 0;
          for (var i = 0; i < 4; i++) {
            final disc = at(c + dc * i, r + dr * i);
            if (disc == me) {
              mine++;
            } else if (disc != null) {
              theirs++;
            }
          }
          if (theirs == 0) score += const [0, 1, 4, 16, 0][mine];
          if (mine == 0) score -= const [0, 1, 4, 18, 0][theirs];
        }
      }
    }
    return score;
  }
}
