import 'dart:convert';

import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:serverpod_offline_sync_server/serverpod_offline_sync_server.dart'
    show OfflineSyncSpace;
import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given the assistant data sources', (
    sessionBuilder,
    endpoints,
  ) {
    late TestSessionBuilder alice;
    late User aliceUser;
    late Player alicePlayer;
    late Player bobPlayer;
    late Player botPlayer;
    late Bot bot;

    Future<(TestSessionBuilder, User, Player)> player(String username) async {
      final session = sessionBuilder.build();
      final authUser = await const AuthUsers().create(session);
      final user = await User.db.insertRow(
        session,
        User(authUserId: authUser.id, username: username),
      );
      final player = await Player.db.insertRow(
        session,
        Player(userId: user.id),
      );
      return (
        sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            authUser.id.uuid,
            {},
          ),
        ),
        user,
        player,
      );
    }

    Future<Partie> partie(
      Player opponent, {
      required EnumType type,
      required EnumOutcome? winner,
      List<int> moves = const [3, 4, 3, 4, 3, 4, 3],
      int daysAgo = 0,
      EnumStatut status = EnumStatut.finished,
    }) => Partie.db.insertRow(
      sessionBuilder.build(),
      Partie(
        typePartie: type,
        playerRougeId: alicePlayer.id!,
        playerJauneId: opponent.id!,
        winner: winner,
        status: status,
        moves: moves,
        createdAt: DateTime.now().toUtc().subtract(Duration(days: daysAgo)),
      ),
    );

    Future<Object?> query(
      String source, [
      Map<String, Object?> params = const {},
    ]) async => jsonDecode(
      await endpoints.data.query(alice, source, jsonEncode(params)),
    );

    setUp(() async {
      (alice, aliceUser, alicePlayer) = await player('alice');
      (_, _, bobPlayer) = await player('Kevin42');
      final session = sessionBuilder.build();
      bot = await Bot.db.insertRow(
        session,
        // Comme `seedBots` : le niveau Expert, sous son identifiant fixe.
        Bot(
          id: UuidValue.withValidation(BotLevel.expert.id),
          botName: BotLevel.expert.name,
          elo: BotLevel.expert.elo,
          pathModel: '',
          description: '',
        ),
      );
      botPlayer = await Player.db.insertRow(session, Player(botId: bot.id));

      // Multi contre Kevin42 : une victoire, une défaite (il y a 10 jours).
      await partie(bobPlayer, type: EnumType.multi, winner: EnumOutcome.rouge);
      await partie(
        bobPlayer,
        type: EnumType.multi,
        winner: EnumOutcome.jaune,
        moves: const [0, 3, 1, 3, 6, 3, 6, 3],
        daysAgo: 10,
      );
      // Classé contre Expert : une victoire, avec son Elo.
      final ranked = await partie(
        botPlayer,
        type: EnumType.classe,
        winner: EnumOutcome.rouge,
      );
      await EloHistory.db.insertRow(
        session,
        EloHistory(
          userId: aliceUser.id!,
          partieId: ranked.id!,
          eloVariation: 16,
          newElo: 1016,
        ),
      );
      // Abandonnée : jamais comptée.
      await partie(
        bobPlayer,
        type: EnumType.multi,
        winner: null,
        status: EnumStatut.abandoned,
      );
      // Normal, synchronisée dans l'espace personnel d'alice : un nul.
      final space = await OfflineSyncSpace.db.insertRow(
        session,
        OfflineSyncSpace(uuidSpaceId: aliceUser.authUserId!),
      );
      await OfflineMatchResult.db.insertRow(
        session,
        OfflineMatchResult(
          spaceId: space.id,
          status: EnumStatut.finished,
          result: EnumMatchResult.draw,
          botId: bot.id!,
          botName: 'Expert',
          playedAs: EnumColor.jaune,
          moves: const [2, 3],
          playedAt: DateTime.now().toUtc(),
        ),
      );
    });

    test(
      'when summarizing then every finished game of every mode counts',
      () async {
        expect(await query('games.summary'), {
          'kind': 'kpi',
          'value': 50,
          'unit': '%',
          'secondary': 4,
        });
      },
    );

    test('when filtering by mode then only that mode is read', () async {
      final normal = await query('games.summary', {'mode': 'normal'}) as Map;
      expect(normal['secondary'], 1);
      expect(normal['value'], 0);
    });

    test(
      'when filtering by an opponent name then only their games count',
      () async {
        final kevin =
            await query('games.summary', {'opponent': 'kevin42'}) as Map;
        expect(kevin['secondary'], 2);
        final expert =
            await query('games.summary', {'opponent': 'Expert'}) as Map;
        expect(expert['secondary'], 2);
      },
    );

    test(
      'when a range is set then the delta compares with the previous period',
      () async {
        final week = await query('games.summary', {'range': 'last:7d'}) as Map;
        expect(week['secondary'], 3);
        // 3 parties, 2 victoires (67 %) contre 0 % la semaine d'avant.
        expect(week['value'], 67);
        expect(week['delta'], 67);
      },
    );

    test(
      'when grouping by opponent then names, kinds and refs come back',
      () async {
        final data = await query('results.byOpponent') as Map;
        final rows = (data['rows'] as List).cast<List>();
        expect(
          rows.map((r) => (r[0], r[1], r[2], r[3])),
          unorderedEquals([
            ('Kevin42', 'human', 'win', 1),
            ('Kevin42', 'human', 'loss', 1),
            ('Expert', 'bot', 'win', 1),
            ('Expert', 'bot', 'draw', 1),
          ]),
        );
        expect(
          rows.firstWhere((r) => r[0] == 'Kevin42')[4],
          startsWith('user:'),
        );
        expect(rows.firstWhere((r) => r[0] == 'Expert')[4], 'bot:${bot.id}');
      },
    );

    test('when listing recent games then the moves played come back', () async {
      final data = await query('games.recent') as Map;
      final names = [
        for (final f in data['fields'] as List) (f as Map)['name'],
      ];
      final rows = (data['rows'] as List).cast<List>();
      // La partie Normal : [2, 3] en index 0, soit colonnes 3 puis 4.
      final normal = rows.firstWhere(
        (r) => r[names.indexOf('mode')] == 'normal',
      );
      expect(normal[names.indexOf('moveList')], '3 4');
      expect(normal[names.indexOf('moveCount')], 2);
    });

    test(
      'when pivoting by opponent and result then each pair is counted',
      () async {
        final data =
            await query('games.pivot', {
                  'groupBy': 'opponent',
                  'splitBy': 'result',
                })
                as Map;
        expect(
          (data['fields'] as List).map((f) => (f as Map)['name']),
          ['opponent', 'opponentKind', 'result', 'count', 'opponentRef'],
        );
        final rows = (data['rows'] as List).cast<List>();
        expect(
          rows.map((r) => (r[0], r[1], r[2], r[3])),
          unorderedEquals([
            ('Kevin42', 'human', 'win', 1),
            ('Kevin42', 'human', 'loss', 1),
            ('Expert', 'bot', 'win', 1),
            ('Expert', 'bot', 'draw', 1),
          ]),
        );
        expect(rows.firstWhere((r) => r[0] == 'Expert')[4], 'bot:${bot.id}');
      },
    );

    test(
      'when pivoting the win rate by mode when I start then Normal drops out',
      () async {
        // alice commence (rouge) en Multi et en Classé, pas en Normal.
        final data =
            await query('games.pivot', {
                  'groupBy': 'mode',
                  'measure': 'winRate',
                  'starter': 'me',
                })
                as Map;
        expect(data['rows'], [
          ['multi', 50],
          ['classe', 100],
        ]);
      },
    );

    test(
      'when counting cells then the board has 42 cells and only my discs',
      () async {
        final data = await query('moves.byCell', {'who': 'me'}) as Map;
        final rows = (data['rows'] as List).cast<List>();
        expect(rows, hasLength(42));
        int at(String row, String column) =>
            rows.firstWhere((r) => r[0] == row && r[1] == column)[2] as int;
        // Colonne 4 (index 3) : alice-rouge y a 4 pions dans 2 victoires,
        // et alice-jaune (Normal) 1 pion en bas.
        expect(at('1', '4'), 3);
        expect(at('1', '5'), 0);
      },
    );

    test('when keeping only winning lines then only won games count', () async {
      final data = await query('moves.byCell', {'only': 'winning'}) as Map;
      final total = (data['rows'] as List).fold<int>(
        0,
        (sum, row) => sum + ((row as List)[2] as int),
      );
      expect(total, 8); // deux victoires, 4 pions alignés chacune
    });

    test('when reading the Elo history then ranked days come back', () async {
      final data = await query('elo.history') as Map;
      expect((data['rows'] as List).single, [isA<String>(), 1016]);
    });

    test(
      'when reading streaks then the current and best streaks come back',
      () async {
        // Du plus récent au plus ancien : nul (Normal), victoires, défaite.
        final data = await query('streaks') as Map;
        expect(data['value'], 0);
        expect(data['secondary'], 2);
      },
    );

    test(
      'when a parameter is unknown then the error lists the valid ones',
      () async {
        await expectLater(
          query('elo.history', {'who': 'me'}),
          throwsA(
            isA<AssistantException>()
                .having(
                  (e) => e.reason,
                  'reason',
                  EnumAssistantError.invalidQuery,
                )
                .having(
                  (e) => e.message,
                  'message',
                  contains('parameters: range'),
                ),
          ),
        );
      },
    );

    test('when an opponent is unknown then the error says so', () async {
      await expectLater(
        query('games.summary', {'opponent': 'Nobody'}),
        throwsA(isA<AssistantException>()),
      );
    });

    test(
      'when searching mentions then matching opponents come back once',
      () async {
        final mentions =
            jsonDecode(
                  await endpoints.data.searchMentions(alice, 'kev'),
                )
                as List;
        expect(mentions, [
          {'ref': startsWith('user:'), 'label': 'Kevin42', 'kind': 'human'},
        ]);
      },
    );
  });
}
