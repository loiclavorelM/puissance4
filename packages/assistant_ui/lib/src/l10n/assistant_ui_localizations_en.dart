// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'assistant_ui_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AssistantUiLocalizationsEn extends AssistantUiLocalizations {
  AssistantUiLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboardEmptyTitle => 'Your dashboard is empty';

  @override
  String get dashboardEmptyBody =>
      'Ask the assistant to add a chart, or add one yourself.';

  @override
  String get widgetLoadError => 'Could not load this data.';

  @override
  String get retry => 'Retry';

  @override
  String get widgetNoData => 'No game to show yet.';

  @override
  String get widgetEdit => 'Edit';

  @override
  String get widgetRename => 'Rename';

  @override
  String get widgetRemove => 'Remove';

  @override
  String get widgetPin => 'Pin';

  @override
  String get widgetPinned => 'Pinned to the dashboard';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get renameTitle => 'Rename widget';

  @override
  String get others => 'Others';

  @override
  String kpiGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '1 game',
      zero: 'no game',
    );
    return '$_temp0';
  }

  @override
  String kpiBest(int best) {
    return 'best: $best';
  }

  @override
  String kpiDelta(String delta) {
    return '$delta pts';
  }

  @override
  String get filterAllPeriods => 'All time';

  @override
  String get filterAllModes => 'All modes';

  @override
  String get filterAllOpponents => 'All opponents';

  @override
  String get filterClearOpponent => 'Clear opponent filter';

  @override
  String get editorTitle => 'Edit widget';

  @override
  String get editorNewTitle => 'New widget';

  @override
  String get editorSource => 'Data';

  @override
  String get editorType => 'Display';

  @override
  String get editorMark => 'Chart';

  @override
  String get editorX => 'X axis';

  @override
  String get editorY => 'Measure';

  @override
  String get editorValue => 'Value';

  @override
  String get editorAggregate => 'Aggregation';

  @override
  String get editorColor => 'Series';

  @override
  String get editorColorNone => 'None';

  @override
  String get editorTopN => 'Top N';

  @override
  String get editorStack => 'Stack';

  @override
  String get editorHorizontal => 'Horizontal bars';

  @override
  String get editorPeriod => 'Period';

  @override
  String get editorFollowDashboard => 'Same as dashboard';

  @override
  String get editorTitleField => 'Title';

  @override
  String get typeKpi => 'Key figure';

  @override
  String get typeTable => 'Table';

  @override
  String get typeChart => 'Chart';

  @override
  String get markBar => 'Bars';

  @override
  String get markLine => 'Line';

  @override
  String get markArea => 'Area';

  @override
  String get markDonut => 'Donut';

  @override
  String get markHeatmap => 'Heatmap';

  @override
  String get aggSum => 'Sum';

  @override
  String get aggAvg => 'Average';

  @override
  String get aggMin => 'Minimum';

  @override
  String get aggMax => 'Maximum';

  @override
  String get aggCount => 'Count';

  @override
  String get range_last24h => '24 h';

  @override
  String get range_last7d => '7 days';

  @override
  String get range_last30d => '30 days';

  @override
  String get range_last90d => '90 days';

  @override
  String get range_thisWeek => 'This week';

  @override
  String get range_thisMonth => 'This month';

  @override
  String get range_thisYear => 'This year';

  @override
  String get range_all => 'All time';

  @override
  String get chatTitle => 'Assistant';

  @override
  String get chatHint => 'Ask for a chart or a question…';

  @override
  String get chatSend => 'Send';

  @override
  String get chatEmpty =>
      'For example: “Add my win rate, and next to it a map of the cells I play on my last 30 games.”';

  @override
  String get chatNewConversation => 'New conversation';

  @override
  String get chatThinking => 'The assistant is thinking…';

  @override
  String get chatTool_list_data_sources => 'Looking at the available data';

  @override
  String get chatTool_get_dashboard => 'Reading your dashboard';

  @override
  String get chatTool_add_widget => 'Adding a widget';

  @override
  String get chatTool_propose_widget => 'Preparing a chart';

  @override
  String get chatTool_update_widget => 'Updating a widget';

  @override
  String get chatTool_remove_widget => 'Removing a widget';

  @override
  String get chatTool_arrange_widgets => 'Rearranging the dashboard';

  @override
  String get chatTool_undo_dashboard => 'Undoing the last change';

  @override
  String get chatTool_set_dashboard_filters => 'Changing the filters';

  @override
  String get chatTool_query_data => 'Checking your statistics';

  @override
  String get chatTool_analyze_game => 'Analyzing the game';

  @override
  String get chatError_notConfigured =>
      'The assistant is not available on this server.';

  @override
  String get chatError_unavailable =>
      'The assistant is not answering. Try again in a moment.';

  @override
  String get chatError_rateLimited =>
      'Too many requests for now. Try again later.';

  @override
  String get chatError_tooManySteps =>
      'Request too complex: rephrase it more simply.';

  @override
  String get chatError_invalidInput => 'Invalid message.';

  @override
  String get undo => 'Undo last change';

  @override
  String get addWidget => 'Add widget';

  @override
  String get openAssistant => 'Open assistant';

  @override
  String get exportPdf => 'Export as PDF';

  @override
  String get exportTitle => 'My Connect Four dashboard';

  @override
  String exportedOn(String date) {
    return 'Exported on $date';
  }

  @override
  String get exportFailed => 'The PDF export failed.';

  @override
  String get editorColumns => 'Columns';
}
