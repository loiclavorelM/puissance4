import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:assistant_ui/assistant_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  late MemoryDashboardRepository repository;
  late FixtureDataClient data;
  late DashboardController dashboard;

  setUp(() async {
    repository = MemoryDashboardRepository();
    data = FixtureDataClient();
    dashboard = DashboardController(repository);
    await dashboard.reload();
  });

  tearDown(() => dashboard.dispose());

  for (final size in const [Size(400, 2400), Size(1200, 2000)]) {
    testWidgets(
      'the fixture dashboard renders every widget at ${size.width.toInt()} px',
      (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          harness(
            AssistantDashboardView(dashboard: dashboard, data: data),
            size: size,
          ),
        );
        await tester.pumpAndSettle();

        for (final widget in repository.current.widgets) {
          expect(find.text(widget.title), findsOneWidget, reason: widget.id);
        }
        expect(find.text('62 %'), findsOneWidget);
        // Les paramètres $dashboard.xxx sont résolus avant d'interroger.
        final summary = data.queries.firstWhere((q) => q.$1 == 'games.summary');
        expect(summary.$2, {'range': 'last:30d'});
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('removing a widget from its menu saves a new version', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      harness(AssistantDashboardView(dashboard: dashboard, data: data)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retirer'));
    await tester.pumpAndSettle();

    expect(repository.current.version, 8);
    expect(repository.current.widgets, hasLength(7));
  });

  testWidgets('the editor only offers valid choices and saves a valid widget', (
    tester,
  ) async {
    WidgetDefinition? saved;
    await tester.pumpWidget(
      harness(
        Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                ChartEditor.show(context, onSave: (w) => saved = w),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Sans titre, l'enregistrement est désactivé.
    final save = find.widgetWithText(FilledButton, 'Enregistrer');
    expect(tester.widget<FilledButton>(save).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'Mes parties');
    await tester.pumpAndSettle();
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(saved?.title, 'Mes parties');
    expect(saved?.chart?.mark, ChartMark.bar);
    expect(
      AssistantContracts.chartRules.validate(
        saved!,
        AssistantContracts.catalog,
      ),
      isEmpty,
    );
  });

  testWidgets('a failing widget shows a retry button', (tester) async {
    final failing = _FailingDataClient();
    await tester.pumpWidget(
      harness(
        LiveWidget(
          definition: repository.current.widgets.first,
          filters: DashboardFilters.none,
          client: failing,
          builder: (context, body) => body,
        ),
        size: const Size(300, 200),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Impossible de charger ces données.'), findsOneWidget);

    failing.fail = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('62 %'), findsOneWidget);
  });
}

class _FailingDataClient extends FixtureDataClient {
  bool fail = true;

  @override
  Future<SourceData> query(String source, Map<String, Object?> params) =>
      fail ? Future.error(StateError('down')) : super.query(source, params);
}
