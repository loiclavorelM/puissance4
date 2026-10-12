import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'charts/chart_series.dart';
import 'l10n/assistant_ui_localizations.dart';

/// Libellés affichés : ceux des contrats (sources, champs, valeurs) dans la
/// langue de l'app, et ceux du package (types, périodes…).
class DashboardLabels {
  DashboardLabels._(this.l10n, this.language, this.catalog);

  factory DashboardLabels.of(BuildContext context) => DashboardLabels._(
    AssistantUiLocalizations.of(context),
    Localizations.localeOf(context).languageCode,
    AssistantContracts.catalog,
  );

  final AssistantUiLocalizations l10n;
  final String language;
  final SourceCatalog catalog;

  String field(String name) => catalog.fields[name]?.label.of(language) ?? name;

  String source(String key) => catalog[key]?.label.of(language) ?? key;

  /// Une valeur de [fieldName] : libellé de catégorie, date courte, nombre.
  String value(String? fieldName, Object? value) {
    if (value == othersKey) return l10n.others;
    if (value == null) return '–';
    final spec = fieldName == null ? null : catalog.fields[fieldName];
    switch (spec?.type) {
      case FieldType.temporal:
        final date = DateTime.tryParse('$value');
        if (date == null) return '$value';
        return '$value'.length > 10
            ? DateFormat.MMMd(language).add_Hm().format(date.toLocal())
            : DateFormat.MMMd(language).format(date);
      case FieldType.number:
        return value is num
            ? NumberFormat.decimalPattern(language).format(value)
            : '$value';
      case FieldType.category || null:
        return spec?.valueLabel(value, language) ?? '$value';
    }
  }

  String range(String? value) => switch (value) {
    'last:24h' => l10n.range_last24h,
    'last:7d' => l10n.range_last7d,
    'last:30d' => l10n.range_last30d,
    'last:90d' => l10n.range_last90d,
    'this:week' => l10n.range_thisWeek,
    'this:month' => l10n.range_thisMonth,
    'this:year' => l10n.range_thisYear,
    _ => l10n.range_all,
  };

  String type(WidgetType type) => switch (type) {
    WidgetType.kpi => l10n.typeKpi,
    WidgetType.table => l10n.typeTable,
    WidgetType.chart => l10n.typeChart,
  };

  String mark(ChartMark mark) => switch (mark) {
    ChartMark.bar => l10n.markBar,
    ChartMark.line => l10n.markLine,
    ChartMark.area => l10n.markArea,
    ChartMark.donut => l10n.markDonut,
    ChartMark.heatmap => l10n.markHeatmap,
  };

  String aggregate(Aggregate aggregate) => switch (aggregate) {
    Aggregate.sum => l10n.aggSum,
    Aggregate.avg => l10n.aggAvg,
    Aggregate.min => l10n.aggMin,
    Aggregate.max => l10n.aggMax,
    Aggregate.count => l10n.aggCount,
  };

  String tool(String name) => switch (name) {
    'list_data_sources' => l10n.chatTool_list_data_sources,
    'get_dashboard' => l10n.chatTool_get_dashboard,
    'add_widget' => l10n.chatTool_add_widget,
    'propose_widget' => l10n.chatTool_propose_widget,
    'update_widget' => l10n.chatTool_update_widget,
    'remove_widget' => l10n.chatTool_remove_widget,
    'arrange_widgets' => l10n.chatTool_arrange_widgets,
    'undo_dashboard' => l10n.chatTool_undo_dashboard,
    'set_dashboard_filters' => l10n.chatTool_set_dashboard_filters,
    'query_data' => l10n.chatTool_query_data,
    'analyze_game' => l10n.chatTool_analyze_game,
    _ => name,
  };

  String error(AssistantErrorCode code) => switch (code) {
    AssistantErrorCode.notConfigured => l10n.chatError_notConfigured,
    AssistantErrorCode.unavailable => l10n.chatError_unavailable,
    AssistantErrorCode.rateLimited => l10n.chatError_rateLimited,
    AssistantErrorCode.tooManySteps => l10n.chatError_tooManySteps,
    AssistantErrorCode.invalidInput => l10n.chatError_invalidInput,
  };
}
