import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:assistant_ui/assistant_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

/// Les PDF générés vont dans ce dossier si la variable est définie (pour
/// les regarder), sinon nulle part.
final _outDir = Platform.environment['EXPORT_OUT'];

void main() {
  final recent = DataSet(
    fields: const [
      DataField('playedAt', FieldType.temporal),
      DataField('opponent', FieldType.category),
      DataField('result', FieldType.category),
      DataField('moveCount', FieldType.number),
      DataField('moveList', FieldType.category),
    ],
    rows: [
      for (var i = 0; i < 60; i++)
        [
          '2026-10-${(i % 28 + 1).toString().padLeft(2, '0')}T09:0${i % 10}:00Z',
          i.isEven ? 'Expert' : 'Kévin; "le roi"',
          ['win', 'loss', 'draw'][i % 3],
          7 + i % 20,
          '4 4 3 5 4',
        ],
    ],
  );
  const table = WidgetDefinition(
    type: WidgetType.table,
    title: 'Mes parties récentes',
    query: DataQuery('games.recent', {}),
    display: WidgetDisplay(columns: ['opponent', 'moveList', 'result']),
  );

  Future<DashboardLabels> labelsOf(WidgetTester tester) async {
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
    return labels;
  }

  WidgetExport export(
    DashboardLabels labels,
    WidgetDefinition definition,
    SourceData data,
  ) => WidgetExport(
    definition: definition,
    data: data,
    labels: labels,
    scope: '30 derniers jours',
    now: DateTime(2026, 10, 12, 11, 5),
  );

  testWidgets('the CSV keeps the chosen columns, translated and escaped', (
    tester,
  ) async {
    final labels = await labelsOf(tester);
    final csv = export(labels, table, recent).csv();
    // BOM UTF-8 : Excel reconnaît l'encodage (accents).
    expect(csv.take(3), [0xEF, 0xBB, 0xBF]);
    final lines = utf8.decode(csv).split('\r\n');
    expect(lines.first, 'Adversaire;Suite des coups;Résultat');
    expect(lines[1], 'Expert;4 4 3 5 4;Victoire');
    // Le séparateur et les guillemets d'une valeur sont échappés.
    expect(lines[2], '"Kévin; ""le roi""";4 4 3 5 4;Défaite');
    expect(lines, hasLength(recent.rows.length + 2)); // + en-tête, ligne vide
  });

  testWidgets('a KPI exports as label / value rows', (tester) async {
    final labels = await labelsOf(tester);
    const kpi = WidgetDefinition(
      type: WidgetType.kpi,
      title: 'Taux de victoire',
      query: DataQuery('games.summary', {}),
    );
    final text = utf8.decode(
      export(
        labels,
        kpi,
        const KpiData(value: 62, unit: '%', delta: 5, secondary: 40),
      ).csv(),
    );
    expect(text, contains('Taux de victoire;62 %'));
    expect(text, contains('Variation;+5'));
    expect(text, contains('Parties;40'));
  });

  testWidgets('every widget type exports a PDF', (tester) async {
    final labels = await labelsOf(tester);
    final cases = <String, WidgetExport>{
      'table': export(labels, table, recent),
      'kpi': export(
        labels,
        const WidgetDefinition(
          type: WidgetType.kpi,
          title: 'Taux de victoire',
          query: DataQuery('games.summary', {}),
        ),
        const KpiData(value: 62, unit: '%', delta: -3, secondary: 40),
      ),
    };
    // Graphique : l'image vient d'une capture, comme à l'écran.
    final captures = WidgetCaptures();
    final byDay = DataSet(
      fields: const [
        DataField('day', FieldType.temporal),
        DataField('result', FieldType.category),
        DataField('count', FieldType.number),
      ],
      rows: [
        for (var d = 1; d <= 6; d++)
          for (final r in ['win', 'loss'])
            ['2026-10-0$d', r, d + (r == 'win' ? 2 : 0)],
      ],
    );
    final chart =
        WidgetArgs(
              AssistantContracts.catalog,
              AssistantContracts.chartRules,
            )
            .build({
              'type': 'chart',
              'title': 'Parties par jour',
              'source': 'games.byDay',
            })
            .$1
            .copyWith(id: 'w_chart');
    await tester.pumpWidget(
      harness(
        captures.capture(
          'w_chart',
          ColoredBox(
            color: Colors.white,
            child: WidgetRegistry.build(chart, byDay),
          ),
        ),
        size: const Size(400, 260),
      ),
    );
    await tester.pumpAndSettle();
    cases['chart'] = WidgetExport(
      definition: chart,
      data: byDay,
      labels: labels,
      scope: '30 derniers jours',
      chartImage: await tester.runAsync<Uint8List?>(
        () => captures.png('w_chart'),
      ),
      now: DateTime(2026, 10, 12, 11, 5),
    );

    for (final MapEntry(key: name, value: export) in cases.entries) {
      final bytes = (await tester.runAsync(export.pdf))!;
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-', reason: name);
      if (_outDir case final dir?) {
        File('$dir/$name.pdf').writeAsBytesSync(bytes);
      }
    }
    expect(
      cases['table']!.fileName('pdf'),
      'puissance4-mes-parties-recentes-2026-10-12.pdf',
    );
  });
}
