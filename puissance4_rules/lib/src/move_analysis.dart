import 'connect4_rules.dart';
import 'heuristic_bot.dart';

/// Avis de l'Expert sur un coup d'une partie terminée (revue de partie,
/// E14) : ce qu'il aurait joué à la place, et ce que valait le coup joué.
/// Déterministe (à égalité, la colonne la plus centrale) : la même position
/// donne toujours la même recommandation, sur le téléphone comme sur le
/// serveur qui l'explique.
class MoveAnalysis {
  MoveAnalysis._(this.played, this.scores, this.recommended);

  /// Analyse le coup d'indice [index] de [moves] (la position est celle
  /// qui précède ce coup).
  factory MoveAnalysis.of(List<int> moves, int index) {
    RangeError.checkValidIndex(index, moves);
    final scores = HeuristicBot.scoreColumns(moves.sublist(0, index));
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

  static MoveVerdict _verdict(int score) => score >= HeuristicBot.winScore
      ? MoveVerdict.forcedWin
      : score <= -HeuristicBot.winScore
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
