import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:test/test.dart';

void main() {
  final catalog = AssistantContracts.catalog;
  final rules = AssistantContracts.chartRules;
  final args = WidgetArgs(catalog, rules);

  WidgetDefinition build(Json json) => args.build(json).$1;

  group('Given the embedded contracts', () {
    test('then every source field and param is declared', () {
      for (final source in catalog.sources.values) {
        for (final field in source.fields) {
          expect(catalog.fields, contains(field), reason: source.key);
        }
        for (final param in source.params) {
          expect(catalog.params, contains(param), reason: source.key);
        }
      }
    });

    test('then the tools accept every source and every source param', () {
      for (final tool in AssistantContracts.tools) {
        final properties = (tool.inputSchema['properties']! as Map)
            .cast<String, Object?>();
        if (properties['source'] case final Map source) {
          expect(
            (source['enum']! as List).toSet(),
            catalog.sources.keys.toSet(),
            reason: tool.name,
          );
          expect(properties.keys, containsAll(catalog.params.keys));
        }
      }
    });

    test('then every tool has the four annotations and a closed schema', () {
      expect(
        AssistantContracts.tools.map((t) => t.name).toSet(),
        hasLength(11),
      );
      for (final tool in AssistantContracts.tools) {
        expect(
          tool.annotations.keys,
          unorderedEquals([
            'readOnlyHint',
            'destructiveHint',
            'idempotentHint',
            'openWorldHint',
          ]),
          reason: tool.name,
        );
        expect(
          tool.inputSchema['additionalProperties'],
          isFalse,
          reason: tool.name,
        );
      }
    });

    test(
      'then the fixture dashboard is valid and its data matches the sources',
      () {
        final dashboard = Dashboard.fromJson(
          AssistantContracts.fixture('dashboard'),
        );
        for (final widget in dashboard.widgets) {
          expect(rules.validate(widget, catalog), isEmpty, reason: widget.id);
        }
        for (final source in catalog.sources.values) {
          final data = SourceData.fromJson(
            AssistantContracts.fixture('data.${source.key}'),
          );
          switch (data) {
            case KpiData():
              expect(source.kind, SourceKind.kpi);
            case DataSet(:final fields):
              // Tableau croisé : les champs suivent les paramètres (ici
              // ceux par défaut).
              expect(
                fields.map((f) => f.name),
                catalog.outputFields(source, const {}),
                reason: source.key,
              );
          }
        }
      },
    );
  });

  group('Given the games.pivot source', () {
    final pivot = catalog['games.pivot']!;

    test('when dimensions are chosen then they are the returned fields', () {
      expect(catalog.outputFields(pivot, const {}), ['mode', 'count']);
      expect(
        catalog.outputFields(pivot, {
          'groupBy': 'opponent',
          'splitBy': 'result',
          'measure': 'winRate',
        }),
        ['opponent', 'opponentKind', 'result', 'winRate', 'opponentRef'],
      );
    });

    test('when a chart is built then its axes follow the dimensions', () {
      final widget = build({
        'type': 'chart',
        'title': 'Taux de victoire par mois et par mode',
        'source': 'games.pivot',
        'groupBy': 'month',
        'splitBy': 'mode',
        'measure': 'winRate',
        'starter': 'me',
      });
      expect(widget.chart!.x!.field, 'month');
      expect(widget.chart!.y!.field, 'winRate');
      expect(widget.chart!.color!.field, 'mode');
      expect(rules.validate(widget, catalog), isEmpty);
    });

    test('when a dimension changes then the axes follow it', () {
      final base = build({
        'type': 'chart',
        'title': 'Parties',
        'source': 'games.pivot',
      });
      expect(base.chart!.x!.field, 'mode');
      final (updated, _) = args.update(base, {'groupBy': 'starter'});
      expect(updated.chart!.x!.field, 'starter');
      expect(rules.validate(updated, catalog), isEmpty);
    });

    test('when an axis is not a returned field then the error lists them', () {
      final widget = build({
        'type': 'chart',
        'title': 'Parties',
        'source': 'games.pivot',
        'groupBy': 'month',
        'x': 'opponent',
      });
      expect(
        rules.validate(widget, catalog),
        contains(contains('has no field opponent (fields: month, count)')),
      );
    });

    test('when both dimensions are the same then it is an error', () {
      expect(
        catalog.checkParams(pivot, {'groupBy': 'result', 'splitBy': 'result'}),
        ['splitBy must differ from groupBy.'],
      );
    });
  });

  group('Given table columns', () {
    Json recent([Json extra = const {}]) => {
      'type': 'table',
      'title': 'Mes parties',
      'source': 'games.recent',
      ...extra,
    };

    test('when columns are chosen then only they are kept, in order', () {
      final widget = build(
        recent({
          'columns': ['opponent', 'moveList', 'result'],
        }),
      );
      expect(widget.display.columns, ['opponent', 'moveList', 'result']);
      expect(rules.validate(widget, catalog), isEmpty);
      expect(
        args.toArgs(widget)['columns'],
        ['opponent', 'moveList', 'result'],
      );
    });

    test(
      'when a column does not exist then the error lists the valid ones',
      () {
        final errors = rules.validate(
          build(
            recent({
              'columns': ['opponent', 'gameId'],
            }),
          ),
          catalog,
        );
        expect(errors.single, startsWith('games.recent has no column gameId'));
        expect(errors.single, contains('moveList'));
      },
    );

    test('when a chart gets columns then it is an error', () {
      final widget = build({
        'type': 'chart',
        'title': 'Parties',
        'source': 'games.byDay',
        'columns': ['day'],
      });
      expect(
        rules.validate(widget, catalog),
        contains('Only a table widget has columns.'),
      );
    });

    test('when the source changes then the columns are dropped', () {
      final base = build(
        recent({
          'columns': ['opponent', 'result'],
        }),
      );
      final (updated, _) = args.update(base, {'source': 'results.byOpponent'});
      expect(updated.display.columns, isNull);
      expect(rules.validate(updated, catalog), isEmpty);
    });
  });

  group('Given ChartRules.validate', () {
    test('when a line has a category x then the error names the fix', () {
      final errors = rules.validate(
        build({
          'type': 'chart',
          'title': 'Mauvaise courbe',
          'source': 'results.byOpponent',
          'mark': 'line',
          'x': 'opponent',
        }),
        catalog,
      );
      expect(errors.join(), contains('needs a temporal x'));
    });

    test('when a kpi uses a rows source then a kpi source is suggested', () {
      final errors = rules.validate(
        build({'type': 'kpi', 'title': 'X', 'source': 'games.byDay'}),
        catalog,
      );
      expect(errors.single, contains('games.summary'));
    });

    test('when a param does not exist then the valid ones are listed', () {
      final errors = rules.validate(
        build({
          'type': 'chart',
          'title': 'X',
          'source': 'elo.history',
          'who': 'me',
        }),
        catalog,
      );
      expect(errors.single, contains('parameters: range'));
    });

    test('when a donut gets 7 categories then bars are suggested', () {
      final chart = build({
        'type': 'chart',
        'title': 'X',
        'source': 'moves.firstColumn',
        'mark': 'donut',
      }).chart!;
      final data =
          SourceData.fromJson(
                AssistantContracts.fixture('data.moves.firstColumn'),
              )
              as DataSet;
      expect(
        rules.validateData(chart, data).single,
        contains('horizontal bars'),
      );
    });
  });

  group('Given WidgetArgs', () {
    test(
      'when only type, title and source are given then the source defaults apply',
      () {
        final widget = build({
          'type': 'chart',
          'title': 'Parties par jour',
          'source': 'games.byDay',
        });
        expect(widget.chart!.toJson(), {
          'mark': 'bar',
          'x': {'field': 'day'},
          'y': {'field': 'count'},
          'color': {'field': 'result'},
          'stack': true,
        });
        expect(widget.query.params, {
          'range': r'$dashboard.range',
          'mode': r'$dashboard.mode',
          'opponent': r'$dashboard.opponent',
        });
        expect(rules.validate(widget, catalog), isEmpty);
      },
    );

    test('when lastGames is given then the dashboard range is not added', () {
      final widget = build({
        'type': 'chart',
        'title': 'Cases',
        'source': 'moves.byCell',
        'lastGames': 30,
        'who': 'me',
      });
      expect(widget.query.params, containsPair('lastGames', 30));
      expect(widget.query.params, isNot(contains('range')));
      expect(widget.display.cell, 'circle');
    });

    test('when the mark changes then the axes are recomputed', () {
      final base = build({
        'type': 'chart',
        'title': 'Parties par jour',
        'source': 'games.byDay',
      });
      final (updated, _) = args.update(base, {'mark': 'line'});
      expect(updated.chart!.mark, ChartMark.line);
      expect(updated.chart!.x!.field, 'day');
      expect(updated.chart!.color, isNull);
      expect(updated.chart!.stack, isFalse);
      expect(rules.validate(updated, catalog), isEmpty);
    });

    test(
      'when an explicit param is cleared then it follows the dashboard again',
      () {
        final base = build({
          'type': 'kpi',
          'title': 'Classé',
          'source': 'games.summary',
          'mode': 'classe',
        });
        final (updated, _) = args.update(base, {}, clear: ['mode']);
        expect(updated.query.params['mode'], r'$dashboard.mode');
      },
    );
  });

  group('Given a Dashboard', () {
    test('when resolving params then empty filters drop the param', () {
      const filters = DashboardFilters(range: 'last:7d');
      expect(
        filters.resolve({
          'range': r'$dashboard.range',
          'mode': r'$dashboard.mode',
          'lastGames': 10,
        }),
        {'range': 'last:7d', 'lastGames': 10},
      );
    });

    test('when looking for a free slot then widgets do not overlap', () {
      final dashboard = Dashboard.fromJson(
        AssistantContracts.fixture('dashboard'),
      );
      final slot = dashboard.firstFreeSlot(4, 2);
      for (final widget in dashboard.widgets) {
        expect(slot.overlaps(widget.layout!), isFalse, reason: widget.id);
      }
      expect(
        Dashboard.empty.firstFreeSlot(6, 4),
        const WidgetLayout(x: 0, y: 0, w: 6, h: 4),
      );
    });

    test('when serializing then it round-trips', () {
      final json = AssistantContracts.fixture('dashboard');
      expect(Dashboard.fromJson(json).toJson(), json);
    });
  });

  group('Given RelativeRange', () {
    final now = DateTime(2026, 10, 9, 15); // un vendredi

    test('then periods start where expected', () {
      expect(
        RelativeRange.tryParse('last:7d')!.start(now),
        DateTime(2026, 10, 3),
      );
      expect(
        RelativeRange.tryParse('this:week')!.start(now),
        DateTime(2026, 10, 5),
      );
      expect(
        RelativeRange.tryParse('this:month')!.start(now),
        DateTime(2026, 10),
      );
      expect(RelativeRange.all.start(now), isNull);
      expect(RelativeRange.tryParse('2026-10-01'), isNull);
    });

    test('then the previous period has the same length', () {
      final (start, end) = RelativeRange.tryParse('last:7d')!.previous(now)!;
      expect(end, DateTime(2026, 10, 3));
      expect(end.difference(start), now.difference(end));
    });
  });

  test('assistant events round-trip through JSON', () {
    final events = <AssistantEvent>[
      const StartedEvent('c1'),
      const ToolStatusEvent('add_widget', ToolState.done),
      const DashboardChangedEvent(3),
      const TextEvent('ok'),
      const DoneEvent(inputTokens: 10, outputTokens: 2),
      const ErrorEvent(AssistantErrorCode.rateLimited),
    ];
    for (final event in events) {
      expect(AssistantEvent.fromJson(event.toJson()).toJson(), event.toJson());
    }
  });
}
