import 'package:assistant_ui/assistant_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  testWidgets(
    'the captured widgets end up in a PDF, missing ones are skipped',
    (
      tester,
    ) async {
      final repository = MemoryDashboardRepository();
      final widgets = repository.current.widgets;
      final export = DashboardPdfExport();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              // Seul le premier widget est affiché.
              export.capture(
                widgets.first.id!,
                const SizedBox(
                  width: 200,
                  height: 100,
                  child: ColoredBox(color: Colors.indigo),
                ),
              ),
            ],
          ),
        ),
      );

      final bytes = await tester.runAsync(
        () => export.build(
          title: 'My dashboard',
          subtitle: 'Exported on Oct 12, 2026',
          widgets: widgets,
        ),
      );

      expect(String.fromCharCodes(bytes!.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(1000));
    },
  );

  testWidgets('the dashboard offers the PDF export once it has widgets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final dashboard = DashboardController(MemoryDashboardRepository());
    addTearDown(dashboard.dispose);
    await dashboard.reload();
    await tester.pumpWidget(
      harness(
        AssistantDashboardView(dashboard: dashboard, data: FixtureDataClient()),
      ),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.picture_as_pdf_outlined),
    );
    expect(button.onPressed, isNotNull);
  });
}
