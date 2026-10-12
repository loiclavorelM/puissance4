import 'dart:async';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:assistant_ui/assistant_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Données des fixtures des contrats, par source.
class FixtureDataClient implements DataSourceClient {
  final queries = <(String, Map<String, Object?>)>[];
  final changes = StreamController<void>.broadcast();

  @override
  Future<SourceData> query(String source, Map<String, Object?> params) async {
    queries.add((source, params));
    return SourceData.fromJson(AssistantContracts.fixture('data.$source'));
  }

  @override
  Stream<void> dataChanged() => changes.stream;

  @override
  Future<List<MentionSuggestion>> searchMentions(String text) async => [
    const MentionSuggestion(
      Mention(
        ref: 'user:00000000-0000-7000-8000-000000000001',
        label: 'Kevin42',
      ),
      isBot: false,
    ),
  ];
}

/// Tableau de bord en mémoire, partant de la fixture.
class MemoryDashboardRepository implements DashboardRepository {
  MemoryDashboardRepository([Dashboard? initial])
    : current =
          initial ??
          Dashboard.fromJson(AssistantContracts.fixture('dashboard'));

  Dashboard current;
  final saved = <WidgetDefinition>[];
  final changesController = StreamController<void>.broadcast();

  @override
  Future<Dashboard> load() async => current;

  @override
  Stream<void> changes() => changesController.stream;

  @override
  Future<Dashboard> saveWidget(WidgetDefinition definition) async {
    saved.add(definition);
    final placed = definition.id == null
        ? DashboardLayout.place(
            current,
            definition.copyWith(
              id: 'w_new${saved.length.toString().padLeft(5, '0')}',
            ),
            const LayoutRequest(),
            AssistantContracts.chartRules,
          )
        : DashboardLayout.replace(current, definition);
    return current = placed.copyWith(version: current.version + 1);
  }

  @override
  Future<Dashboard> removeWidget(String id) async => current = current.copyWith(
    version: current.version + 1,
    widgets: [
      for (final w in current.widgets)
        if (w.id != id) w,
    ],
  );

  @override
  Future<Dashboard?> undo() async => null;

  @override
  Future<Dashboard> setFilters(DashboardFilters filters) async => current =
      current.copyWith(version: current.version + 1, filters: filters);
}

/// Assistant qui rejoue une liste d'événements.
class ScriptedAssistantClient implements AssistantClient {
  ScriptedAssistantClient(this.events);

  final List<AssistantEvent> events;
  final sent = <ChatInput>[];

  @override
  Stream<AssistantEvent> send(String? conversationId, ChatInput input) {
    sent.add(input);
    return Stream.fromIterable(events);
  }
}

/// Monte [child] avec les localisations du package, en français.
Widget harness(Widget child, {Size size = const Size(420, 900)}) => MaterialApp(
  locale: const Locale('fr'),
  supportedLocales: AssistantUiLocalizations.supportedLocales,
  localizationsDelegates: const [
    AssistantUiLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(
    body: Center(
      child: SizedBox.fromSize(size: size, child: child),
    ),
  ),
);
