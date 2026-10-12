import 'connect4_rules.dart';

/// Garde-fou tactique d'une IA qui joue sans recherche (réseau RL seul,
/// `sims=0` dans le notebook) : un réseau voit bien la stratégie mais rate
/// encore des menaces immédiates. Avant de suivre ses scores, on applique
/// les trois règles du bot Medium (`NetworkBot`, niveaux `guarded`) :
///
/// 1. gagner si c'est possible ;
/// 2. sinon bloquer une victoire immédiate de l'adversaire ;
/// 3. sinon écarter les coups qui lui offrent la victoire juste après.
abstract final class TacticalGuard {
  /// Coup imposé après [moves] : la victoire du joueur au trait, sinon le
  /// blocage de celle de l'adversaire, sinon `null`.
  static int? forcedMove(List<int> moves) {
    final me = Connect4Rules.discToPlay(moves);
    return Connect4Rules.winningMoveFor(moves, me) ??
        Connect4Rules.winningMoveFor(moves, me.other);
  }

  /// Colonnes jouables qui n'offrent pas une victoire immédiate à
  /// l'adversaire — toutes les colonnes jouables si aucune ne l'évite.
  static List<int> safeMoves(List<int> moves) {
    final valid = Connect4Rules.validMoves(moves);
    final opponent = Connect4Rules.discToPlay(moves).other;
    final safe = [
      for (final column in valid)
        if (Connect4Rules.winningMoveFor([...moves, column], opponent) == null)
          column,
    ];
    return safe.isEmpty ? valid : safe;
  }
}
