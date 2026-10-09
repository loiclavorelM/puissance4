import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

import '../../generated/protocol.dart';
import '../dashboard/dashboard_store.dart';
import '../sources/data_sources.dart';
import '../sources/game_record_repository.dart';
import '../sources/opponents.dart';
import 'tool_context.dart';

/// Les outils de l'assistant (`contracts/tools/*.json`), en fonctions pures
/// `(contexte, arguments) → résultat` : le serveur MCP ne fait que les
/// exposer, et ils se testent sans MCP ni LLM.
///
/// Les arguments arrivent déjà validés contre `inputSchema` par mcp_dart ;
/// ici on vérifie ce que le schéma ne peut pas dire (règles des graphiques,
/// données, ids).
abstract final class AssistantTools {
  static final _catalog = AssistantContracts.catalog;
  static final _rules = AssistantContracts.chartRules;
  static final _args = WidgetArgs(_catalog, _rules);

  /// Lignes rendues au LLM par `query_data` au plus.
  static const maxRowsForLlm = 20;

  static final Map<String, ToolHandler> handlers = {
    'list_data_sources': _listDataSources,
    'get_dashboard': _getDashboard,
    'add_widget': _addWidget,
    'propose_widget': _proposeWidget,
    'update_widget': _updateWidget,
    'remove_widget': _removeWidget,
    'arrange_widgets': _arrangeWidgets,
    'undo_dashboard': _undoDashboard,
    'set_dashboard_filters': _setDashboardFilters,
    'query_data': _queryData,
    'analyze_game': _analyzeGame,
  };

  /// Exécute [name] ; une [ToolError] devient une erreur actionnable.
  static Future<ToolOutcome> call(
    ToolContext context,
    String name,
    Json args,
  ) async {
    final handler = handlers[name];
    if (handler == null) return ToolOutcome.error('Unknown tool $name.');
    try {
      return await handler(context, args);
    } on ToolError catch (e) {
      return ToolOutcome.error(e.message);
    } on SourceQueryException catch (e) {
      return ToolOutcome.error(e.message);
    }
  }

  static Future<ToolOutcome> _listDataSources(
    ToolContext context,
    Json args,
  ) async => ToolOutcome(_catalog.describe());

  static Future<ToolOutcome> _getDashboard(
    ToolContext context,
    Json args,
  ) async {
    final dashboard = await DashboardStore.load(context.session, context.user);
    return ToolOutcome(_describe(dashboard));
  }

  /// Le tableau de bord vu comme le LLM écrit les widgets : arguments à
  /// plat, id et place.
  static Json _describe(Dashboard dashboard) => {
    'version': dashboard.version,
    'filters': compact({
      'range': dashboard.filters.range,
      'mode': dashboard.filters.mode,
      'opponent': dashboard.filters.opponentLabel,
    }),
    'widgets': [
      for (final widget in dashboard.stacked)
        {
          'id': widget.id,
          ..._args.toArgs(widget),
          if (widget.layout case final layout?) ...{
            'col': layout.x,
            'row': layout.y,
            'width': layout.w,
            'height': layout.h,
          },
        },
    ],
  };

  static Future<ToolOutcome> _addWidget(ToolContext context, Json args) async {
    final (definition, layout) = _args.build(args);
    final current = await DashboardStore.load(context.session, context.user);
    final stats = await _check(context, definition, current.filters);
    final id = DashboardStore.newWidgetId();
    final saved = await DashboardStore.mutate(
      context.session,
      context.user,
      EnumDashboardAuthor.assistant,
      (dashboard) => DashboardLayout.place(
        dashboard,
        definition.copyWith(id: id),
        layout,
        _rules,
      ),
    );
    return ToolOutcome({
      'id': id,
      'version': saved.version,
      'data': stats,
    }, dashboardVersion: saved.version);
  }

  static Future<ToolOutcome> _proposeWidget(
    ToolContext context,
    Json args,
  ) async {
    final (definition, _) = _args.build(args);
    final current = await DashboardStore.load(context.session, context.user);
    final stats = await _check(context, definition, current.filters);
    return ToolOutcome({'shown': true, 'data': stats}, block: definition);
  }

  static Future<ToolOutcome> _updateWidget(
    ToolContext context,
    Json args,
  ) async {
    final id = args.string('id');
    final current = await DashboardStore.load(context.session, context.user);
    final base = current.widget(id) ?? (throw _unknownWidget(id, current));
    final (definition, layout) = _args.update(
      base,
      args,
      clear: args.list('clear').cast<String>(),
    );
    final stats = await _check(context, definition, current.filters);
    final saved = await DashboardStore.mutate(
      context.session,
      context.user,
      EnumDashboardAuthor.assistant,
      (dashboard) => layout.isEmpty
          ? DashboardLayout.replace(dashboard, definition)
          : DashboardLayout.place(dashboard, definition, layout, _rules),
    );
    return ToolOutcome({
      'version': saved.version,
      'data': stats,
    }, dashboardVersion: saved.version);
  }

  static Future<ToolOutcome> _removeWidget(
    ToolContext context,
    Json args,
  ) async {
    final id = args.string('id');
    final saved = await DashboardStore.mutate(
      context.session,
      context.user,
      EnumDashboardAuthor.assistant,
      (dashboard) {
        if (dashboard.widget(id) == null) throw _unknownWidget(id, dashboard);
        return dashboard.copyWith(
          widgets: [
            for (final w in dashboard.widgets)
              if (w.id != id) w,
          ],
        );
      },
    );
    return ToolOutcome({
      'version': saved.version,
    }, dashboardVersion: saved.version);
  }

  static Future<ToolOutcome> _arrangeWidgets(
    ToolContext context,
    Json args,
  ) async {
    final moves = [
      for (final item in args.list('widgets'))
        (item! as Map).cast<String, Object?>(),
    ];
    final saved = await DashboardStore.mutate(
      context.session,
      context.user,
      EnumDashboardAuthor.assistant,
      (dashboard) {
        var next = dashboard;
        for (final move in moves) {
          final id = move.string('id');
          final widget = next.widget(id) ?? (throw _unknownWidget(id, next));
          next = DashboardLayout.place(
            next,
            widget,
            LayoutRequest(
              col: move.intOrNull('col'),
              row: move.intOrNull('row'),
              width: move.intOrNull('width'),
              height: move.intOrNull('height'),
            ),
            _rules,
          );
        }
        return next;
      },
    );
    return ToolOutcome({
      'version': saved.version,
    }, dashboardVersion: saved.version);
  }

  static Future<ToolOutcome> _undoDashboard(
    ToolContext context,
    Json args,
  ) async {
    final restored = await DashboardStore.undo(context.session, context.user);
    if (restored == null) throw const ToolError('Nothing to undo.');
    return ToolOutcome({
      'version': restored.version,
    }, dashboardVersion: restored.version);
  }

  static Future<ToolOutcome> _setDashboardFilters(
    ToolContext context,
    Json args,
  ) async {
    String? Function()? opponent;
    if (args.stringOrNull('opponent') case final value?) {
      if (value == 'all') {
        opponent = () => null;
      } else {
        final ref = await Opponents.resolve(context.session, value);
        if (ref == null) {
          throw ToolError(
            'No opponent matches "$value": use a name from results.byOpponent.',
          );
        }
        opponent = () => ref;
      }
    }
    String? Function()? clearable(String key) =>
        switch (args.stringOrNull(key)) {
          null => null,
          'all' => () => null,
          final value => () => value,
        };
    final saved = await DashboardStore.mutate(
      context.session,
      context.user,
      EnumDashboardAuthor.assistant,
      (dashboard) => dashboard.copyWith(
        filters: dashboard.filters.copyWith(
          range: clearable('range'),
          mode: clearable('mode'),
          opponent: opponent,
        ),
      ),
    );
    return ToolOutcome({
      'version': saved.version,
    }, dashboardVersion: saved.version);
  }

  static Future<ToolOutcome> _queryData(ToolContext context, Json args) async {
    final params = {
      for (final MapEntry(:key, :value) in args.entries)
        if (key != 'source') key: value,
    };
    final data = await DataSources.query(
      context.session,
      context.user,
      args.string('source'),
      params,
    );
    return ToolOutcome(switch (data) {
      KpiData() => data.toJson(),
      DataSet() => data.truncate(maxRowsForLlm).toJson(),
    });
  }

  static Future<ToolOutcome> _analyzeGame(
    ToolContext context,
    Json args,
  ) async {
    final gameId = args.string('gameId');
    final games = await GameRecordRepository.load(
      context.session,
      context.user,
    );
    final game =
        games.where((g) => g.id.uuid == gameId).firstOrNull ??
        (throw const ToolError(
          'Unknown gameId: take one from the gameId field of games.recent.',
        ));

    final turningPoints = <({int index, int loss, MoveAnalysis analysis})>[];
    for (var i = 0; i < game.moves.length; i++) {
      if (MoveAnalysis.playerOf(i) != game.myDisc) continue;
      final analysis = MoveAnalysis.of(game.moves, i);
      if (analysis.isBest) continue;
      final loss =
          analysis.scores[analysis.recommended]! -
          analysis.scores[analysis.played]!;
      turningPoints.add((index: i, loss: loss, analysis: analysis));
    }
    turningPoints.sort((a, b) => b.loss.compareTo(a.loss));
    final kept = turningPoints.take(3).toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    return ToolOutcome({
      'result': game.result.name,
      'moves': game.moves.length,
      'turningPoints': [
        for (final point in kept)
          {
            'moveNumber': point.index + 1,
            'played': point.analysis.played + 1,
            'recommended': point.analysis.recommended + 1,
            'playedVerdict': point.analysis.playedVerdict.name,
            'recommendedVerdict': point.analysis.recommendedVerdict.name,
          },
      ],
      if (kept.isEmpty) 'note': 'No move differs from the engine choice.',
    });
  }

  /// Valide [definition] (règles, puis données) et renvoie les statistiques
  /// de ses données, jamais les données elles-mêmes.
  static Future<Json> _check(
    ToolContext context,
    WidgetDefinition definition,
    DashboardFilters filters,
  ) async {
    final errors = _rules.validate(definition, _catalog);
    if (errors.isNotEmpty) throw ToolError(errors.join(' '));
    final data = await DataSources.query(
      context.session,
      context.user,
      definition.query.source,
      filters.resolve(definition.query.params),
    );
    switch (data) {
      case KpiData(:final value):
        return {'hasValue': value != null};
      case DataSet():
        if (definition.chart case final chart?) {
          final dataErrors = _rules.validateData(chart, data);
          if (dataErrors.isNotEmpty) throw ToolError(dataErrors.join(' '));
        }
        return {
          'rows': data.rows.length,
          'distinct': {
            for (final field in data.fields)
              if (!_catalog.fields[field.name]!.internal)
                field.name: data.column(field.name).toSet().length,
          },
        };
    }
  }

  static ToolError _unknownWidget(String id, Dashboard dashboard) => ToolError(
    'No widget $id. Widgets: '
    '${dashboard.widgets.map((w) => '${w.id} (${w.title})').join(', ')}.',
  );
}
