import 'json.dart';
import 'source_catalog.dart';
import 'source_data.dart';
import 'widget_definition.dart';

/// Canal d'un graphique : quelle colonne va où.
enum ChartChannel { x, y, value, color }

final class MarkRule {
  const MarkRule({
    required this.channels,
    this.maxCategories,
    this.maxSeries,
    this.options = const {},
  });

  /// Types de champ acceptés par canal ; un canal absent est interdit.
  final Map<ChartChannel, Set<FieldType>> channels;
  final int? maxCategories;
  final int? maxSeries;

  /// `stack`, `horizontal`.
  final Set<String> options;
}

/// Règles de validité des graphiques (`contracts/chart-rules.json`), lues
/// par le serveur (validation des outils) et par l'app (panneau
/// « Modifier »), pour que les deux appliquent les mêmes.
///
/// Les messages d'erreur s'adressent au LLM : ils disent quoi corriger.
final class ChartRules {
  ChartRules._(this.marks, this.json);

  factory ChartRules.fromJson(Json json) => ChartRules._({
    for (final MapEntry(:key, :value) in json.objectOrNull('marks')!.entries)
      ChartMark.values.byName(key): _rule((value! as Map).cast()),
  }, json);

  static MarkRule _rule(Json json) {
    Set<FieldType>? types(String channel) => switch (json[channel]) {
      final List<Object?> list => {
        for (final type in list) FieldType.values.byName(type! as String),
      },
      _ => null,
    };
    return MarkRule(
      channels: {
        for (final channel in ChartChannel.values)
          channel: ?types(channel.name),
      },
      maxCategories: json.intOrNull('maxCategories'),
      maxSeries: json.intOrNull('maxSeries'),
      options: json.list('options').cast<String>().toSet(),
    );
  }

  final Map<ChartMark, MarkRule> marks;
  final Json json;

  int get gridColumns =>
      (json.objectOrNull('grid')!['columns']! as num).toInt();
  int get maxHeight =>
      (json.objectOrNull('grid')!['maxHeight']! as num).toInt();
  int get minRefreshSeconds => json.intOrNull('minRefreshSeconds')!;
  List<String> get displayColors => json.list('displayColors').cast();

  ({int w, int h}) defaultSize(WidgetType type) {
    final size = json.objectOrNull('defaultSize')!.objectOrNull(type.name)!;
    return (w: size.intOrNull('w')!, h: size.intOrNull('h')!);
  }

  /// Champs de [source] utilisables sur [channel] pour [mark] : ce que le
  /// panneau « Modifier » propose.
  List<FieldSpec> allowedFields(
    ChartMark mark,
    ChartChannel channel,
    SourceSpec source,
    SourceCatalog catalog,
  ) {
    final allowed = marks[mark]!.channels[channel];
    if (allowed == null) return const [];
    return [
      for (final field in catalog.fieldsOf(source))
        if (!field.internal && allowed.contains(field.type)) field,
    ];
  }

  /// Erreurs de [definition] sans regarder les données.
  List<String> validate(WidgetDefinition definition, SourceCatalog catalog) {
    final errors = <String>[];
    final source = catalog[definition.query.source];
    if (source == null) {
      return [
        'Unknown source ${definition.query.source}. '
            'Sources: ${catalog.sources.keys.join(', ')}.',
      ];
    }
    errors.addAll(catalog.checkParams(source, definition.query.params));

    switch ((definition.type, source.kind)) {
      case (WidgetType.kpi, SourceKind.rows):
        errors.add(
          '${source.key} returns rows: use type table or chart, '
          'or a kpi source (${_keys(catalog, SourceKind.kpi)}).',
        );
      case (WidgetType.table || WidgetType.chart, SourceKind.kpi):
        errors.add(
          '${source.key} returns a single number: use type kpi, '
          'or a rows source (${_keys(catalog, SourceKind.rows)}).',
        );
      default:
    }

    final chart = definition.chart;
    if (definition.type == WidgetType.chart && chart == null) {
      errors.add('A chart widget needs a chart spec (mark).');
    }
    if (definition.type != WidgetType.chart && chart != null) {
      errors.add('Only a chart widget has a chart spec.');
    }
    if (chart != null && source.kind == SourceKind.rows) {
      errors.addAll(_validateChart(chart, source, catalog));
    }

    if (definition.display.color case final color?
        when !displayColors.contains(color)) {
      errors.add('displayColor must be one of ${displayColors.join(', ')}.');
    }
    if (definition.refresh.minIntervalSeconds < minRefreshSeconds) {
      errors.add('Refresh interval must be at least $minRefreshSeconds s.');
    }
    if (definition.layout case final layout?) {
      if (layout.x < 0 ||
          layout.w < 1 ||
          layout.x + layout.w > gridColumns ||
          layout.y < 0 ||
          layout.h < 1 ||
          layout.h > maxHeight) {
        errors.add(
          'Layout out of the grid: col 0-${gridColumns - 1}, '
          'col + width <= $gridColumns, height 1-$maxHeight.',
        );
      }
    }
    return errors;
  }

  List<String> _validateChart(
    ChartSpec chart,
    SourceSpec source,
    SourceCatalog catalog,
  ) {
    final rule = marks[chart.mark]!;
    final errors = <String>[];
    final channels = {
      ChartChannel.x: chart.x?.field,
      ChartChannel.y: chart.y?.field,
      ChartChannel.value: chart.value?.field,
      ChartChannel.color: chart.color?.field,
    };
    for (final MapEntry(key: channel, value: name) in channels.entries) {
      final allowed = rule.channels[channel];
      if (name == null) {
        if (allowed != null && channel != ChartChannel.color) {
          errors.add('A ${chart.mark.name} chart needs ${channel.name}.');
        }
        continue;
      }
      if (allowed == null) {
        errors.add('A ${chart.mark.name} chart has no ${channel.name}.');
        continue;
      }
      if (!source.fields.contains(name) || catalog.fields[name]!.internal) {
        errors.add(
          '${source.key} has no field $name '
          '(fields: ${_visibleFields(source, catalog)}).',
        );
        continue;
      }
      final type = catalog.fields[name]!.type;
      if (!allowed.contains(type)) {
        errors.add(
          _typeError(chart.mark, channel, name, type, allowed, source, catalog),
        );
      }
    }
    if (chart.stack && !rule.options.contains('stack')) {
      errors.add('Only bar and area charts can be stacked.');
    }
    if (chart.horizontal && !rule.options.contains('horizontal')) {
      errors.add('Only bar charts can be horizontal.');
    }
    if (chart.stack && chart.color == null) {
      errors.add('stack needs a color field to split the series.');
    }
    return errors;
  }

  String _typeError(
    ChartMark mark,
    ChartChannel channel,
    String field,
    FieldType type,
    Set<FieldType> allowed,
    SourceSpec source,
    SourceCatalog catalog,
  ) {
    final fitting = allowedFields(mark, channel, source, catalog);
    final suggestion = fitting.isEmpty
        ? 'use another chart type'
        : 'use ${fitting.map((f) => f.name).join(' or ')}';
    final kinds = allowed.map((t) => t.name).join(' or ');
    return 'A ${mark.name} chart needs a $kinds ${channel.name}, '
        'but $field is ${type.name}: $suggestion.';
  }

  /// Erreurs qui dépendent des données (nombre de catégories, de séries).
  List<String> validateData(ChartSpec chart, DataSet data) {
    final rule = marks[chart.mark]!;
    final errors = <String>[];
    final x = chart.x?.field;
    if (rule.maxCategories case final max?
        when x != null && data.field(x)?.type == FieldType.category) {
      final count = data.column(x).toSet().length;
      if (count > max) {
        errors.add(switch (chart.mark) {
          ChartMark.donut =>
            'A donut shows $max parts at most and $x has $count values: '
                'use horizontal bars, or a narrower range.',
          _ =>
            'A ${chart.mark.name} chart shows $max categories at most and $x '
                'has $count values: use a narrower range or lastGames.',
        });
      }
    }
    final color = chart.color;
    if (rule.maxSeries case final max? when color != null) {
      final count = data.column(color.field).toSet().length;
      final shown = color.limit == null ? count : color.limit!.clamp(0, count);
      if (shown > max) {
        errors.add(
          'A ${chart.mark.name} chart shows $max series at most and '
          '${color.field} has $count values: set colorLimit to $max or less.',
        );
      }
    }
    return errors;
  }

  static String _keys(SourceCatalog catalog, SourceKind kind) => [
    for (final source in catalog.sources.values)
      if (source.kind == kind) source.key,
  ].join(', ');

  static String _visibleFields(SourceSpec source, SourceCatalog catalog) => [
    for (final field in catalog.fieldsOf(source))
      if (!field.internal) field.name,
  ].join(', ');
}
