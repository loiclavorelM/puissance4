import 'chart_rules.dart';
import 'json.dart';
import 'source_catalog.dart';
import 'widget_definition.dart';

/// Place demandée pour un widget ; ce qui manque est complété par le
/// tableau de bord (taille par défaut, première place libre).
final class LayoutRequest {
  const LayoutRequest({this.col, this.row, this.width, this.height});

  final int? col;
  final int? row;
  final int? width;
  final int? height;

  bool get isEmpty =>
      col == null && row == null && width == null && height == null;
}

/// Passage des arguments **à plat** des outils (`add_widget`,
/// `propose_widget`, `update_widget`) à la définition imbriquée du contrat.
///
/// À plat parce que le lot 0 l'a montré : avec un objet `params` imbriqué,
/// le modèle invente les clés ; à plat, il suit le schéma.
final class WidgetArgs {
  WidgetArgs(this.catalog, this.rules);

  final SourceCatalog catalog;
  final ChartRules rules;

  static const _chartArgs = {
    'mark',
    'x',
    'y',
    'value',
    'aggregate',
    'color',
    'colorLimit',
    'stack',
    'horizontal',
  };

  static const layoutArgs = {'col', 'row', 'width', 'height'};

  /// Nouvelle définition depuis [args]. Les paramètres de source absents qui
  /// peuvent venir du tableau de bord le suivent (`$dashboard.xxx`).
  (WidgetDefinition, LayoutRequest) build(Json args) {
    final type = WidgetType.values.byName(args.string('type'));
    final source = catalog[args.string('source')];
    final params = <String, Object?>{};
    if (source != null) {
      for (final param in source.params) {
        if (args[param] case final value?) {
          params[param] = value;
        } else if (catalog.dashboardParams.contains(param)) {
          params[param] = '$dashboardPrefix$param';
        }
      }
      // `lastGames` et `range` ne se cumulent pas : un nombre de parties
      // donné explicitement l'emporte sur la période du tableau de bord.
      if (args['lastGames'] != null && args['range'] == null) {
        params.remove('range');
      }
    }
    // Un paramètre qui n'existe pas pour cette source reste visible, pour
    // que la validation le signale au lieu de l'ignorer.
    for (final name in catalog.params.keys) {
      if (args[name] != null && !(source?.params.contains(name) ?? false)) {
        params[name] = args[name];
      }
    }

    final definition = WidgetDefinition(
      type: type,
      title: args.string('title'),
      query: DataQuery(args.string('source'), params),
      chart: type == WidgetType.chart && source != null
          ? _chart(args, source, params)
          : null,
      refresh: switch (args.stringOrNull('refresh')) {
        final mode? => RefreshPolicy(RefreshMode.values.byName(mode)),
        null => RefreshPolicy.live,
      },
      display: WidgetDisplay(
        columns: switch (args['columns']) {
          final List<Object?> columns => columns.cast<String>(),
          _ => null,
        },
        color: args.stringOrNull('displayColor'),
        cell:
            args.stringOrNull('cellShape') ??
            (source?.key == 'moves.byCell' ? 'circle' : null),
      ),
    );
    return (
      definition,
      LayoutRequest(
        col: args.intOrNull('col'),
        row: args.intOrNull('row'),
        width: args.intOrNull('width'),
        height: args.intOrNull('height'),
      ),
    );
  }

  /// [base] modifié par [args] : seuls les arguments donnés changent,
  /// [clear] retire des arguments (un paramètre retiré suit de nouveau le
  /// tableau de bord). Changer de source ou de type de graphique repart des
  /// valeurs par défaut pour les axes non redonnés.
  (WidgetDefinition, LayoutRequest) update(
    WidgetDefinition base,
    Json args, {
    List<String> clear = const [],
  }) {
    final merged = toArgs(base);
    final sourceChanged =
        args['source'] != null && args['source'] != base.query.source;
    final markChanged =
        args['mark'] != null && args['mark'] != base.chart?.mark.name;
    // Tableau croisé : changer une dimension ou la mesure change les champs
    // renvoyés, les axes repartent donc des valeurs par défaut.
    final fieldParams = catalog[base.query.source]?.fieldParams ?? const [];
    final fieldsChanged = fieldParams.any(
      (p) =>
          (args[p] != null && args[p] != merged[p]) ||
          (clear.contains(p) && merged.containsKey(p)),
    );
    if (sourceChanged || markChanged || fieldsChanged) {
      merged.removeWhere((key, _) => _chartArgs.contains(key) && key != 'mark');
    }
    // Les colonnes choisies n'existent plus forcément.
    if (sourceChanged || fieldsChanged) merged.remove('columns');
    if (sourceChanged) {
      final source = catalog[args.string('source')];
      merged.removeWhere(
        (key, _) =>
            catalog.params.containsKey(key) &&
            !(source?.params.contains(key) ?? false),
      );
    }
    for (final name in clear) {
      merged.remove(name);
    }
    for (final MapEntry(:key, :value) in args.entries) {
      if (key != 'id' && key != 'clear' && value != null) merged[key] = value;
    }
    final (definition, layout) = build(merged);
    return (
      WidgetDefinition(
        id: base.id,
        type: definition.type,
        title: definition.title,
        query: definition.query,
        chart: definition.chart,
        refresh: definition.refresh,
        drilldown: base.drilldown,
        display: definition.display,
        layout: base.layout,
      ),
      layout,
    );
  }

  /// La définition vue comme des arguments à plat (sans la place).
  Json toArgs(WidgetDefinition definition) {
    final chart = definition.chart;
    return compact({
      'type': definition.type.name,
      'title': definition.title,
      'source': definition.query.source,
      for (final MapEntry(:key, :value) in definition.query.params.entries)
        if (!(value is String && value.startsWith(dashboardPrefix))) key: value,
      'mark': chart?.mark.name,
      'x': chart?.x?.field,
      'y': chart?.y?.field,
      'value': chart?.value?.field,
      'aggregate': (chart?.y?.aggregate ?? chart?.value?.aggregate)?.name,
      'color': chart?.color?.field,
      'colorLimit': chart?.color?.limit,
      if (chart?.stack ?? false) 'stack': true,
      if (chart?.horizontal ?? false) 'horizontal': true,
      'columns': definition.display.columns,
      'displayColor': definition.display.color,
      'cellShape': definition.display.cell,
      if (definition.refresh.mode != RefreshMode.live)
        'refresh': definition.refresh.mode.name,
    });
  }

  ChartSpec _chart(Json args, SourceSpec source, Map<String, Object?> params) {
    final defaults = source.defaultChart;

    /// Un axe par défaut peut reprendre un paramètre (`"x": "$groupBy"`).
    String? resolve(String? axis) => axis != null && axis.startsWith(r'$')
        ? catalog.paramValue(axis.substring(1), params)
        : axis;
    final mark = ChartMark.values.byName(
      args.stringOrNull('mark') ?? defaults?.mark ?? ChartMark.bar.name,
    );
    final sameMark = defaults?.mark == mark.name;

    String? pick(ChartChannel channel, String? given, String? byDefault) {
      if (given != null) return given;
      final fitting = rules.allowedFields(
        mark,
        channel,
        source,
        catalog,
        params: params,
      );
      if (byDefault != null && fitting.any((f) => f.name == byDefault)) {
        return byDefault;
      }
      if (channel == ChartChannel.color) return null;
      return fitting.firstOrNull?.name;
    }

    final aggregate = switch (args.stringOrNull('aggregate')) {
      final name? => Aggregate.values.byName(name),
      null => null,
    };
    final hasX = rules.marks[mark]!.channels.containsKey(ChartChannel.x);
    final hasY = rules.marks[mark]!.channels.containsKey(ChartChannel.y);
    final hasValue = rules.marks[mark]!.channels.containsKey(
      ChartChannel.value,
    );
    final hasColor = rules.marks[mark]!.channels.containsKey(
      ChartChannel.color,
    );

    final x = hasX || args['x'] != null
        ? pick(ChartChannel.x, args.stringOrNull('x'), resolve(defaults?.x))
        : null;
    final y = hasY || args['y'] != null
        ? pick(ChartChannel.y, args.stringOrNull('y'), resolve(defaults?.y))
        : null;
    final value = hasValue || args['value'] != null
        ? pick(
            ChartChannel.value,
            args.stringOrNull('value'),
            resolve(defaults?.value),
          )
        : null;
    final color = hasColor || args['color'] != null
        ? pick(
            ChartChannel.color,
            args.stringOrNull('color'),
            sameMark ? resolve(defaults?.color) : null,
          )
        : null;

    return ChartSpec(
      mark: mark,
      x: x == null ? null : Encoding(x),
      y: y == null ? null : Encoding(y, aggregate: aggregate),
      value: value == null ? null : Encoding(value, aggregate: aggregate),
      color: color == null
          ? null
          : ColorEncoding(color, limit: args.intOrNull('colorLimit')),
      stack:
          args.boolOrNull('stack') ??
          (sameMark && color != null && (defaults?.stack ?? false)),
      horizontal:
          args.boolOrNull('horizontal') ??
          (sameMark && (defaults?.horizontal ?? false)),
    );
  }
}
