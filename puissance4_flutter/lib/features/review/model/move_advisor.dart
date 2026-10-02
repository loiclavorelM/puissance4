import 'package:flutter/foundation.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

/// Avis de l'Expert sur un coup d'une partie terminée (E14, T14.2.2).
/// Aujourd'hui la recherche de `HeuristicBot` ; demain le modèle RL Expert
/// embarqué (E5) derrière la même interface.
abstract interface class MoveAdvisor {
  /// Analyse le coup d'indice [index] de [moves].
  Future<MoveAnalysis> analyze(List<int> moves, int index);
}

class ExpertMoveAdvisor implements MoveAdvisor {
  const ExpertMoveAdvisor();

  /// Hors du thread UI, comme le bot Expert (`HeuristicBotBrain`).
  @override
  Future<MoveAnalysis> analyze(List<int> moves, int index) =>
      compute(_analyze, (List<int>.of(moves), index));
}

MoveAnalysis _analyze((List<int>, int) args) =>
    MoveAnalysis.of(args.$1, args.$2);
