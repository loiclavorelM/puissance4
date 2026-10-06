import 'dart:async';

import 'package:puissance4_server/src/friends/friend_code.dart';
import 'package:puissance4_server/src/friends/friends_config.dart';
import 'package:puissance4_server/src/friends/presence_store.dart';
import 'package:puissance4_server/src/friends/shake_matcher.dart';
import 'package:puissance4_server/src/game/server_game.dart';
import 'package:puissance4_server/src/game/server_game_config.dart';
import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:puissance4_server/src/multiplayer/multiplayer_config.dart';
import 'package:puissance4_server/src/multiplayer/room_store.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Collecte les événements d'un stream Multi pour les attendre dans l'ordre.
class _Events {
  _Events(Stream<GameEvent> stream) {
    _subscription = stream.listen(all.add, onError: errors.add);
  }

  late final StreamSubscription<GameEvent> _subscription;
  final all = <GameEvent>[];
  final errors = <Object>[];

  Future<GameEvent> next(EnumGameEventType type) =>
      _eventually(() => all.where((e) => e.type == type).firstOrNull);

  Future<Object> nextError() => _eventually(() => errors.firstOrNull);

  Future<void> cancel() => _subscription.cancel();
}

/// Attend que [read] renvoie une valeur non nulle (5 s au plus).
Future<T> _eventually<T extends Object>(FutureOr<T?> Function() read) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    final value = await read();
    if (value != null) return value;
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  throw TimeoutException('Condition never reached');
}

void main() {
  withServerpod(
    'Given friends presence and challenges (E15 P2)',
    // Streams et nettoyages ont leurs propres sessions : il faut des
    // écritures réellement commitées.
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      final openStreams = <_Events>[];
      final liveStreams = <StreamSubscription<LiveEvent>>[];

      Future<(TestSessionBuilder, User)> player(String username) async {
        final session = sessionBuilder.build();
        final authUser = await const AuthUsers().create(session);
        final user = await User.db.insertRow(
          session,
          User(authUserId: authUser.id, username: username),
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

      Future<void> befriend(User a, User b) => Friendship.db.insertRow(
        sessionBuilder.build(),
        Friendship(
          requesterId: a.id!,
          addresseeId: b.id!,
          pairKey: friendPairKey(a.id!, b.id!),
          status: EnumFriendshipStatus.accepted,
        ),
      );

      _Events listen(Stream<GameEvent> stream) {
        final events = _Events(stream);
        openStreams.add(events);
        return events;
      }

      Future<FriendshipDto> friendSeenBy(TestSessionBuilder who) async =>
          (await endpoints.friends.getOverview(who)).friends.single;

      setUp(() {
        MultiplayerConfig.rooms = InMemoryRoomStore();
        FriendsConfig.presence = InMemoryPresenceStore();
        FriendsConfig.shakes = InMemoryShakeMatcher();
        FriendsConfig.shakeWindow = const Duration(milliseconds: 300);
        ServerGameConfig.scheduler = LocalTimerScheduler();
      });

      tearDown(() async {
        for (final events in openStreams) {
          await events.cancel();
        }
        openStreams.clear();
        for (final live in liveStreams) {
          await live.cancel();
        }
        liveStreams.clear();
        (ServerGameConfig.scheduler as LocalTimerScheduler).cancelAll();
        ServerGame.releaseStreams();
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
        // Supprime en cascade les User et leurs Friendship.
        await AuthUser.db.deleteWhere(
          session,
          where: (t) => t.id.notEquals(null),
        );
        await Bot.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
      });

      /// Partie terminée entre [rouge] et [jaune] (un `User` ou un `Bot`).
      Future<Partie> finishedGame(
        Object rouge,
        Object jaune, {
        required EnumType type,
        required EnumOutcome winner,
        DateTime? at,
      }) async {
        final session = sessionBuilder.build();
        Future<Player> seat(Object who) => Player.db.insertRow(
          session,
          who is User ? Player(userId: who.id) : Player(botId: (who as Bot).id),
        );
        return Partie.db.insertRow(
          session,
          Partie(
            typePartie: type,
            playerRougeId: (await seat(rouge)).id!,
            playerJauneId: (await seat(jaune)).id!,
            status: EnumStatut.finished,
            winner: winner,
            moves: const [],
            createdAt: at ?? DateTime.now().toUtc(),
          ),
        );
      }

      test('a friend with the live stream open is online, then seen', () async {
        final (alice, aliceUser) = await player('alice');
        final (bob, bobUser) = await player('bob');
        await befriend(aliceUser, bobUser);

        expect(
          (await friendSeenBy(alice)).presence,
          EnumFriendPresence.offline,
        );

        final live = endpoints.live.watchUpdates(bob).listen((_) {});
        await _eventually(
          () async =>
              (await friendSeenBy(alice)).presence == EnumFriendPresence.online
              ? true
              : null,
        );

        await live.cancel();
        final seen = await _eventually(() async {
          final friend = await friendSeenBy(alice);
          return friend.presence == EnumFriendPresence.offline
              ? friend.lastSeenAt
              : null;
        });
        expect(seen.difference(DateTime.now()).inMinutes, 0);
      });

      test('an accepted challenge starts a game the friend sees', () async {
        final (alice, aliceUser) = await player('alice');
        final (bob, bobUser) = await player('bob');
        final (carol, carolUser) = await player('carol');
        await befriend(aliceUser, bobUser);
        await befriend(carolUser, bobUser);

        final host = listen(
          endpoints.multiplayer.hostRoom(
            alice,
            false,
            challengeUserId: bobUser.id,
          ),
        );
        final code = (await host.next(EnumGameEventType.roomCreated)).code!;

        final challenges = await endpoints.friends.getChallenges(bob);
        expect(challenges.single.code, code);
        expect(challenges.single.from.username, 'alice');
        // Une salle de défi n'est ni publique ni ouverte à un autre.
        await expectLater(
          endpoints.multiplayer.joinRoom(carol, code).first,
          throwsA(
            isA<GameException>().having(
              (e) => e.reason,
              'reason',
              EnumGameError.roomNotFound,
            ),
          ),
        );

        final guest = listen(endpoints.multiplayer.joinRoom(bob, code));
        await host.next(EnumGameEventType.gameStarted);
        await guest.next(EnumGameEventType.gameStarted);

        expect(await endpoints.friends.getChallenges(bob), isEmpty);
        final aliceSeenByBob = (await endpoints.friends.getOverview(
          bob,
        )).friends.firstWhere((f) => f.other.username == 'alice');
        expect(aliceSeenByBob.presence, EnumFriendPresence.playing);
        expect(aliceSeenByBob.playing, EnumType.multi);
      });

      test('a declined challenge closes the host room', () async {
        final (alice, aliceUser) = await player('alice');
        final (bob, bobUser) = await player('bob');
        await befriend(aliceUser, bobUser);

        final host = listen(
          endpoints.multiplayer.hostRoom(
            alice,
            false,
            challengeUserId: bobUser.id,
          ),
        );
        final code = (await host.next(EnumGameEventType.roomCreated)).code!;

        await endpoints.friends.declineChallenge(bob, code);

        await host.next(EnumGameEventType.challengeDeclined);
        expect(await endpoints.friends.getChallenges(bob), isEmpty);
        await expectLater(
          endpoints.friends.declineChallenge(bob, code),
          throwsA(
            isA<FriendsException>().having(
              (e) => e.reason,
              'reason',
              EnumFriendsError.challengeNotFound,
            ),
          ),
        );
      });

      test('only a friend can be challenged', () async {
        final (alice, _) = await player('alice');
        final (_, strangerUser) = await player('stranger');

        final host = listen(
          endpoints.multiplayer.hostRoom(
            alice,
            false,
            challengeUserId: strangerUser.id,
          ),
        );

        expect(
          await host.nextError(),
          isA<GameException>().having(
            (e) => e.reason,
            'reason',
            EnumGameError.friendUnavailable,
          ),
        );
      });

      test('two players shaking together find each other', () async {
        final (alice, _) = await player('alice');
        final (bob, _) = await player('bob');

        final (aliceSees, bobSees) = await (
          endpoints.friends.shakeToAdd(alice),
          endpoints.friends.shakeToAdd(bob),
        ).wait;

        expect(aliceSees?.player.username, 'bob');
        expect(aliceSees?.relation, EnumFriendRelation.none);
        expect(bobSees?.player.username, 'alice');
      });

      test('a lone shake finds nobody', () async {
        final (alice, _) = await player('alice');

        expect(await endpoints.friends.shakeToAdd(alice), isNull);
        // Deux appareils du même compte ne s'apparient pas entre eux.
        final both = await (
          endpoints.friends.shakeToAdd(alice),
          endpoints.friends.shakeToAdd(alice),
        ).wait;
        expect(both, (null, null));
      });

      test('rivalries count head-to-head results and the streak', () async {
        final (alice, aliceUser) = await player('alice');
        final (_, bobUser) = await player('bob');
        final (_, carolUser) = await player('carol');
        final (_, daveUser) = await player('dave');
        await befriend(aliceUser, bobUser);
        await befriend(aliceUser, carolUser);
        Future<void> multi(User rouge, User jaune, EnumOutcome w, int day) =>
            finishedGame(
              rouge,
              jaune,
              type: EnumType.multi,
              winner: w,
              at: DateTime.utc(2026, 10, day),
            );
        await multi(aliceUser, bobUser, EnumOutcome.jaune, 1); // défaite
        await multi(bobUser, aliceUser, EnumOutcome.jaune, 2); // victoire
        await multi(aliceUser, bobUser, EnumOutcome.rouge, 3); // victoire
        await multi(aliceUser, daveUser, EnumOutcome.rouge, 4); // pas un ami

        final rivalries = await endpoints.friends.getRivalries(alice);

        expect(rivalries.map((r) => r.friend.username), ['bob', 'carol']);
        final bob = rivalries.first;
        expect((bob.wins, bob.losses, bob.draws), (2, 1, 0));
        expect(bob.streak, 2);
        expect(bob.partieIds, hasLength(3));
        expect(bob.lastPlayedAt, DateTime.utc(2026, 10, 3));
        expect(rivalries.last.partieIds, isEmpty);
      });

      test("the activity feed lists friends' recent games", () async {
        final (alice, aliceUser) = await player('alice');
        final (_, bobUser) = await player('bob');
        final (_, strangerUser) = await player('stranger');
        await befriend(aliceUser, bobUser);
        final bot = await Bot.db.insertRow(
          sessionBuilder.build(),
          Bot(botName: 'Expert', elo: 1500, pathModel: '', description: ''),
        );
        final ranked = await finishedGame(
          bobUser,
          bot,
          type: EnumType.classe,
          winner: EnumOutcome.rouge,
        );
        await EloHistory.db.insertRow(
          sessionBuilder.build(),
          EloHistory(
            userId: bobUser.id!,
            partieId: ranked.id!,
            eloVariation: 24,
            newElo: 1024,
          ),
        );
        await finishedGame(
          strangerUser,
          bot,
          type: EnumType.classe,
          winner: EnumOutcome.rouge,
        );
        await finishedGame(
          aliceUser,
          bobUser,
          type: EnumType.multi,
          winner: EnumOutcome.rouge,
          at: DateTime.now().toUtc().subtract(const Duration(days: 30)),
        );

        final activity = await endpoints.friends.getFriendsActivity(alice);

        // Ni l'inconnu, ni la partie trop ancienne.
        expect(activity, hasLength(1));
        expect(activity.single.friend.username, 'bob');
        expect(activity.single.typePartie, EnumType.classe);
        expect(activity.single.result, EnumMatchResult.win);
        expect(activity.single.opponent, 'Expert');
        expect(activity.single.eloVariation, 24);
      });

      test('recent Multi opponents come newest first, once each', () async {
        final (alice, aliceUser) = await player('alice');
        final (_, bobUser) = await player('bob');
        final (_, carolUser) = await player('carol');
        await befriend(aliceUser, carolUser);
        final session = sessionBuilder.build();

        Future<void> played(User opponent, DateTime when) async {
          final mine = await Player.db.insertRow(
            session,
            Player(userId: aliceUser.id),
          );
          final theirs = await Player.db.insertRow(
            session,
            Player(userId: opponent.id),
          );
          await Partie.db.insertRow(
            session,
            Partie(
              typePartie: EnumType.multi,
              playerRougeId: mine.id!,
              playerJauneId: theirs.id!,
              status: EnumStatut.finished,
              moves: const [],
              createdAt: when,
            ),
          );
        }

        await played(bobUser, DateTime(2026, 10, 1));
        await played(carolUser, DateTime(2026, 10, 2));
        await played(bobUser, DateTime(2026, 10, 3));

        final recent = await endpoints.friends.recentOpponents(alice);

        expect(recent.map((r) => (r.player.username, r.relation)), [
          ('bob', EnumFriendRelation.none),
          ('carol', EnumFriendRelation.friend),
        ]);
      });
    },
  );
}
