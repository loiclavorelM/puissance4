import 'dart:convert';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:serverpod/serverpod.dart';

import '../game/server_game.dart';
import '../generated/protocol.dart';
import 'dashboard/dashboard_store.dart';
import 'sources/opponents.dart';

/// Le tableau de bord de l'assistant côté app (E16) : lecture, panneau
/// « Modifier », « Épingler » un bloc du chat, annulation, filtres. Les
/// écritures de l'assistant passent par les outils MCP ; les deux aboutissent
/// à [DashboardStore], donc aux mêmes versions annulables.
///
/// Entrées et sorties en JSON des contrats (`dashboard.schema.json`,
/// `widget-definition.schema.json`). Les nouvelles versions sont signalées
/// par `LiveEvent(dashboardChanged)`.
class DashboardEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static final _catalog = AssistantContracts.catalog;
  static final _rules = AssistantContracts.chartRules;

  Future<String> get(Session session) async {
    final user = await ServerGame.requireUser(session);
    return _encode(await DashboardStore.load(session, user));
  }

  /// Ajoute [definitionJson] (sans id : « Épingler ») ou remplace le widget
  /// de même id (panneau « Modifier »). Lève [AssistantException]
  /// (`invalidWidget`, `notFound`).
  Future<String> saveWidget(Session session, String definitionJson) async {
    final user = await ServerGame.requireUser(session);
    final definition = _decodeWidget(definitionJson);
    final errors = _rules.validate(definition, _catalog);
    if (errors.isNotEmpty) {
      throw AssistantException(
        reason: EnumAssistantError.invalidWidget,
        message: errors.join(' '),
      );
    }
    final saved = await DashboardStore.mutate(
      session,
      user,
      EnumDashboardAuthor.player,
      (dashboard) {
        final id = definition.id;
        if (id == null) {
          return DashboardLayout.place(
            dashboard,
            definition.copyWith(id: DashboardStore.newWidgetId()),
            _request(definition.layout),
            _rules,
          );
        }
        final current = dashboard.widget(id);
        if (current == null) {
          throw AssistantException(reason: EnumAssistantError.notFound);
        }
        return definition.layout == null || definition.layout == current.layout
            ? DashboardLayout.replace(dashboard, definition)
            : DashboardLayout.place(
                dashboard,
                definition,
                _request(definition.layout),
                _rules,
              );
      },
    );
    return _encode(saved);
  }

  Future<String> removeWidget(Session session, String id) async {
    final user = await ServerGame.requireUser(session);
    final saved = await DashboardStore.mutate(
      session,
      user,
      EnumDashboardAuthor.player,
      (dashboard) {
        if (dashboard.widget(id) == null) {
          throw AssistantException(reason: EnumAssistantError.notFound);
        }
        return dashboard.copyWith(
          widgets: [
            for (final w in dashboard.widgets)
              if (w.id != id) w,
          ],
        );
      },
    );
    return _encode(saved);
  }

  /// Revient à la version précédente. Lève [AssistantException]
  /// (`nothingToUndo`).
  Future<String> undo(Session session) async {
    final user = await ServerGame.requireUser(session);
    final restored = await DashboardStore.undo(session, user);
    if (restored == null) {
      throw AssistantException(reason: EnumAssistantError.nothingToUndo);
    }
    return _encode(restored);
  }

  /// Remplace les filtres par [filtersJson] (`range`, `mode`, `opponent` en
  /// référence `user:`/`bot:` ; absent = pas de filtre).
  Future<String> setFilters(Session session, String filtersJson) async {
    final user = await ServerGame.requireUser(session);
    final DashboardFilters filters;
    try {
      filters = DashboardFilters.fromJson(
        (jsonDecode(filtersJson) as Map).cast(),
      );
    } on Object {
      throw AssistantException(
        reason: EnumAssistantError.invalidQuery,
        message: 'filtersJson must be a dashboard filters object.',
      );
    }
    final errors = [
      if (filters.range case final range?
          when RelativeRange.tryParse(range) == null)
        'Unknown range $range.',
      if (filters.mode case final mode?
          when !_catalog.params['mode']!.values.contains(mode))
        'Unknown mode $mode.',
      if (filters.opponent case final opponent?
          when await Opponents.label(session, opponent) == null)
        'Unknown opponent $opponent.',
    ];
    if (errors.isNotEmpty) {
      throw AssistantException(
        reason: EnumAssistantError.invalidQuery,
        message: errors.join(' '),
      );
    }
    final saved = await DashboardStore.mutate(
      session,
      user,
      EnumDashboardAuthor.player,
      (dashboard) => dashboard.copyWith(
        filters: DashboardFilters(
          range: filters.range,
          mode: filters.mode,
          opponent: filters.opponent,
        ),
      ),
    );
    return _encode(saved);
  }

  static WidgetDefinition _decodeWidget(String json) {
    try {
      return WidgetDefinition.fromJson((jsonDecode(json) as Map).cast());
    } on Object {
      throw AssistantException(
        reason: EnumAssistantError.invalidWidget,
        message: 'definitionJson must be a widget definition.',
      );
    }
  }

  static LayoutRequest _request(WidgetLayout? layout) => layout == null
      ? const LayoutRequest()
      : LayoutRequest(
          col: layout.x,
          row: layout.y,
          width: layout.w,
          height: layout.h,
        );

  static String _encode(Dashboard dashboard) => jsonEncode(dashboard.toJson());
}
