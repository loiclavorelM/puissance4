import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:assistant_ui/assistant_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  final data = DataSet(
    fields: const [
      DataField('playedAt', FieldType.temporal),
      DataField('opponent', FieldType.category),
      DataField('result', FieldType.category),
      DataField('moveCount', FieldType.number),
      DataField('moveList', FieldType.category),
    ],
    rows: [
      ['2026-10-12T09:00:00Z', 'Expert', 'win', 3, '4 4 4'],
    ],
  );

  testWidgets('a table shows only the chosen columns, in their order', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        DataTableView(
          data: data,
          columns: const ['opponent', 'moveList', 'result'],
        ),
      ),
    );

    expect(find.text('Adversaire'), findsOneWidget);
    expect(find.text('Suite des coups'), findsOneWidget);
    expect(find.text('Résultat'), findsOneWidget);
    expect(find.text('Date'), findsNothing);
    expect(find.text('Coups'), findsNothing);
    expect(find.text('4 4 4'), findsOneWidget);
    expect(find.text('Victoire'), findsOneWidget);
    double x(String text) => tester.getTopLeft(find.text(text)).dx;
    expect(x('Adversaire'), lessThan(x('Suite des coups')));
    expect(x('Suite des coups'), lessThan(x('Résultat')));
  });

  testWidgets('without a choice every readable column is shown', (
    tester,
  ) async {
    await tester.pumpWidget(harness(DataTableView(data: data)));
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Coups'), findsOneWidget);
  });
}
