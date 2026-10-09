import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/dashboard_tokens.dart';
import 'chart_series.dart';

/// Ce que chaque moteur de rendu reçoit : les séries visibles et comment
/// les afficher. La répartition en séries est faite une fois, en amont.
class RenderInput {
  const RenderInput({
    required this.chart,
    required this.colors,
    required this.xLabel,
    required this.valueLabel,
    this.onSelect,
  });

  final PreparedChart chart;

  /// Une couleur par série de [chart].
  final List<Color> colors;
  final String Function(Object? x) xLabel;
  final String Function(num value) valueLabel;

  /// Clic sur une catégorie (drilldown, filtre commun).
  final ValueChanged<Object?>? onSelect;
}

/// Une étiquette d'axe sur [every] pour ne pas les chevaucher.
int _labelStep(int count, double width, double labelWidth) =>
    math.max(1, (count * labelWidth / math.max(width, 1)).ceil());

TextStyle _axisStyle(DashboardTokens tokens) =>
    TextStyle(fontSize: 10, color: tokens.textMuted);

FlGridData _grid(DashboardTokens tokens) => FlGridData(
  drawVerticalLine: false,
  getDrawingHorizontalLine: (_) => FlLine(color: tokens.grid, strokeWidth: 0.5),
);

class BarRenderer extends StatelessWidget {
  const BarRenderer({
    super.key,
    required this.input,
    required this.stack,
    required this.horizontal,
  });

  final RenderInput input;
  final bool stack;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final tokens = context.dashboardTokens;
    final chart = input.chart;
    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = horizontal
            ? constraints.maxHeight
            : constraints.maxWidth;
        final step = _labelStep(
          chart.categories.length,
          extent,
          horizontal ? 18 : 36,
        );
        final rodWidth = math.max(
          3.0,
          math.min(22.0, extent / math.max(chart.categories.length, 1) * 0.6) /
              (stack ? 1 : math.max(chart.series.length, 1)),
        );
        return BarChart(
          BarChartData(
            rotationQuarterTurns: horizontal ? 1 : 0,
            maxY: (stack ? chart.maxStacked : chart.maxValue) * 1.1 + 0.01,
            gridData: _grid(tokens),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) => SideTitleWidget(
                    meta: meta,
                    child: Text(
                      input.valueLabel(value),
                      style: _axisStyle(tokens),
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: horizontal ? 72 : 24,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i % step != 0 || i >= chart.categories.length) {
                      return const SizedBox.shrink();
                    }
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        input.xLabel(chart.categories[i]),
                        style: _axisStyle(tokens),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => tokens.surfaceAlt,
                getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                    BarTooltipItem(
                      '${input.xLabel(chart.categories[group.x])}\n'
                      '${input.valueLabel(stack ? rod.toY : rod.toY - rod.fromY)}',
                      TextStyle(color: tokens.text, fontSize: 11),
                    ),
              ),
              touchCallback: (event, response) {
                if (event is FlTapUpEvent && response?.spot != null) {
                  input.onSelect?.call(
                    chart.categories[response!.spot!.touchedBarGroupIndex],
                  );
                }
              },
            ),
            barGroups: [
              for (var i = 0; i < chart.categories.length; i++)
                stack ? _stacked(i, rodWidth) : _grouped(i, rodWidth),
            ],
          ),
        );
      },
    );
  }

  BarChartGroupData _stacked(int i, double width) {
    var from = 0.0;
    final items = <BarChartRodStackItem>[];
    for (var s = 0; s < input.chart.series.length; s++) {
      final value = input.chart.series[s].values[i] ?? 0;
      if (value == 0) continue;
      items.add(BarChartRodStackItem(from, from + value, input.colors[s]));
      from += value;
    }
    return BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: from,
          width: width,
          color: items.isEmpty ? Colors.transparent : null,
          rodStackItems: items,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  BarChartGroupData _grouped(int i, double width) => BarChartGroupData(
    x: i,
    barsSpace: 2,
    barRods: [
      for (var s = 0; s < input.chart.series.length; s++)
        BarChartRodData(
          toY: input.chart.series[s].values[i] ?? 0,
          width: width,
          color: input.colors[s],
          borderRadius: BorderRadius.circular(3),
        ),
    ],
  );
}

class LineRenderer extends StatelessWidget {
  const LineRenderer({
    super.key,
    required this.input,
    required this.area,
    required this.stack,
  });

  final RenderInput input;
  final bool area;
  final bool stack;

  @override
  Widget build(BuildContext context) {
    final tokens = context.dashboardTokens;
    final chart = input.chart;
    final cumulative = List.filled(chart.categories.length, 0.0);
    final bars = <LineChartBarData>[];
    for (var s = 0; s < chart.series.length; s++) {
      final spots = <FlSpot>[];
      for (var i = 0; i < chart.categories.length; i++) {
        final value = chart.series[s].values[i];
        if (value == null && !stack) continue;
        if (stack) cumulative[i] += value ?? 0;
        spots.add(FlSpot(i.toDouble(), stack ? cumulative[i] : value!));
      }
      bars.add(
        LineChartBarData(
          spots: spots,
          color: input.colors[s],
          barWidth: 2,
          isCurved: false,
          dotData: FlDotData(show: chart.categories.length <= 12),
          belowBarData: BarAreaData(
            show: area,
            color: input.colors[s].withValues(alpha: 0.25),
          ),
        ),
      );
    }
    final values = bars.expand((b) => b.spots).map((s) => s.y);
    final minY = values.isEmpty ? 0.0 : values.reduce(math.min);
    final maxY = values.isEmpty ? 1.0 : values.reduce(math.max);
    final margin = math.max((maxY - minY) * 0.1, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final step = _labelStep(
          chart.categories.length,
          constraints.maxWidth,
          44,
        );
        return LineChart(
          LineChartData(
            minY: area ? 0 : minY - margin,
            maxY: maxY + margin,
            gridData: _grid(tokens),
            borderData: FlBorderData(show: false),
            lineBarsData: bars,
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) => SideTitleWidget(
                    meta: meta,
                    child: Text(
                      input.valueLabel(value),
                      style: _axisStyle(tokens),
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 24,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (value != i ||
                        i % step != 0 ||
                        i >= chart.categories.length) {
                      return const SizedBox.shrink();
                    }
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        input.xLabel(chart.categories[i]),
                        style: _axisStyle(tokens),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => tokens.surfaceAlt,
                getTooltipItems: (spots) => [
                  for (final spot in spots)
                    LineTooltipItem(
                      '${input.xLabel(chart.categories[spot.x.toInt()])}\n'
                      '${input.valueLabel(spot.y)}',
                      TextStyle(color: tokens.text, fontSize: 11),
                    ),
                ],
              ),
              touchCallback: (event, response) {
                final spot = response?.lineBarSpots?.firstOrNull;
                if (event is FlTapUpEvent && spot != null) {
                  input.onSelect?.call(chart.categories[spot.x.toInt()]);
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class DonutRenderer extends StatelessWidget {
  const DonutRenderer({super.key, required this.input, required this.hidden});

  /// Une couleur par catégorie dans [RenderInput.colors].
  final RenderInput input;
  final Set<Object?> hidden;

  @override
  Widget build(BuildContext context) {
    final tokens = context.dashboardTokens;
    final chart = input.chart;
    final values = chart.series.isEmpty
        ? const <double?>[]
        : chart.series.first.values;
    final total = values.fold<double>(0, (a, v) => a + (v ?? 0));
    return LayoutBuilder(
      builder: (context, constraints) {
        final radius =
            math.min(constraints.maxWidth, constraints.maxHeight) / 2;
        return PieChart(
          PieChartData(
            centerSpaceRadius: radius * 0.45,
            sectionsSpace: 1,
            pieTouchData: PieTouchData(
              touchCallback: (event, response) {
                final index =
                    response?.touchedSection?.touchedSectionIndex ?? -1;
                if (event is FlTapUpEvent && index >= 0) {
                  input.onSelect?.call(chart.categories[index]);
                }
              },
            ),
            sections: [
              for (var i = 0; i < chart.categories.length; i++)
                if (!hidden.contains(chart.categories[i]))
                  PieChartSectionData(
                    value: values[i] ?? 0,
                    color: input.colors[i],
                    radius: radius * 0.5,
                    title: total == 0 || (values[i] ?? 0) / total < 0.08
                        ? ''
                        : '${((values[i] ?? 0) / total * 100).round()} %',
                    titleStyle: TextStyle(fontSize: 10, color: tokens.surface),
                  ),
            ],
          ),
        );
      },
    );
  }
}

/// Carte de chaleur maison : cases rondes ou carrées, comme le plateau.
class HeatmapRenderer extends StatefulWidget {
  const HeatmapRenderer({
    super.key,
    required this.heatmap,
    required this.color,
    required this.circles,
    required this.xLabel,
    required this.yLabel,
    required this.valueLabel,
  });

  final PreparedHeatmap heatmap;
  final Color color;
  final bool circles;
  final String Function(Object?) xLabel;
  final String Function(Object?) yLabel;
  final String Function(num) valueLabel;

  @override
  State<HeatmapRenderer> createState() => _HeatmapRendererState();
}

class _HeatmapRendererState extends State<HeatmapRenderer> {
  (int, int)? _selected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.dashboardTokens;
    final heatmap = widget.heatmap;
    final selected = _selected;
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cols = heatmap.xs.length, rows = heatmap.ys.length;
              final cell = math.min(
                constraints.maxWidth / cols,
                constraints.maxHeight / rows,
              );
              final size = Size(cell * cols, cell * rows);
              return Center(
                child: GestureDetector(
                  onTapDown: (details) {
                    final x = (details.localPosition.dx / cell).floor();
                    final y =
                        rows - 1 - (details.localPosition.dy / cell).floor();
                    setState(
                      () => _selected = (
                        x.clamp(0, cols - 1),
                        y.clamp(0, rows - 1),
                      ),
                    );
                  },
                  child: CustomPaint(
                    size: size,
                    painter: _HeatmapPainter(
                      heatmap: heatmap,
                      color: widget.color,
                      empty: tokens.surfaceAlt,
                      highlight: tokens.text,
                      circles: widget.circles,
                      selected: selected,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          selected == null
              ? ' '
              : '${widget.xLabel(heatmap.xs[selected.$1])} · '
                    '${widget.yLabel(heatmap.ys[selected.$2])} : '
                    '${widget.valueLabel(heatmap.values[selected.$2][selected.$1])}',
          style: TextStyle(fontSize: 11, color: tokens.textMuted),
        ),
      ],
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.heatmap,
    required this.color,
    required this.empty,
    required this.highlight,
    required this.circles,
    required this.selected,
  });

  final PreparedHeatmap heatmap;
  final Color color;
  final Color empty;
  final Color highlight;
  final bool circles;
  final (int, int)? selected;

  @override
  void paint(Canvas canvas, Size size) {
    final cols = heatmap.xs.length, rows = heatmap.ys.length;
    if (cols == 0 || rows == 0) return;
    final cell = size.width / cols;
    final max = heatmap.max;
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final value = heatmap.values[y][x];
        final rect = Rect.fromLTWH(
          x * cell,
          (rows - 1 - y) * cell,
          cell,
          cell,
        ).deflate(cell * 0.08);
        final paint = Paint()
          ..color = value == 0 || max == 0
              ? empty
              : Color.lerp(empty, color, 0.2 + 0.8 * value / max)!;
        if (circles) {
          canvas.drawOval(rect, paint);
        } else {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.12)),
            paint,
          );
        }
        if (selected == (x, y)) {
          final border = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = highlight;
          circles
              ? canvas.drawOval(rect, border)
              : canvas.drawRect(rect, border);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) =>
      old.heatmap != heatmap ||
      old.selected != selected ||
      old.color != color ||
      old.empty != empty;
}
