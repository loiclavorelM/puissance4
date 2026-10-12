import 'chart_rules.dart';
import 'dashboard.dart';
import 'widget_args.dart';
import 'widget_definition.dart';

/// Placement des widgets sur la grille de 12 colonnes.
abstract final class DashboardLayout {
  /// [widget] (nouveau ou déplacé) placé selon [request] : taille par
  /// défaut de son type si absente, première place libre si la position
  /// manque. Les widgets qu'il recouvre descendent juste en dessous.
  static Dashboard place(
    Dashboard dashboard,
    WidgetDefinition widget,
    LayoutRequest request,
    ChartRules rules,
  ) {
    final size = rules.defaultSize(widget.type);
    final w = (request.width ?? widget.layout?.w ?? size.w).clamp(
      1,
      Dashboard.columns,
    );
    final h = (request.height ?? widget.layout?.h ?? size.h).clamp(
      1,
      rules.maxHeight,
    );
    final others = Dashboard(
      version: dashboard.version,
      filters: dashboard.filters,
      widgets: [
        for (final other in dashboard.widgets)
          if (other.id != widget.id) other,
      ],
    );

    final WidgetLayout layout;
    final col = request.col?.clamp(0, Dashboard.columns - w);
    final row = request.row;
    if (col != null && row != null) {
      layout = WidgetLayout(x: col, y: row, w: w, h: h);
    } else if (col != null) {
      layout = _firstFree(
        others,
        (y) => [WidgetLayout(x: col, y: y, w: w, h: h)],
      );
    } else if (row != null) {
      layout = _firstFreeInRow(others, row, w, h);
    } else if (widget.layout != null &&
        request.width == null &&
        request.height == null) {
      layout = widget.layout!;
    } else if (widget.layout case final current?) {
      layout = WidgetLayout(
        x: current.x.clamp(0, Dashboard.columns - w),
        y: current.y,
        w: w,
        h: h,
      );
    } else {
      layout = others.firstFreeSlot(w, h);
    }

    final placed = widget.copyWith(layout: layout);
    final existing = dashboard.widgets.any((other) => other.id == widget.id);
    final widgets = existing
        ? [
            for (final other in dashboard.widgets)
              other.id == widget.id ? placed : other,
          ]
        : [...dashboard.widgets, placed];
    return dashboard.copyWith(widgets: _pushDown(widgets, placed.id));
  }

  /// [widget] remplace celui de même id, à la même place.
  static Dashboard replace(Dashboard dashboard, WidgetDefinition widget) =>
      dashboard.copyWith(
        widgets: [
          for (final other in dashboard.widgets)
            other.id == widget.id
                ? widget.copyWith(layout: other.layout)
                : other,
        ],
      );

  static WidgetLayout _firstFree(
    Dashboard dashboard,
    List<WidgetLayout> Function(int y) candidates,
  ) {
    final taken = [for (final w in dashboard.widgets) ?w.layout];
    for (var y = 0; ; y++) {
      for (final slot in candidates(y)) {
        if (!taken.any(slot.overlaps)) return slot;
      }
    }
  }

  static WidgetLayout _firstFreeInRow(
    Dashboard dashboard,
    int row,
    int w,
    int h,
  ) {
    final taken = [for (final widget in dashboard.widgets) ?widget.layout];
    for (var x = 0; x + w <= Dashboard.columns; x++) {
      final slot = WidgetLayout(x: x, y: row, w: w, h: h);
      if (!taken.any(slot.overlaps)) return slot;
    }
    return WidgetLayout(x: 0, y: row, w: w, h: h);
  }

  /// Fait descendre, de haut en bas, tout widget qui en recouvre un autre
  /// déjà posé ; [fixedId] ne bouge jamais.
  static List<WidgetDefinition> _pushDown(
    List<WidgetDefinition> widgets,
    String? fixedId,
  ) {
    final settled = <WidgetDefinition>[
      for (final widget in widgets)
        if (widget.id == fixedId || widget.layout == null) widget,
    ];
    final moving = [
      for (final widget in widgets)
        if (widget.id != fixedId && widget.layout != null) widget,
    ]..sort((a, b) => a.layout!.y.compareTo(b.layout!.y));
    for (final widget in moving) {
      var layout = widget.layout!;
      while (true) {
        final blocker = settled
            .map((other) => other.layout)
            .whereType<WidgetLayout>()
            .where(layout.overlaps)
            .firstOrNull;
        if (blocker == null) break;
        layout = WidgetLayout(
          x: layout.x,
          y: blocker.y + blocker.h,
          w: layout.w,
          h: layout.h,
        );
      }
      settled.add(widget.copyWith(layout: layout));
    }
    // Ordre d'origine conservé (dans un tableau de bord, chaque widget a un id).
    final byId = {for (final widget in settled) widget.id: widget};
    return [for (final widget in widgets) byId[widget.id]!];
  }
}
