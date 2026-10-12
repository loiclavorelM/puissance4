import 'dart:convert';

import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'assistant_test_helpers.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given the Dashboard endpoint', (sessionBuilder, endpoints) {
    late TestPlayer alice;
    late TestPlayer bob;

    const kpi = {
      'type': 'kpi',
      'title': 'Taux de victoire',
      'query': {'source': 'games.summary'},
    };

    Future<Map<String, dynamic>> pin(
      TestPlayer player,
      Map<String, Object?> widget,
    ) async =>
        jsonDecode(
              await endpoints.dashboard.saveWidget(
                player.session,
                jsonEncode(widget),
              ),
            )
            as Map<String, dynamic>;

    setUp(() async {
      alice = await createTestPlayer(sessionBuilder, 'alice');
      bob = await createTestPlayer(sessionBuilder, 'bob');
    });

    test(
      'when nothing was saved then the dashboard is empty at version 0',
      () async {
        expect(jsonDecode(await endpoints.dashboard.get(alice.session)), {
          'version': 0,
          'filters': {},
          'widgets': [],
        });
      },
    );

    test(
      'when pinning a block then it gets an id and the first free place',
      () async {
        await pin(alice, kpi);
        final dashboard = await pin(alice, kpi);
        expect(dashboard['version'], 2);
        final layouts = [
          for (final w in dashboard['widgets'] as List) w['layout'],
        ];
        expect(layouts, [
          {'x': 0, 'y': 0, 'w': 4, 'h': 2},
          {'x': 4, 'y': 0, 'w': 4, 'h': 2},
        ]);
        // Chaque joueur a son propre tableau de bord.
        expect(
          jsonDecode(await endpoints.dashboard.get(bob.session))['widgets'],
          isEmpty,
        );
      },
    );

    test('when editing a widget then it keeps its id and place', () async {
      final saved = await pin(alice, kpi);
      final widget = (saved['widgets'] as List).single as Map<String, dynamic>;
      final edited = await pin(alice, {...widget, 'title': 'Victoires'});
      expect((edited['widgets'] as List).single, {
        ...widget,
        'title': 'Victoires',
      });
    });

    test(
      'when a widget breaks the rules then it is refused with the reason',
      () async {
        await expectLater(
          pin(alice, {
            'type': 'chart',
            'title': 'X',
            'query': {'source': 'games.summary'},
            'chart': {'mark': 'bar'},
          }),
          throwsA(
            isA<AssistantException>()
                .having(
                  (e) => e.reason,
                  'reason',
                  EnumAssistantError.invalidWidget,
                )
                .having((e) => e.message, 'message', contains('single number')),
          ),
        );
      },
    );

    test(
      'when undoing then the previous version comes back, until there is none',
      () async {
        await pin(alice, kpi);
        final undone = jsonDecode(
          await endpoints.dashboard.undo(alice.session),
        );
        expect(undone['version'], 2);
        expect(undone['widgets'], isEmpty);
        await expectLater(
          endpoints.dashboard.undo(alice.session),
          throwsA(
            isA<AssistantException>().having(
              (e) => e.reason,
              'reason',
              EnumAssistantError.nothingToUndo,
            ),
          ),
        );
      },
    );

    test(
      'when setting filters then the opponent label is resolved, never stored',
      () async {
        final saved = jsonDecode(
          await endpoints.dashboard.setFilters(
            alice.session,
            jsonEncode({'range': 'last:7d', 'opponent': 'user:${bob.user.id}'}),
          ),
        );
        expect(saved['filters'], {
          'range': 'last:7d',
          'opponent': 'user:${bob.user.id}',
          'opponentLabel': 'bob',
        });
        final row = await UserDashboard.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) => t.userId.equals(alice.user.id),
        );
        expect(row!.definitionJson, isNot(contains('opponentLabel')));

        await expectLater(
          endpoints.dashboard.setFilters(
            alice.session,
            jsonEncode({'range': 'yesterday'}),
          ),
          throwsA(isA<AssistantException>()),
        );
      },
    );
  });
}
