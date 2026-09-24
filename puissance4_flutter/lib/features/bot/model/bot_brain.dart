import 'package:flutter/foundation.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

/// IA d'un bot qui joue sur le téléphone : une position → une colonne.
/// Aujourd'hui l'heuristique partagée avec le serveur (`HeuristicBot`) ;
/// demain le modèle RL embarqué (T5.1.3) derrière la même interface.
abstract interface class BotBrain {
  Future<int> chooseColumn(List<int> moves);
}

class HeuristicBotBrain implements BotBrain {
  const HeuristicBotBrain(this.strength);

  /// Niveau d'après l'Elo virtuel du bot choisi (`bots_seed.yaml`).
  HeuristicBotBrain.forElo(int elo) : this(BotStrength.fromElo(elo));

  final BotStrength strength;

  /// Calcul hors du thread UI (la recherche Expert explore des milliers de
  /// positions) — sur le web, `compute` s'exécute simplement en place.
  @override
  Future<int> chooseColumn(List<int> moves) =>
      compute(_choose, (strength.index, List<int>.of(moves)));
}

int _choose((int, List<int>) args) =>
    HeuristicBot(BotStrength.values[args.$1]).chooseColumn(args.$2);
