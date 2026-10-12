import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:assistant_ui/assistant_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

/// Un golden par moteur de rendu, alimenté par les fixtures des contrats
/// (régénérer : flutter test --update-goldens).
void main() {
  final dashboard = Dashboard.fromJson(AssistantContracts.fixture('dashboard'));

  for (final widget in dashboard.widgets) {
    final name = widget.chart?.mark.name ?? widget.type.name;
    testWidgets('golden: ${widget.title} ($name)', (tester) async {
      final data = SourceData.fromJson(
        AssistantContracts.fixture('data.${widget.query.source}'),
      );
      await tester.pumpWidget(
        harness(
          RepaintBoundary(
            child: WidgetFrame(
              title: widget.title,
              child: WidgetRegistry.build(widget, data),
            ),
          ),
          size: Size(360, widget.type == WidgetType.kpi ? 130 : 280),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(RepaintBoundary).last,
        matchesGoldenFile('goldens/${widget.id}_$name.png'),
      );
    });
  }
}
