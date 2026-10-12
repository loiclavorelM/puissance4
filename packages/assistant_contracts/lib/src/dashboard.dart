import 'json.dart';
import 'source_catalog.dart';
import 'widget_definition.dart';

/// Filtres communs du tableau de bord. Les widgets dont un paramètre vaut
/// `$dashboard.xxx` les reprennent.
final class DashboardFilters {
  const DashboardFilters({
    this.range,
    this.mode,
    this.opponent,
    this.opponentLabel,
  });

  factory DashboardFilters.fromJson(Json json) => DashboardFilters(
    range: json.stringOrNull('range'),
    mode: json.stringOrNull('mode'),
    opponent: json.stringOrNull('opponent'),
    opponentLabel: json.stringOrNull('opponentLabel'),
  );

  static const none = DashboardFilters();

  final String? range;
  final String? mode;

  /// Référence `user:<uuid>` ou `bot:<uuid>`.
  final String? opponent;

  /// Nom de [opponent], résolu par le serveur à la lecture, jamais stocké.
  final String? opponentLabel;

  Object? valueOf(String param) => switch (param) {
    'range' => range,
    'mode' => mode,
    'opponent' => opponent,
    _ => null,
  };

  /// [params] avec les `$dashboard.xxx` remplacés par la valeur du filtre ;
  /// un filtre vide retire le paramètre (la source prend alors tout).
  Map<String, Object?> resolve(Map<String, Object?> params) {
    final resolved = <String, Object?>{};
    for (final MapEntry(:key, :value) in params.entries) {
      final reference = value is String && value.startsWith(dashboardPrefix)
          ? value.substring(dashboardPrefix.length)
          : null;
      final actual = reference == null ? value : valueOf(reference);
      if (actual != null) resolved[key] = actual;
    }
    return resolved;
  }

  DashboardFilters copyWith({
    String? Function()? range,
    String? Function()? mode,
    String? Function()? opponent,
    String? Function()? opponentLabel,
  }) => DashboardFilters(
    range: range == null ? this.range : range(),
    mode: mode == null ? this.mode : mode(),
    opponent: opponent == null ? this.opponent : opponent(),
    opponentLabel: opponentLabel == null ? this.opponentLabel : opponentLabel(),
  );

  /// Sans [opponentLabel], qui ne se stocke pas.
  Json toJson({bool withLabel = true}) => compact({
    'range': range,
    'mode': mode,
    'opponent': opponent,
    if (withLabel) 'opponentLabel': opponentLabel,
  });
}

/// Le tableau de bord d'un joueur, à une version donnée.
final class Dashboard {
  const Dashboard({
    required this.version,
    this.filters = DashboardFilters.none,
    this.widgets = const [],
  });

  factory Dashboard.fromJson(Json json) => Dashboard(
    version: json.intOrNull('version') ?? 0,
    filters: DashboardFilters.fromJson(
      json.objectOrNull('filters') ?? const {},
    ),
    widgets: [
      for (final widget in json.list('widgets'))
        WidgetDefinition.fromJson((widget! as Map).cast()),
    ],
  );

  static const empty = Dashboard(version: 0);

  static const columns = 12;

  final int version;
  final DashboardFilters filters;
  final List<WidgetDefinition> widgets;

  WidgetDefinition? widget(String id) =>
      widgets.where((w) => w.id == id).firstOrNull;

  /// Première place libre de taille [w]×[h], de haut en bas puis de gauche
  /// à droite.
  WidgetLayout firstFreeSlot(int w, int h, {String? ignoring}) {
    final taken = [
      for (final widget in widgets)
        if (widget.id != ignoring && widget.layout != null) widget.layout!,
    ];
    for (var y = 0; ; y++) {
      for (var x = 0; x + w <= columns; x++) {
        final slot = WidgetLayout(x: x, y: y, w: w, h: h);
        if (!taken.any(slot.overlaps)) return slot;
      }
    }
  }

  /// Widgets triés pour un affichage en pile (écran étroit) : par (y, x).
  List<WidgetDefinition> get stacked => [...widgets]
    ..sort((a, b) {
      final la = a.layout, lb = b.layout;
      if (la == null || lb == null) return 0;
      return la.y != lb.y ? la.y.compareTo(lb.y) : la.x.compareTo(lb.x);
    });

  Dashboard copyWith({
    int? version,
    DashboardFilters? filters,
    List<WidgetDefinition>? widgets,
  }) => Dashboard(
    version: version ?? this.version,
    filters: filters ?? this.filters,
    widgets: widgets ?? this.widgets,
  );

  Json toJson({bool withLabels = true}) => {
    'version': version,
    'filters': filters.toJson(withLabel: withLabels),
    'widgets': [for (final widget in widgets) widget.toJson()],
  };
}
