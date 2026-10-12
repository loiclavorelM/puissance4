import 'package:flutter/foundation.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

/// Avis de l'Expert sur un coup d'une partie terminée (E14, T14.2.2).
/// Une recherche exacte (`MoveAnalysis`), pas un réseau : elle seule peut
/// affirmer qu'une victoire ou une défaite est forcée.
abstract interface class MoveAdvisor {
  /// Analyse le coup d'indice [index] de [moves].
  Future<MoveAnalysis> analyze(List<int> moves, int index);
}

class ExpertMoveAdvisor implements MoveAdvisor {
  const ExpertMoveAdvisor();

  /// Hors du thread UI : la recherche explore des milliers de positions.
  @override
  Future<MoveAnalysis> analyze(List<int> moves, int index) =>
      compute(_analyze, (List<int>.of(moves), index));
}

MoveAnalysis _analyze((List<int>, int) args) =>
    MoveAnalysis.of(args.$1, args.$2);
