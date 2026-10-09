import 'dart:math' as math;

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:flutter/material.dart';

/// Les widgets d'un tableau de bord sur la grille de 12 colonnes. Sous
/// [stackBelow] de large (téléphone), ils s'empilent dans l'ordre (y, x),
/// chacun sur toute la largeur.
class DashboardGrid extends StatelessWidget {
  const DashboardGrid({
    super.key,
    required this.dashboard,
    required this.itemBuilder,
    this.rowHeight = 64,
    this.gap = 10,
    this.stackBelow = 600,
  });

  final Dashboard dashboard;
  final Widget Function(BuildContext context, WidgetDefinition widget)
  itemBuilder;

  /// Hauteur d'une rangée de grille.
  final double rowHeight;
  final double gap;
  final double stackBelow;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      if (width < stackBelow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final widget in dashboard.stacked)
              Padding(
                padding: EdgeInsets.only(bottom: gap),
                child: SizedBox(
                  height: _stackedHeight(widget),
                  child: itemBuilder(context, widget),
                ),
              ),
          ],
        );
      }
      final column = (width + gap) / Dashboard.columns;
      final bottom = dashboard.widgets.fold<int>(
        0,
        (max, w) => math.max(max, (w.layout?.y ?? 0) + (w.layout?.h ?? 0)),
      );
      return SizedBox(
        height: bottom * (rowHeight + gap),
        child: Stack(
          children: [
            for (final widget in dashboard.widgets)
              if (widget.layout case final layout?)
                Positioned(
                  key: ValueKey(widget.id),
                  left: layout.x * column,
                  top: layout.y * (rowHeight + gap),
                  width: layout.w * column - gap,
                  height: layout.h * (rowHeight + gap) - gap,
                  child: itemBuilder(context, widget),
                ),
          ],
        ),
      );
    },
  );

  /// En pile, une hauteur lisible quelle que soit la largeur d'origine.
  double _stackedHeight(WidgetDefinition widget) {
    final h = widget.layout?.h ?? 4;
    return switch (widget.type) {
      WidgetType.kpi => 120,
      WidgetType.table => math.max(h, 4) * rowHeight,
      WidgetType.chart => math.max(h, 4) * rowHeight * 0.9 + 40,
    };
  }
}
