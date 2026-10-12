import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:flutter/material.dart';

import '../charts/chart_series.dart';
import '../charts/renderers.dart';
import '../charts/series_style.dart';
import '../labels.dart';
import '../theme/dashboard_tokens.dart';
import 'cross_table.dart';

/// Clic sur une valeur d'un widget : `(champ, valeur)`.
typedef SelectCallback = void Function(String field, Object? value);

/// Corps d'un widget selon son type : un seul registre, utilisé par le
/// tableau de bord et par le chat.
abstract final class WidgetRegistry {
  static Widget build(
    WidgetDefinition definition,
    SourceData data, {
    SelectCallback? onSelect,
  }) => switch ((definition.type, data)) {
    (WidgetType.kpi, final KpiData kpi) => KpiCard(
      definition: definition,
      data: kpi,
    ),
    (WidgetType.table, final DataSet rows) => switch (CrossTable.of(
      definition,
      rows,
    )) {
      final cross? => CrossTableView(table: cross, onSelect: onSelect),
      null => DataTableView(
        data: rows,
        columns: definition.display.columns,
        onSelect: onSelect,
      ),
    },
    (WidgetType.chart, final DataSet rows) => ChartWidget(
      definition: definition,
      data: rows,
      onSelect: onSelect,
    ),
    _ => const SizedBox.shrink(),
  };

  /// Pas de donnée à montrer (aucune partie).
  static bool isEmpty(SourceData data) => switch (data) {
    KpiData(:final value) => value == null,
    DataSet(:final rows, :final fields) =>
      rows.isEmpty ||
          // Une source qui renvoie toujours ses cases (plateau, colonnes) mais
          // ne compte que des zéros n'a rien à montrer.
          fields
              .where((f) => f.type == FieldType.number)
              .every(
                (f) => rows.every(
                  (row) => (row[fields.indexOf(f)] as num? ?? 0) == 0,
                ),
              ),
  };
}

class KpiCard extends StatelessWidget {
  const KpiCard({super.key, required this.definition, required this.data});

  final WidgetDefinition definition;
  final KpiData data;

  @override
  Widget build(BuildContext context) {
    final tokens = context.dashboardTokens;
    final labels = DashboardLabels.of(context);
    final delta = data.delta;
    final secondary = data.secondary?.toInt();
    final caption = switch (definition.query.source) {
      'streaks' when secondary != null => labels.l10n.kpiBest(secondary),
      _ when secondary != null => labels.l10n.kpiGames(secondary),
      _ => null,
    };
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${data.value}${data.unit == null ? '' : ' ${data.unit}'}',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: tokens.resolve(definition.display.color),
                ),
              ),
              if (delta != null && delta != 0) ...[
                const SizedBox(width: 8),
                Icon(
                  delta > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: delta > 0 ? tokens.success : tokens.danger,
                ),
                Text(
                  labels.l10n.kpiDelta('${delta.abs()}'),
                  style: TextStyle(
                    fontSize: 12,
                    color: delta > 0 ? tokens.success : tokens.danger,
                  ),
                ),
              ],
            ],
          ),
          if (caption != null)
            Text(
              caption,
              style: TextStyle(fontSize: 12, color: tokens.textMuted),
            ),
        ],
      ),
    );
  }
}

class DataTableView extends StatelessWidget {
  const DataTableView({
    super.key,
    required this.data,
    this.columns,
    this.onSelect,
  });

  final DataSet data;

  /// Colonnes montrées, dans cet ordre (`null` : toutes).
  final List<String>? columns;
  final SelectCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.dashboardTokens;
    final labels = DashboardLabels.of(context);
    final catalog = AssistantContracts.catalog;
    // Colonnes choisies, dans leur ordre ; sinon toutes celles qui se lisent.
    final visible = columns != null
        ? [
            for (final name in columns!)
              if (data.indexOf(name) case final i when i >= 0) i,
          ]
        : [
            for (var i = 0; i < data.fields.length; i++)
              if (!(catalog.fields[data.fields[i].name]?.internal ?? false) &&
                  data.fields[i].name != 'opponentKind')
                i,
          ];
    final opponentRef = data.indexOf('opponentRef');
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 32,
          dataRowMinHeight: 30,
          dataRowMaxHeight: 34,
          columnSpacing: 16,
          horizontalMargin: 4,
          headingTextStyle: TextStyle(fontSize: 11, color: tokens.textMuted),
          dataTextStyle: TextStyle(fontSize: 12, color: tokens.text),
          columns: [
            for (final i in visible)
              DataColumn(
                label: Text(labels.field(data.fields[i].name)),
                numeric: data.fields[i].type == FieldType.number,
              ),
          ],
          rows: [
            for (final row in data.rows)
              DataRow(
                onSelectChanged: onSelect == null || opponentRef < 0
                    ? null
                    : (_) => onSelect!('opponentRef', row[opponentRef]),
                cells: [
                  for (final i in visible)
                    DataCell(Text(labels.value(data.fields[i].name, row[i]))),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Un [CrossTable] : première dimension en lignes, seconde en colonnes.
class CrossTableView extends StatelessWidget {
  const CrossTableView({super.key, required this.table, this.onSelect});

  final CrossTable table;
  final SelectCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.dashboardTokens;
    final labels = DashboardLabels.of(context);
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 32,
          dataRowMinHeight: 30,
          dataRowMaxHeight: 34,
          columnSpacing: 16,
          horizontalMargin: 4,
          headingTextStyle: TextStyle(fontSize: 11, color: tokens.textMuted),
          dataTextStyle: TextStyle(fontSize: 12, color: tokens.text),
          columns: [
            DataColumn(label: Text(labels.field(table.rowField))),
            for (final column in table.columnKeys)
              DataColumn(
                label: Text(labels.value(table.columnField, column)),
                numeric: true,
              ),
          ],
          rows: [
            for (final row in table.rowKeys)
              DataRow(
                onSelectChanged:
                    onSelect == null || !table.rowRefs.containsKey(row)
                    ? null
                    : (_) => onSelect!('opponentRef', table.rowRefs[row]),
                cells: [
                  DataCell(
                    Text(
                      labels.value(table.rowField, row),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  for (final column in table.columnKeys)
                    DataCell(
                      Text(
                        labels.value(
                          table.measureField,
                          table.cell(row, column),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Un seul widget de graphique : répartit les lignes en séries selon la
/// spec, puis aiguille vers le moteur de rendu de `mark`. Les séries
/// masquées (légende) sont un état temporaire : la spec ne change pas.
class ChartWidget extends StatefulWidget {
  const ChartWidget({
    super.key,
    required this.definition,
    required this.data,
    this.onSelect,
  });

  final WidgetDefinition definition;
  final DataSet data;
  final SelectCallback? onSelect;

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  final _hidden = <Object?>{};

  void _toggle(Object? key) => setState(() {
    if (!_hidden.remove(key)) _hidden.add(key);
  });

  @override
  Widget build(BuildContext context) {
    final spec = widget.definition.chart!;
    final tokens = context.dashboardTokens;
    final labels = DashboardLabels.of(context);
    final xField = spec.x?.field;
    String valueLabel(num v) =>
        v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);

    if (spec.mark == ChartMark.heatmap) {
      return HeatmapRenderer(
        heatmap: PreparedHeatmap.prepare(widget.data, spec),
        color: tokens.resolve(widget.definition.display.color),
        circles: widget.definition.display.cell == 'circle',
        xLabel: (x) => '${labels.field(xField!)} ${labels.value(xField, x)}',
        yLabel: (y) =>
            '${labels.field(spec.y!.field)} ${labels.value(spec.y!.field, y)}',
        valueLabel: valueLabel,
      );
    }

    final prepared = PreparedChart.prepare(widget.data, spec);
    void select(Object? x) {
      if (xField != null) widget.onSelect?.call(xField, x);
    }

    if (spec.mark == ChartMark.donut) {
      final colors = [
        for (var i = 0; i < prepared.categories.length; i++)
          seriesColor(
            tokens,
            colorField: xField,
            key: prepared.categories[i],
            index: i,
            display: const WidgetDisplay(),
          ),
      ];
      return Row(
        children: [
          Expanded(
            child: DonutRenderer(
              hidden: _hidden,
              input: RenderInput(
                chart: prepared,
                colors: colors,
                xLabel: (x) => labels.value(xField, x),
                valueLabel: valueLabel,
                onSelect: select,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 96,
            child: SingleChildScrollView(
              child: ChartLegend(
                entries: [
                  for (var i = 0; i < prepared.categories.length; i++)
                    (
                      key: prepared.categories[i],
                      label: labels.value(xField, prepared.categories[i]),
                      color: colors[i],
                    ),
                ],
                hidden: _hidden,
                onToggle: _toggle,
              ),
            ),
          ),
        ],
      );
    }

    final colorField = spec.color?.field;
    final allColors = [
      for (var i = 0; i < prepared.series.length; i++)
        seriesColor(
          tokens,
          colorField: colorField,
          key: prepared.series[i].key,
          index: i,
          display: widget.definition.display,
        ),
    ];
    final visible = [
      for (var i = 0; i < prepared.series.length; i++)
        if (!_hidden.contains(prepared.series[i].key)) i,
    ];
    final input = RenderInput(
      chart: PreparedChart(prepared.categories, [
        for (final i in visible) prepared.series[i],
      ]),
      colors: [for (final i in visible) allColors[i]],
      xLabel: (x) => labels.value(xField, x),
      valueLabel: valueLabel,
      onSelect: select,
    );
    final renderer = switch (spec.mark) {
      ChartMark.line => LineRenderer(input: input, area: false, stack: false),
      ChartMark.area => LineRenderer(
        input: input,
        area: true,
        stack: spec.stack,
      ),
      _ => BarRenderer(
        input: input,
        stack: spec.stack,
        horizontal: spec.horizontal,
      ),
    };
    return Column(
      children: [
        Expanded(child: renderer),
        if (colorField != null && prepared.series.length > 1) ...[
          const SizedBox(height: 6),
          ChartLegend(
            entries: [
              for (var i = 0; i < prepared.series.length; i++)
                (
                  key: prepared.series[i].key,
                  label: labels.value(colorField, prepared.series[i].key),
                  color: allColors[i],
                ),
            ],
            hidden: _hidden,
            onToggle: _toggle,
          ),
        ],
      ],
    );
  }
}
