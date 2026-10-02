/// Règles du Puissance 4 — seule copie, importée par `puissance4_server`
/// (seul juge des parties Multi/Classé) et `puissance4_flutter` (moteur
/// local du mode Normal, replay). Pur Dart, sans dépendance : les types
/// générés par Serverpod (`EnumColor`, `EnumOutcome`) sont convertis de
/// chaque côté.
library;

export 'src/connect4_rules.dart';
export 'src/heuristic_bot.dart';
export 'src/move_analysis.dart';
