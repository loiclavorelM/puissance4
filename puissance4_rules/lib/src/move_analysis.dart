import 'connect4_rules.dart';

/// Avis de l'Expert sur un coup d'une partie terminée (revue de partie,
/// E14) : ce qu'une recherche exacte ([_Search]) aurait joué à la place, et
/// ce que valait le coup joué.
/// Déterministe (à égalité, la colonne la plus centrale) : la même position
/// donne toujours la même recommandation, sur le téléphone comme sur le
/// serveur qui l'explique.
class MoveAnalysis {
  MoveAnalysis._(this.played, this.scores, this.recommended);

  /// Analyse le coup d'indice [index] de [moves] (la position est celle
  /// qui précède ce coup).
  factory MoveAnalysis.of(List<int> moves, int index) {
    RangeError.checkValidIndex(index, moves);
    final scores = _Search.scoreColumns(moves.sublist(0, index));
    // Les colonnes arrivent du centre vers les bords : la première meilleure
    // est la plus centrale.
    var recommended = scores.keys.first;
    for (final MapEntry(key: column, value: score) in scores.entries) {
      if (score > scores[recommended]!) recommended = column;
    }
    return MoveAnalysis._(moves[index], scores, recommended);
  }

  /// Colonne jouée.
  final int played;

  /// Colonne recommandée par l'Expert.
  final int recommended;

  /// Score de chaque colonne jouable pour le joueur qui avait le trait.
  final Map<int, int> scores;

  /// Le coup joué valait celui de l'Expert (même s'il est différent).
  bool get isBest => scores[played] == scores[recommended];

  MoveVerdict get playedVerdict => _verdict(scores[played]!);
  MoveVerdict get recommendedVerdict => _verdict(scores[recommended]!);

  static MoveVerdict _verdict(int score) => score >= _Search.winScore
      ? MoveVerdict.forcedWin
      : score <= -_Search.winScore
      ? MoveVerdict.forcedLoss
      : MoveVerdict.open;

  /// Couleur du joueur qui a joué ce coup.
  static Disc playerOf(int index) => index.isEven ? Disc.rouge : Disc.jaune;
}

/// Ce que l'Expert voit au bout de sa recherche après un coup.
enum MoveVerdict {
  /// Victoire forcée pour le joueur qui a joué.
  forcedWin,

  /// Défaite forcée (l'adversaire gagne quoi qu'il arrive).
  forcedLoss,

  /// Rien de forcé à la profondeur de recherche.
  open,
}

/// Recherche négamax à profondeur 5 avec élagage alpha-bêta : le moteur de
/// la revue de partie. Ce n'est pas un bot (les bots jouent avec les réseaux
/// RL, `BotLevel`) : une recherche exacte peut affirmer qu'une victoire ou
/// une défaite est forcée, ce qu'un réseau ne garantit pas.
abstract final class _Search {
  static const _depth = 5;
  static const _win = 1000000;

  /// Colonnes du centre vers les bords : meilleur ordre d'exploration.
  static const _centerFirst = [3, 2, 4, 1, 5, 0, 6];

  /// Score de chaque colonne jouable après [moves], du point de vue du
  /// joueur au trait (colonnes du centre vers les bords).
  /// Au-delà de [winScore] en valeur absolue : victoire (ou défaite) forcée.
  static Map<int, int> scoreColumns(List<int> moves) {
    final work = [...moves];
    final scores = <int, int>{};
    for (final column in _centerFirst) {
      if (!Connect4Rules.isValidMove(work, column)) continue;
      work.add(column);
      scores[column] = -_negamax(work, _depth - 1, -_win * 2, _win * 2);
      work.removeLast();
    }
    return scores;
  }

  /// Seuil des scores de victoire forcée renvoyés par [scoreColumns].
  static const winScore = _win;

  /// Score de la position pour le joueur au trait.
  static int _negamax(List<int> moves, int depth, int alpha, int beta) {
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
  static int _evaluate(List<int> moves) {
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
