/// Tableau de bord modulable et chat de l'assistant (E16). Transposable :
/// ni Serverpod ni gestionnaire d'état ; l'app fournit les ports
/// ([DashboardRepository], [DataSourceClient], [AssistantClient]) et les
/// couleurs ([DashboardTokens]), et ajoute
/// `AssistantUiLocalizations.delegate` à ses `localizationsDelegates`.
library;

export 'src/charts/chart_series.dart';
export 'src/controllers/chat_controller.dart';
export 'src/controllers/dashboard_controller.dart';
export 'src/controllers/widget_data_controller.dart';
export 'src/export/dashboard_pdf_export.dart';
export 'src/l10n/assistant_ui_localizations.dart';
export 'src/labels.dart';
export 'src/ports/ports.dart';
export 'src/theme/dashboard_tokens.dart';
export 'src/view/assistant_dashboard_view.dart';
export 'src/view/chart_editor.dart';
export 'src/view/chat_panel.dart';
export 'src/view/dashboard_grid.dart';
export 'src/view/filter_bar.dart';
export 'src/view/mini_markdown.dart';
export 'src/view/widget_frame.dart';
export 'src/widgets/widget_bodies.dart';
