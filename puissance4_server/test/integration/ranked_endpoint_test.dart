import 'dart:async';

import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:puissance4_server/src/bot/bot_seed.dart';
import 'package:puissance4_server/src/game/server_game_config.dart';
import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Given Ranked endpoint',
    // Rappels différés et streams utilisent leurs propres sessions.
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late LocalTimerScheduler scheduler;
      final subscriptions = <StreamSubscription<GameEvent>>[];

      Future<(TestSessionBuilder, User)> signedIn({int elo = 1000}) async {
        final session = sessionBuilder.build();
        final authUser = await const AuthUsers().create(session);
        final user = await User.db.insertRow(
          session,
          User(authUserId: authUser.id, username: 'alice', elo: elo),
        );
        return (
          sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              authUser.id.uuid,
              {},
            ),
          ),
          user,
        );
      }

      /// Suit la partie et renvoie la liste (vivante) de ses événements.
      List<GameEvent> watch(TestSessionBuilder who, UuidValue partieId) {
        final events = <GameEvent>[];
        subscriptions.add(
          endpoints.game.watchPartie(who, partieId).listen(events.add),
        );
        return events;
      }

      Future<GameEvent> waitFor(
        List<GameEvent> events,
        bool Function(GameEvent) test,
      ) async {
        final deadline = DateTime.now().add(const Duration(seconds: 5));
        while (DateTime.now().isBefore(deadline)) {
          for (final event in events) {
            if (test(event)) return event;
          }
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        throw TimeoutException(
          'Event not received: ${events.map((e) => e.type)}',
        );
      }

      /// Attend que ce soit au joueur de jouer (le bot a pu commencer).
      Future<GameEvent> myTurn(List<GameEvent> events) => waitFor(
        events,
        (e) =>
            e.moves != null &&
            (e.moves!.length.isEven ? EnumColor.rouge : EnumColor.jaune) ==
                events.first.yourColor,
      );

      setUp(() async {
        scheduler = LocalTimerScheduler();
        ServerGameConfig.scheduler = scheduler;
        ServerGameConfig.botMoveDelay = const Duration(milliseconds: 20);
        ServerGameConfig.turnTimeout = const Duration(seconds: 30);
        ServerGameConfig.disconnectGrace = const Duration(milliseconds: 300);
        await seedBots(sessionBuilder.build());
      });

      tearDown(() async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
        subscriptions.clear();
        scheduler.cancelAll();
        final session = sessionBuilder.build();
        await EloHistory.db.deleteWhere(
          session,
          where: (t) => t.id.notEquals(null),
        );
        await Partie.db.deleteWhere(
          session,
          where: (t) => t.id.notEquals(null),
        );
        await Player.db.deleteWhere(
          session,
          where: (t) => t.id.notEquals(null),
        );
        await User.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
        await Bot.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
      });

      test(
        'when a 1000 Elo player starts then they face the closest level (Moyen) in a classe partie',
        () async {
          final (alice, _) = await signedIn();

          final partieId = await endpoints.ranked.startRanked(alice);
          final events = watch(alice, partieId);
          final start = await waitFor(
            events,
            (e) => e.type == EnumGameEventType.gameStarted,
          );

          expect(start.typePartie, EnumType.classe);
          final bot = start.yourColor == EnumColor.rouge
              ? start.jaune!
              : start.rouge!;
          expect(bot.username, BotLevel.moyen.name);
          expect(bot.isBot, isTrue);
          await expectLater(
            endpoints.ranked.startRanked(alice),
            throwsA(
              isA<GameException>().having(
                (e) => e.reason,
                'reason',
                EnumGameError.alreadyInGame,
              ),
            ),
          );
        },
      );

      test('when the player moves then the server bot answers', () async {
        final (alice, _) = await signedIn();
        final partieId = await endpoints.ranked.startRanked(alice);
        final events = watch(alice, partieId);

        final before = await myTurn(events);
        final column = before.moves!.isEmpty ? 3 : before.moves!.last;
        await endpoints.game.playMove(alice, partieId, column);

        final answered = await waitFor(
          events,
          (e) => (e.moves?.length ?? 0) == before.moves!.length + 2,
        );
        expect(answered.moves![before.moves!.length], column);
      });

      test(
        'when the player abandons after a move then they lose Elo against the bot',
        () async {
          final (alice, user) = await signedIn();
          final partieId = await endpoints.ranked.startRanked(alice);
          final events = watch(alice, partieId);
          await myTurn(events);
          await endpoints.game.playMove(alice, partieId, 3);
          await waitFor(events, (e) => e.moves != null && e.moves!.contains(3));

          await endpoints.game.abandon(alice, partieId);

          final over = await waitFor(
            events,
            (e) => e.type == EnumGameEventType.gameOver,
          );
          expect(over.endReason, EnumGameEndReason.forfeit);
          expect(over.eloVariation, -12); // 1000 contre le bot Moyen (1100)
          final session = sessionBuilder.build();
          expect((await User.db.findById(session, user.id!))!.elo, 988);
          final history = await EloHistory.db.find(session);
          expect(history.single.newElo, 988);
        },
      );

      test(
        'when the player leaves before playing any move then the partie is cancelled without Elo change',
        () async {
          final (alice, user) = await signedIn();
          final partieId = await endpoints.ranked.startRanked(alice);

          await endpoints.game.abandon(alice, partieId);

          final session = sessionBuilder.build();
          final partie = await Partie.db.findById(session, partieId);
          expect(partie!.status, EnumStatut.abandoned);
          expect((await User.db.findById(session, user.id!))!.elo, 1000);
          expect(await EloHistory.db.find(session), isEmpty);
        },
      );

      test(
        'when the player closes the app on their turn then they still lose on time and lose Elo',
        () async {
          ServerGameConfig.turnTimeout = const Duration(seconds: 1);
          ServerGameConfig.disconnectGrace = const Duration(seconds: 10);
          final (alice, user) = await signedIn();
          final partieId = await endpoints.ranked.startRanked(alice);
          final events = watch(alice, partieId);
          final before = await myTurn(events);
          await endpoints.game.playMove(alice, partieId, 3);
          await waitFor(
            events,
            (e) => (e.moves?.length ?? 0) == before.moves!.length + 2,
          );

          await subscriptions.removeLast().cancel();

          final session = sessionBuilder.build();
          final deadline = DateTime.now().add(const Duration(seconds: 5));
          Partie? partie;
          while (DateTime.now().isBefore(deadline)) {
            partie = await Partie.db.findById(session, partieId);
            if (partie!.status != EnumStatut.inProgress) break;
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
          expect(partie!.status, EnumStatut.finished);
          expect(partie.endReason, EnumGameEndReason.timeout);
          expect((await User.db.findById(session, user.id!))!.elo, 988);
        },
      );

      test(
        'when the same player starts twice at once then only one partie is created',
        () async {
          final (alice, _) = await signedIn();

          final results = await Future.wait([
            for (var i = 0; i < 2; i++)
              endpoints.ranked
                  .startRanked(alice)
                  .then<Object>((id) => id, onError: (Object e) => e),
          ]);

          expect(results.whereType<UuidValue>(), hasLength(1));
          expect(
            results.whereType<GameException>().single.reason,
            EnumGameError.alreadyInGame,
          );
          expect(await Partie.db.find(sessionBuilder.build()), hasLength(1));
        },
      );
    },
  );
}
