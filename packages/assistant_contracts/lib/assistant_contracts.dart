/// Contrats de l'assistant et modèle de domaine en pur Dart, partagés par
/// `puissance4_server` (outils MCP, sources, orchestrateur) et
/// `packages/assistant_ui` (tableau de bord, chat). Les contrats JSON de
/// `contracts/` sont la source de vérité, embarqués par `tool/generate.dart`.
library;

export 'src/assistant_event.dart';
export 'src/chart_rules.dart';
export 'src/chat_input.dart';
export 'src/contracts.dart';
export 'src/dashboard.dart';
export 'src/json.dart';
export 'src/relative_range.dart';
export 'src/source_catalog.dart';
export 'src/source_data.dart';
export 'src/widget_args.dart';
export 'src/widget_definition.dart';
