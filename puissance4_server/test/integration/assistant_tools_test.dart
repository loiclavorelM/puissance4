import 'dart:convert';

import 'package:mcp_dart/mcp_dart.dart';
import 'package:puissance4_server/src/assistant/mcp/assistant_mcp.dart';
import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'assistant_test_helpers.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given the assistant MCP tools', (sessionBuilder, endpoints) {
    late TestPlayer alice;
    late McpClient mcp;
    late Partie lastGame;

    /// Appelle [tool] par le vrai protocole MCP (client en mémoire).
    Future<CallToolResult> call(
      String tool, [
      Map<String, dynamic> args = const {},
    ]) => mcp.callTool(CallToolRequest(name: tool, arguments: args));

    Map<String, dynamic> json(CallToolResult result) =>
        jsonDecode((result.content.single as TextContent).text)
            as Map<String, dynamic>;

    Future<Map<String, dynamic>> ok(
      String tool, [
      Map<String, dynamic> args = const {},
    ]) async {
      final result = await call(tool, args);
      expect(result.isError, isFalse, reason: json(result).toString());
      return json(result);
    }

    Future<String> error(String tool, Map<String, dynamic> args) async {
      final result = await call(tool, args);
      expect(result.isError, isTrue);
      return (result.content.single as TextContent).text;
    }

    setUp(() async {
      alice = await createTestPlayer(sessionBuilder, 'alice');
      final kevin = await createTestPlayer(sessionBuilder, 'Kevin42');
      for (final winner in [EnumOutcome.rouge, EnumOutcome.jaune]) {
        lastGame = await createFinishedPartie(
          sessionBuilder,
          me: alice.player,
          opponent: kevin.player,
          type: EnumType.multi,
          winner: winner,
        );
      }
      final session = alice.session.build();
      mcp = await connectInMemory(
        buildAssistantMcpServer(alice.user, <R>(work) => work(session)),
      );
    });

    tearDown(() => mcp.close());

    test(
      'when listing tools then the 11 contract tools come without any identity param',
      () async {
        final tools = (await mcp.listTools()).tools;
        expect(tools, hasLength(11));
        for (final tool in tools) {
          final properties =
              tool.inputSchema.toJson()['properties'] as Map? ?? {};
          expect(properties.keys, isNot(contains('userId')), reason: tool.name);
        }
        final remove = tools.firstWhere((t) => t.name == 'remove_widget');
        expect(remove.annotations?.destructiveHint, isTrue);
        final query = tools.firstWhere((t) => t.name == 'query_data');
        expect(query.annotations?.readOnlyHint, isTrue);
        expect(query.annotations?.destructiveHint, isFalse);
      },
    );

    test(
      'when adding a widget with defaults then it is placed and stats come back',
      () async {
        final added = await ok('add_widget', {
          'type': 'chart',
          'title': 'Parties par jour',
          'source': 'games.byDay',
        });
        expect(added['id'], matches(RegExp(r'^w_[a-z0-9]{8}$')));
        expect(added['version'], 1);
        expect(added['data'], {
          'rows': 2,
          'distinct': {'day': 1, 'result': 2, 'count': 1},
        });
        final result = await call('get_dashboard');
        final widget = (json(result)['widgets'] as List).single as Map;
        expect(widget, containsPair('col', 0));
        expect(widget, containsPair('width', 6));
        expect(widget, containsPair('mark', 'bar'));
        expect(widget, containsPair('stack', true));
        // L'orchestrateur reçoit la nouvelle version en méta-données.
        final meta = (await call('add_widget', {
          'type': 'kpi',
          'title': 'Taux',
          'source': 'games.summary',
        })).meta;
        expect(meta?[dashboardVersionMeta], 2);
      },
    );

    test(
      'when a chart breaks the rules then the error says what to fix and nothing is saved',
      () async {
        final message = await error('add_widget', {
          'type': 'chart',
          'title': 'Mauvaise courbe',
          'source': 'results.byOpponent',
          'mark': 'line',
        });
        expect(message, contains('needs a temporal x'));
        expect(json(await call('get_dashboard'))['version'], 0);
      },
    );

    test(
      'when an argument is not in the schema then mcp_dart rejects it',
      () async {
        final message = await error('query_data', {
          'source': 'games.summary',
          'opponentId': 1,
        });
        expect(message, contains('opponentId'));
      },
    );

    test(
      'when proposing a widget then it comes back as a block, not saved',
      () async {
        final result = await call('propose_widget', {
          'type': 'chart',
          'title': 'Où je joue',
          'source': 'moves.byCell',
          'lastGames': 30,
        });
        expect(result.isError, isFalse);
        final block = result.meta?[blockMeta] as Map;
        expect(block['chart'], containsPair('mark', 'heatmap'));
        expect(block['display'], {'cell': 'circle'});
        expect(json(await call('get_dashboard'))['widgets'], isEmpty);
      },
    );

    test(
      'when updating, arranging, removing and undoing then each makes a version',
      () async {
        final id = (await ok('add_widget', {
          'type': 'chart',
          'title': 'Parties',
          'source': 'games.byDay',
        }))['id'];
        final kpi = (await ok('add_widget', {
          'type': 'kpi',
          'title': 'Taux',
          'source': 'games.summary',
        }))['id'];

        await ok('update_widget', {
          'id': id,
          'mark': 'line',
          'title': 'Courbe',
        });
        var widgets = json(await call('get_dashboard'))['widgets'] as List;
        final line = widgets.firstWhere((w) => w['id'] == id) as Map;
        expect(line['mark'], 'line');
        expect(line, isNot(contains('color')));

        // Le KPI en haut à gauche : la courbe descend en dessous.
        await ok('arrange_widgets', {
          'widgets': [
            {'id': kpi, 'col': 0, 'row': 0, 'width': 12},
          ],
        });
        widgets = json(await call('get_dashboard'))['widgets'] as List;
        expect(widgets.first['id'], kpi);
        expect((widgets.last as Map)['row'], 2);

        await ok('remove_widget', {'id': id});
        expect(json(await call('get_dashboard'))['widgets'], hasLength(1));
        final undone = await ok('undo_dashboard');
        expect(undone['version'], 6);
        expect(json(await call('get_dashboard'))['widgets'], hasLength(2));

        expect(
          await error('remove_widget', {'id': 'w_missing0'}),
          contains(kpi),
        );
      },
    );

    test(
      'when filtering on an opponent name then the dashboard stores a reference',
      () async {
        await ok('set_dashboard_filters', {
          'opponent': 'kevin42',
          'mode': 'multi',
        });
        final filters = json(await call('get_dashboard'))['filters'];
        expect(filters, {'mode': 'multi', 'opponent': 'Kevin42'});
        final stored =
            jsonDecode(await endpoints.dashboard.get(alice.session)) as Map;
        expect(stored['filters']['opponent'], startsWith('user:'));

        expect(
          await error('set_dashboard_filters', {'opponent': 'Nobody'}),
          contains('No opponent matches'),
        );
        await ok('set_dashboard_filters', {'opponent': 'all'});
        expect(json(await call('get_dashboard'))['filters'], {'mode': 'multi'});
      },
    );

    test('when querying data then rows come back for the LLM', () async {
      final data = await ok('query_data', {
        'source': 'results.byOpponent',
        'range': 'this:month',
      });
      expect(data['rows'], hasLength(2));
      final summary = await ok('query_data', {'source': 'games.summary'});
      expect(summary['value'], 50);
    });

    test(
      'when analyzing a game then turning points refer to the player moves',
      () async {
        final analysis = await ok('analyze_game', {
          'gameId': lastGame.id!.uuid,
        });
        expect(analysis['result'], 'loss');
        for (final point in analysis['turningPoints'] as List) {
          expect(
            (point['moveNumber'] as int).isOdd,
            isTrue,
          ); // Rouge : coups 1, 3…
        }
        expect(
          await error('analyze_game', {'gameId': 'nope'}),
          contains('games.recent'),
        );
      },
    );
  });
}
