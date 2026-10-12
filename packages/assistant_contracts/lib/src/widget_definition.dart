import 'json.dart';
import 'source_data.dart';

enum WidgetType { kpi, table, chart }

enum ChartMark { bar, line, area, donut, heatmap }

enum Aggregate { sum, avg, min, max, count }

enum RefreshMode { live, interval, manual }

/// Source et paramètres d'un widget. Une valeur `$dashboard.xxx` reprend le
/// filtre du tableau de bord (voir `DashboardFilters.resolve`).
final class DataQuery {
  const DataQuery(this.source, [this.params = const {}]);

  factory DataQuery.fromJson(Json json) => DataQuery(
    json.string('source'),
    (json.objectOrNull('params') ?? const {}),
  );

  final String source;
  final Map<String, Object?> params;

  Json toJson() => {'source': source, if (params.isNotEmpty) 'params': params};
}

/// Quelle colonne va sur un axe.
final class Encoding {
  const Encoding(this.field, {this.type, this.aggregate});

  factory Encoding.fromJson(Json json) => Encoding(
    json.string('field'),
    type: switch (json.stringOrNull('type')) {
      final type? => FieldType.values.byName(type),
      null => null,
    },
    aggregate: switch (json.stringOrNull('aggregate')) {
      final aggregate? => Aggregate.values.byName(aggregate),
      null => null,
    },
  );

  final String field;
  final FieldType? type;
  final Aggregate? aggregate;

  Json toJson() => compact({
    'field': field,
    'type': type?.name,
    'aggregate': aggregate?.name,
  });
}

/// Découpage en séries, avec un top N et une catégorie « Autres ».
final class ColorEncoding {
  const ColorEncoding(this.field, {this.limit, this.others = true});

  factory ColorEncoding.fromJson(Json json) => ColorEncoding(
    json.string('field'),
    limit: json.intOrNull('limit'),
    others: json.boolOrNull('others') ?? true,
  );

  final String field;
  final int? limit;
  final bool others;

  Json toJson() => compact({
    'field': field,
    'limit': limit,
    if (!others) 'others': false,
  });
}

/// Spec d'un graphique : quoi montrer et comment, jamais les données.
final class ChartSpec {
  const ChartSpec({
    required this.mark,
    this.x,
    this.y,
    this.value,
    this.color,
    this.stack = false,
    this.horizontal = false,
  });

  factory ChartSpec.fromJson(Json json) => ChartSpec(
    mark: ChartMark.values.byName(json.string('mark')),
    x: _encoding(json.objectOrNull('x')),
    y: _encoding(json.objectOrNull('y')),
    value: _encoding(json.objectOrNull('value')),
    color: switch (json.objectOrNull('color')) {
      final color? => ColorEncoding.fromJson(color),
      null => null,
    },
    stack: json.boolOrNull('stack') ?? false,
    horizontal: json.boolOrNull('horizontal') ?? false,
  );

  static Encoding? _encoding(Json? json) =>
      json == null ? null : Encoding.fromJson(json);

  final ChartMark mark;
  final Encoding? x;
  final Encoding? y;
  final Encoding? value;
  final ColorEncoding? color;
  final bool stack;
  final bool horizontal;

  Json toJson() => compact({
    'mark': mark.name,
    'x': x?.toJson(),
    'y': y?.toJson(),
    'value': value?.toJson(),
    'color': color?.toJson(),
    if (stack) 'stack': true,
    if (horizontal) 'horizontal': true,
  });
}

final class RefreshPolicy {
  const RefreshPolicy(this.mode, {this.minIntervalSeconds = 5});

  factory RefreshPolicy.fromJson(Json json) => RefreshPolicy(
    RefreshMode.values.byName(json.string('mode')),
    minIntervalSeconds: json.intOrNull('minIntervalSeconds') ?? 5,
  );

  static const live = RefreshPolicy(RefreshMode.live);

  final RefreshMode mode;
  final int minIntervalSeconds;

  Json toJson() => {
    'mode': mode.name,
    'minIntervalSeconds': minIntervalSeconds,
  };
}

/// Ce qui s'ouvre au clic sur une barre ou un point : la source cible,
/// filtrée par la valeur cliquée de [filterField].
final class Drilldown {
  const Drilldown(this.source, this.filterField);

  factory Drilldown.fromJson(Json json) =>
      Drilldown(json.string('source'), json.string('filterField'));

  final String source;
  final String filterField;

  Json toJson() => {'source': source, 'filterField': filterField};
}

/// Rendu : des jetons du thème, jamais de couleur en dur.
final class WidgetDisplay {
  const WidgetDisplay({this.cell, this.color});

  factory WidgetDisplay.fromJson(Json json) => WidgetDisplay(
    cell: json.stringOrNull('cell'),
    color: json.stringOrNull('color'),
  );

  /// `square` ou `circle` (cases du plateau).
  final String? cell;

  /// `accent`, `success`, `warn`, `danger`, `neutral`, `rouge`, `jaune`.
  final String? color;

  bool get isEmpty => cell == null && color == null;

  Json toJson() => compact({'cell': cell, 'color': color});
}

/// Place sur une grille de 12 colonnes.
final class WidgetLayout {
  const WidgetLayout({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  factory WidgetLayout.fromJson(Json json) => WidgetLayout(
    x: json.intOrNull('x')!,
    y: json.intOrNull('y')!,
    w: json.intOrNull('w')!,
    h: json.intOrNull('h')!,
  );

  final int x;
  final int y;
  final int w;
  final int h;

  bool overlaps(WidgetLayout other) =>
      x < other.x + other.w &&
      other.x < x + w &&
      y < other.y + other.h &&
      other.y < y + h;

  Json toJson() => {'x': x, 'y': y, 'w': w, 'h': h};

  @override
  bool operator ==(Object other) =>
      other is WidgetLayout &&
      other.x == x &&
      other.y == y &&
      other.w == w &&
      other.h == h;

  @override
  int get hashCode => Object.hash(x, y, w, h);
}

/// Un widget du tableau de bord, ou un bloc du chat
/// (`contracts/widget-definition.schema.json`).
final class WidgetDefinition {
  const WidgetDefinition({
    this.id,
    required this.type,
    required this.title,
    required this.query,
    this.chart,
    this.refresh = RefreshPolicy.live,
    this.drilldown,
    this.display = const WidgetDisplay(),
    this.layout,
  });

  factory WidgetDefinition.fromJson(Json json) => WidgetDefinition(
    id: json.stringOrNull('id'),
    type: WidgetType.values.byName(json.string('type')),
    title: json.string('title'),
    query: DataQuery.fromJson(json.objectOrNull('query')!),
    chart: switch (json.objectOrNull('chart')) {
      final chart? => ChartSpec.fromJson(chart),
      null => null,
    },
    refresh: switch (json.objectOrNull('refresh')) {
      final refresh? => RefreshPolicy.fromJson(refresh),
      null => RefreshPolicy.live,
    },
    drilldown: switch (json.objectOrNull('drilldown')) {
      final drilldown? => Drilldown.fromJson(drilldown),
      null => null,
    },
    display: switch (json.objectOrNull('display')) {
      final display? => WidgetDisplay.fromJson(display),
      null => const WidgetDisplay(),
    },
    layout: switch (json.objectOrNull('layout')) {
      final layout? => WidgetLayout.fromJson(layout),
      null => null,
    },
  );

  /// Attribué par le serveur (`w_` + 8 caractères), jamais par le LLM.
  final String? id;
  final WidgetType type;
  final String title;
  final DataQuery query;
  final ChartSpec? chart;
  final RefreshPolicy refresh;
  final Drilldown? drilldown;
  final WidgetDisplay display;
  final WidgetLayout? layout;

  WidgetDefinition copyWith({
    String? id,
    String? title,
    DataQuery? query,
    ChartSpec? chart,
    RefreshPolicy? refresh,
    WidgetDisplay? display,
    WidgetLayout? layout,
  }) => WidgetDefinition(
    id: id ?? this.id,
    type: type,
    title: title ?? this.title,
    query: query ?? this.query,
    chart: chart ?? this.chart,
    refresh: refresh ?? this.refresh,
    drilldown: drilldown,
    display: display ?? this.display,
    layout: layout ?? this.layout,
  );

  /// Sans id ni place : ce qu'un bloc du chat épingle.
  WidgetDefinition get unplaced => WidgetDefinition(
    type: type,
    title: title,
    query: query,
    chart: chart,
    refresh: refresh,
    drilldown: drilldown,
    display: display,
  );

  Json toJson() => compact({
    'id': id,
    'type': type.name,
    'title': title,
    'query': query.toJson(),
    'chart': chart?.toJson(),
    'refresh': refresh.toJson(),
    'drilldown': drilldown?.toJson(),
    'display': display.isEmpty ? null : display.toJson(),
    'layout': layout?.toJson(),
  });
}
