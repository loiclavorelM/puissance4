import 'dart:math';

/// Calcul Elo (cahier des charges, table "Paramètres du système Elo").
abstract final class Elo {
  static const kFactor = 32;

  /// Variation d'Elo d'un joueur à [player] contre [opponent], pour un
  /// [score] de 1 (victoire), 0.5 (nul) ou 0 (défaite).
  ///
  /// Ex. : 1000 contre 1200 → +24 en cas de victoire, −8 en cas de défaite.
  static int delta(int player, int opponent, double score) {
    final expected = 1 / (1 + pow(10, (opponent - player) / 400));
    return (kFactor * (score - expected)).round();
  }
}
