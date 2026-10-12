import 'dart:convert';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:assistant_ui/assistant_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  // Format long de games.pivot : une ligne par couple (mode, mois).
  final pivot = DataSet(
    fields: const [
      DataField('mode', FieldType.category),
      DataField('month', FieldType.category),
      DataField('winRate', FieldType.number),
    ],
    rows: [
      ['normal', '2026-10', 29],
      ['normal', '2026-09', 50],
      ['multi', '2026-10', 100],
    ],
  );
  const crossed = WidgetDefinition(
    type: WidgetType.table,
    title: 'Victoires par mode et par mois',
    query: DataQuery('games.pivot', {
      'groupBy': 'mode',
      'splitBy': 'month',
      'measure': 'winRate',
    }),
  );

  test('only a two-dimension pivot table without chosen columns crosses', () {
    expect(CrossTable.of(crossed, pivot), isNotNull);
    WidgetDefinition variant({
      WidgetType type = WidgetType.table,
      Map<String, Object?>? params,
      List<String>? columns,
    }) => WidgetDefinition(
      type: type,
      title: 't',
      query: DataQuery('games.pivot', params ?? crossed.query.params),
      display: WidgetDisplay(columns: columns),
    );
    expect(CrossTable.of(variant(type: WidgetType.chart), pivot), isNull);
    expect(
      CrossTable.of(
        variant(params: {'groupBy': 'mode', 'measure': 'winRate'}),
        pivot,
      ),
      isNull,
    );
    expect(CrossTable.of(variant(columns: ['mode']), pivot), isNull);
  });

  test('months read left to right and a missing pair stays empty', () {
    final table = CrossTable.of(crossed, pivot)!;
    expect(table.rowKeys, ['normal', 'multi']);
    expect(table.columnKeys, ['2026-09', '2026-10']);
    expect(table.cell('normal', '2026-09'), 50);
    expect(table.cell('multi', '2026-09'), isNull);
  });

  test('months go to the columns even when they are the groupBy', () {
    const monthFirst = WidgetDefinition(
      type: WidgetType.table,
      title: 't',
      query: DataQuery('games.pivot', {
        'groupBy': 'month',
        'splitBy': 'mode',
        'measure': 'winRate',
      }),
    );
    final table = CrossTable.of(monthFirst, pivot)!;
    expect(table.rowField, 'mode');
    expect(table.columnField, 'month');
    expect(table.columnKeys, ['2026-09', '2026-10']);
    expect(table.cell('multi', '2026-10'), 100);
  });

  testWidgets('the table shows one row per mode and one column per month', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        Builder(
          builder: (context) => WidgetRegistry.build(crossed, pivot),
        ),
      ),
    );
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('Multijoueur'), findsOneWidget);
    expect(find.text('2026-09'), findsOneWidget);
    expect(find.text('2026-10'), findsOneWidget);
    expect(find.text('–'), findsOneWidget); // multi en septembre
    double x(String text) => tester.getTopLeft(find.text(text)).dx;
    double y(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(x('2026-09'), lessThan(x('2026-10')));
    expect(y('Normal'), lessThan(y('Multijoueur')));
  });

  testWidgets('the CSV export is crossed like the screen', (tester) async {
    late DashboardLabels labels;
    await tester.pumpWidget(
      harness(
        Builder(
          builder: (context) {
            labels = DashboardLabels.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    final lines = utf8
        .decode(
          WidgetExport(
            definition: crossed,
            data: pivot,
            labels: labels,
            scope: 'Tout',
          ).csv(),
        )
        .split('\r\n');
    expect(lines[0], 'Mode;2026-09;2026-10');
    expect(lines[1], 'Normal;50;29');
    expect(lines[2], 'Multijoueur;;100');
  });
}
