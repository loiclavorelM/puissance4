import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:assistant_ui/assistant_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  final cells = Dashboard.fromJson(
    AssistantContracts.fixture('dashboard'),
  ).widgets.firstWhere((w) => w.query.source == 'moves.byCell');

  testWidgets('a question shows tool status, a pinnable block and the answer', (
    tester,
  ) async {
    final assistant = ScriptedAssistantClient([
      const StartedEvent('c1'),
      const ToolStatusEvent('propose_widget', ToolState.started),
      const ToolStatusEvent('propose_widget', ToolState.done),
      BlockEvent(cells.unplaced),
      const TextEvent('Voici **tes cases** préférées :\n- colonne 4'),
      const DoneEvent(),
    ]);
    final chat = ChatController(assistant);
    addTearDown(chat.dispose);
    final pinned = <WidgetDefinition>[];

    await tester.pumpWidget(
      harness(
        ChatPanel(
          controller: chat,
          data: FixtureDataClient(),
          filters: DashboardFilters.none,
          onPin: (definition) async => pinned.add(definition),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Montre où je joue');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(assistant.sent.single.text, 'Montre où je joue');
    expect(chat.conversationId, 'c1');
    expect(find.text('Prépare un graphique'), findsOneWidget);
    expect(find.text(cells.title), findsOneWidget);
    expect(find.textContaining('colonne 4'), findsOneWidget);

    await tester.tap(find.text('Épingler'));
    await tester.pumpAndSettle();
    expect(pinned.single.id, isNull);
    expect(pinned.single.query.source, 'moves.byCell');
    expect(find.text('Épingler'), findsNothing);
  });

  testWidgets('choosing a mention sends its reference with the text', (
    tester,
  ) async {
    final assistant = ScriptedAssistantClient([const DoneEvent()]);
    final chat = ChatController(assistant);
    addTearDown(chat.dispose);
    await tester.pumpWidget(
      harness(
        ChatPanel(
          controller: chat,
          data: FixtureDataClient(),
          filters: DashboardFilters.none,
          onPin: (_) async {},
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), "Ai-je battu @kev");
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ActionChip, 'Kevin42'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    final sent = assistant.sent.single;
    expect(sent.text, 'Ai-je battu Kevin42');
    expect(sent.mentions.single.ref, startsWith('user:'));
  });

  testWidgets('an error code is shown as a translated message', (tester) async {
    final chat = ChatController(
      ScriptedAssistantClient([
        const ErrorEvent(AssistantErrorCode.rateLimited),
      ]),
    );
    addTearDown(chat.dispose);
    await tester.pumpWidget(
      harness(
        ChatPanel(
          controller: chat,
          data: FixtureDataClient(),
          filters: DashboardFilters.none,
          onPin: (_) async {},
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Salut');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
    expect(
      find.text('Trop de demandes pour l\'instant. Réessaie plus tard.'),
      findsOneWidget,
    );
  });
}
