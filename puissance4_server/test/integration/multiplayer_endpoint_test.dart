import 'dart:async';

import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:puissance4_server/src/game/server_game.dart';
import 'package:puissance4_server/src/game/server_game_config.dart';
import 'package:puissance4_server/src/multiplayer/multiplayer_config.dart';
import 'package:puissance4_server/src/multiplayer/room_store.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Collecte les événements d'un stream Multi pour pouvoir les attendre un par
/// un, dans l'ordre.
class _Events {
  _Events(Stream<GameEvent> stream) {
    _subscription = stream.listen(
      all.add,
      onError: errors.add,
      onDone: () => isDone = true,
    );
  }

  late final StreamSubscription<GameEvent> _subscription;
  final all = <GameEvent>[];
  final errors = <Object>[];
  var isDone = false;
  var _cursor = 0;

  /// Prochain événement de type [type] après le dernier déjà attendu.
  Future<GameEvent> next(EnumGameEventType type) async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (DateTime.now().isBefore(deadline)) {
      for (var i = _cursor; i < all.length; i++) {
        if (all[i].type == type) {
          _cursor = i + 1;
          return all[i];
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    throw TimeoutException('No $type event (got ${all.map((e) => e.type)})');
  }

  Future<Object> nextError() async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (errors.isEmpty && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    return errors.isNotEmpty
        ? errors.first
        : throw TimeoutException('No error');
  }

  Future<void> cancel() => _subscription.cancel();
}

/// Collecte les listes émises par `watchLobby`.
class _LobbyWatch {
  _LobbyWatch(Stream<LobbySnapshot> stream) {
    _subscription = stream.listen(all.add, onError: (_) {});
  }

  late final StreamSubscription<LobbySnapshot> _subscription;
  final all = <LobbySnapshot>[];

  /// Attend une liste dont les codes de salle valent [codes].
  Future<List<LobbyRoom>> until(Set<String> codes) async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (DateTime.now().isBefore(deadline)) {
      if (all.isNotEmpty &&
          all.last.rooms.map((r) => r.code).toSet().containsAll(codes) &&
          all.last.rooms.length == codes.length) {
        return all.last.rooms;
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    throw TimeoutException(
      'Lobby never became $codes (got ${all.map((l) => l.rooms.map((r) => r.code))})',
    );
  }

  Future<void> cancel() => _subscription.cancel();
}

Matcher _gameError(EnumGameError reason) =>
    isA<GameException>().having((e) => e.reason, 'reason', reason);

void main() {
  withServerpod(
    'Given Multiplayer endpoint',
    // Les streams, rappels différés et nettoyages utilisent leurs propres
    // sessions : sans commit réel, ils ne verraient pas les lignes du test.
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late LocalTimerScheduler scheduler;
      final openStreams = <_Events>[];

      Future<TestSessionBuilder> signedInAs(String username) async {
        final session = sessionBuilder.build();
        final authUser = await const AuthUsers().create(session);
        await User.db.insertRow(
          session,
          User(authUserId: authUser.id, username: username),
        );
        return sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            authUser.id.uuid,
            {},
          ),
        );
      }

      final lobbies = <_LobbyWatch>[];
      _LobbyWatch watchLobby(TestSessionBuilder who) {
        final lobby = _LobbyWatch(endpoints.multiplayer.watchLobby(who));
        lobbies.add(lobby);
        return lobby;
      }

      _Events listen(Stream<GameEvent> stream) {
        final events = _Events(stream);
        openStreams.add(events);
        return events;
      }

      Future<List<Partie>> parties() => Partie.db.find(sessionBuilder.build());

      Future<Partie> waitForPresence(
        UuidValue partieId,
        bool Function(Partie) test,
      ) async {
        final deadline = DateTime.now().add(const Duration(seconds: 5));
        while (DateTime.now().isBefore(deadline)) {
          final partie = await Partie.db.findById(
            sessionBuilder.build(),
            partieId,
          );
          if (test(partie!)) return partie;
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        throw TimeoutException('Presence never reached');
      }

      Future<Partie> waitForStatus(
        UuidValue partieId,
        EnumStatut status,
      ) async {
        final deadline = DateTime.now().add(const Duration(seconds: 5));
        while (DateTime.now().isBefore(deadline)) {
          final partie = await Partie.db.findById(
            sessionBuilder.build(),
            partieId,
          );
          if (partie!.status == status) return partie;
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        throw TimeoutException('Partie never reached $status');
      }

      /// Ouvre une salle pour [host] et la fait rejoindre par [guest].
      /// Renvoie les streams et builders rangés par couleur.
      Future<
        ({
          UuidValue partieId,
          _Events rouge,
          _Events jaune,
          TestSessionBuilder rougeSession,
          TestSessionBuilder jauneSession,
        })
      >
      startGame(TestSessionBuilder host, TestSessionBuilder guest) async {
        final hostEvents = listen(endpoints.multiplayer.hostRoom(host, false));
        final code = (await hostEvents.next(
          EnumGameEventType.roomCreated,
        )).code!;
        final guestEvents = listen(endpoints.multiplayer.joinRoom(guest, code));
        final hostStart = await hostEvents.next(EnumGameEventType.gameStarted);
        await guestEvents.next(EnumGameEventType.gameStarted);
        final hostIsRouge = hostStart.yourColor == EnumColor.rouge;
        return (
          partieId: hostStart.partieId!,
          rouge: hostIsRouge ? hostEvents : guestEvents,
          jaune: hostIsRouge ? guestEvents : hostEvents,
          rougeSession: hostIsRouge ? host : guest,
          jauneSession: hostIsRouge ? guest : host,
        );
      }

      setUp(() {
        scheduler = LocalTimerScheduler();
        MultiplayerConfig.rooms = InMemoryRoomStore();
        ServerGameConfig.scheduler = scheduler;
        MultiplayerConfig.roomLifetime = const Duration(minutes: 1);
        ServerGameConfig.disconnectGrace = const Duration(milliseconds: 300);
        ServerGameConfig.turnTimeout = const Duration(seconds: 30);
      });

      tearDown(() async {
        for (final events in openStreams) {
          await events.cancel();
        }
        openStreams.clear();
        for (final lobby in lobbies) {
          await lobby.cancel();
        }
        lobbies.clear();
        scheduler.cancelAll();
        ServerGame.releaseStreams();
        final session = sessionBuilder.build();
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
        'when a guest joins the code then both get the game with opposite colors',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');

          final game = await startGame(alice, bob);

          final rougeStart = game.rouge.all.last;
          final jauneStart = game.jaune.all.last;
          expect(rougeStart.yourColor, EnumColor.rouge);
          expect(jauneStart.yourColor, EnumColor.jaune);
          expect(rougeStart.moves, isEmpty);
          expect(rougeStart.turnDeadline, isNotNull);
          expect(
            {rougeStart.rouge?.username, rougeStart.jaune?.username},
            {
              'alice',
              'bob',
            },
          );
          final saved = await parties();
          expect(saved.single.status, EnumStatut.inProgress);
          expect(saved.single.typePartie, EnumType.multi);
        },
      );

      test(
        'when the host leaves before anyone joins then the code is dead and no partie exists',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final host = listen(endpoints.multiplayer.hostRoom(alice, false));
          final code = (await host.next(EnumGameEventType.roomCreated)).code!;

          await host.cancel();
          final guest = listen(endpoints.multiplayer.joinRoom(bob, code));

          expect(
            await guest.nextError(),
            _gameError(EnumGameError.roomNotFound),
          );
          expect(await parties(), isEmpty);
        },
      );

      test(
        'when two guests join the same code then only one partie is created',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final carol = await signedInAs('carol');
          final host = listen(endpoints.multiplayer.hostRoom(alice, false));
          final code = (await host.next(EnumGameEventType.roomCreated)).code!;

          final bobEvents = listen(endpoints.multiplayer.joinRoom(bob, code));
          final carolEvents = listen(
            endpoints.multiplayer.joinRoom(carol, code),
          );
          await host.next(EnumGameEventType.gameStarted);
          await Future<void>.delayed(const Duration(milliseconds: 200));

          // Le perdant reçoit aussi un `ConnectionClosedException` de l'outil
          // de test à la fermeture de son stream : seul le refus compte.
          final failures = [
            ...bobEvents.errors,
            ...carolEvents.errors,
          ].whereType<GameException>();
          expect(failures, [_gameError(EnumGameError.roomNotFound)]);
          expect(await parties(), hasLength(1));
        },
      );

      test(
        'when the host enters its own code then it is refused and the room stays open',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final host = listen(endpoints.multiplayer.hostRoom(alice, false));
          final code = (await host.next(EnumGameEventType.roomCreated)).code!;

          final self = listen(endpoints.multiplayer.joinRoom(alice, code));
          expect(await self.nextError(), _gameError(EnumGameError.ownRoom));

          listen(endpoints.multiplayer.joinRoom(bob, code));
          await host.next(EnumGameEventType.gameStarted);
        },
      );

      test(
        'when the host opens a second room then the first stream is closed',
        () async {
          final alice = await signedInAs('alice');
          final first = listen(endpoints.multiplayer.hostRoom(alice, false));
          await first.next(EnumGameEventType.roomCreated);

          final second = listen(endpoints.multiplayer.hostRoom(alice, false));
          await second.next(EnumGameEventType.roomCreated);

          await first.next(EnumGameEventType.roomClosed);
        },
      );

      test(
        'when a public room opens then others see it in the lobby, but not its host',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final bobLobby = watchLobby(bob);
          final aliceLobby = watchLobby(alice);
          await bobLobby.until({});

          listen(endpoints.multiplayer.hostRoom(alice, false));
          final public = listen(endpoints.multiplayer.hostRoom(bob, true));
          final code = (await public.next(EnumGameEventType.roomCreated)).code!;

          // La salle privée d'alice n'apparaît nulle part.
          final seen = await aliceLobby.until({code});
          expect(seen.single.hostUsername, 'bob');
          expect(seen.single.hostElo, 1000);
          await Future<void>.delayed(const Duration(milliseconds: 100));
          expect(bobLobby.all.last.rooms, isEmpty);
        },
      );

      test(
        'when a public room is taken or closed then it leaves the lobby',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final carol = await signedInAs('carol');
          final lobby = watchLobby(carol);

          final aliceRoom = listen(endpoints.multiplayer.hostRoom(alice, true));
          final aliceCode = (await aliceRoom.next(
            EnumGameEventType.roomCreated,
          )).code!;
          final bobRoom = listen(endpoints.multiplayer.hostRoom(bob, true));
          final bobCode = (await bobRoom.next(
            EnumGameEventType.roomCreated,
          )).code!;
          await lobby.until({aliceCode, bobCode});

          await bobRoom.cancel();
          await lobby.until({aliceCode});

          listen(endpoints.multiplayer.joinRoom(carol, aliceCode));
          await aliceRoom.next(EnumGameEventType.gameStarted);
          await lobby.until({});
        },
      );

      test('when a public room expires then it leaves the lobby', () async {
        MultiplayerConfig.roomLifetime = const Duration(milliseconds: 300);
        final alice = await signedInAs('alice');
        final bob = await signedInAs('bob');
        final lobby = watchLobby(bob);

        final host = listen(endpoints.multiplayer.hostRoom(alice, true));
        final code = (await host.next(EnumGameEventType.roomCreated)).code!;
        await lobby.until({code});

        await host.next(EnumGameEventType.roomClosed);
        await lobby.until({});
      });

      test('when the room expires then the host gets roomClosed', () async {
        MultiplayerConfig.roomLifetime = const Duration(milliseconds: 200);
        final alice = await signedInAs('alice');
        final host = listen(endpoints.multiplayer.hostRoom(alice, false));
        await host.next(EnumGameEventType.roomCreated);

        await host.next(EnumGameEventType.roomClosed);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(host.isDone, isTrue);
      });

      test(
        'when players alternate until four in a column then rouge wins and the partie is finished',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final game = await startGame(alice, bob);

          await expectLater(
            endpoints.game.playMove(game.jauneSession, game.partieId, 0),
            throwsA(_gameError(EnumGameError.notYourTurn)),
          );
          for (final (session, column) in [
            (game.rougeSession, 0),
            (game.jauneSession, 1),
            (game.rougeSession, 0),
            (game.jauneSession, 1),
            (game.rougeSession, 0),
            (game.jauneSession, 1),
          ]) {
            await endpoints.game.playMove(session, game.partieId, column);
          }
          final lastMove = await game.jaune.next(
            EnumGameEventType.moveApplied,
          );
          expect(lastMove.moves, [0]);
          await endpoints.game.playMove(game.rougeSession, game.partieId, 0);

          for (final events in [game.rouge, game.jaune]) {
            final over = await events.next(EnumGameEventType.gameOver);
            expect(over.winner, EnumOutcome.rouge);
            expect(over.endReason, EnumGameEndReason.connectFour);
            expect(over.moves, hasLength(7));
          }
          final saved = await Partie.db.findById(
            sessionBuilder.build(),
            game.partieId,
          );
          expect(saved!.status, EnumStatut.finished);
          await expectLater(
            endpoints.game.playMove(game.jauneSession, game.partieId, 2),
            throwsA(_gameError(EnumGameError.gameOver)),
          );
        },
      );

      test(
        'when a player asks for the replay then only the two players get the moves',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final carol = await signedInAs('carol');
          final game = await startGame(alice, bob);
          await endpoints.game.playMove(game.rougeSession, game.partieId, 3);
          await endpoints.game.playMove(game.jauneSession, game.partieId, 4);
          await endpoints.game.abandon(game.jauneSession, game.partieId);

          final replay = await endpoints.history.getReplay(
            game.rougeSession,
            idPartie: game.partieId,
          );
          expect(replay.moves, [3, 4]);
          expect(replay.playedAs, EnumColor.rouge);
          expect(replay.winner, EnumOutcome.rouge);
          expect(replay.endReason, EnumGameEndReason.forfeit);
          await expectLater(
            endpoints.history.getReplay(carol, idPartie: game.partieId),
            throwsA(_gameError(EnumGameError.notAPlayer)),
          );
        },
      );

      test(
        'when a player in a game tries to host again then it gets alreadyInGame with the partie',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final game = await startGame(alice, bob);

          final again = listen(endpoints.multiplayer.hostRoom(alice, false));

          expect(
            await again.nextError(),
            isA<GameException>()
                .having((e) => e.reason, 'reason', EnumGameError.alreadyInGame)
                .having((e) => e.partieId, 'partieId', game.partieId),
          );
          expect(
            await endpoints.game.getActivePartie(alice),
            game.partieId,
          );
        },
      );

      test(
        'when a player disconnects after a move and does not come back then the opponent wins',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final game = await startGame(alice, bob);
          await endpoints.game.playMove(
            game.rougeSession,
            game.partieId,
            3,
          );
          await endpoints.game.playMove(
            game.jauneSession,
            game.partieId,
            4,
          );

          await game.jaune.cancel();

          await game.rouge.next(EnumGameEventType.opponentDisconnected);
          final over = await game.rouge.next(EnumGameEventType.gameOver);
          expect(over.winner, EnumOutcome.rouge);
          expect(over.endReason, EnumGameEndReason.disconnect);
        },
      );

      test(
        'when a disconnected player comes back within the grace period then the game goes on',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final game = await startGame(alice, bob);
          await endpoints.game.playMove(
            game.rougeSession,
            game.partieId,
            3,
          );

          await game.jaune.cancel();
          await game.rouge.next(EnumGameEventType.opponentDisconnected);
          final back = listen(
            endpoints.game.watchPartie(game.jauneSession, game.partieId),
          );
          final resumed = await back.next(EnumGameEventType.gameStarted);
          expect(resumed.moves, [3]);
          expect(resumed.yourColor, EnumColor.jaune);
          await game.rouge.next(EnumGameEventType.opponentReconnected);

          await Future<void>.delayed(const Duration(milliseconds: 600));
          final partie = await Partie.db.findById(
            sessionBuilder.build(),
            game.partieId,
          );
          expect(partie!.status, EnumStatut.inProgress);
          await endpoints.game.playMove(
            game.jauneSession,
            game.partieId,
            4,
          );
        },
      );

      test(
        'when a player leaves before any move then the partie is cancelled',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final game = await startGame(alice, bob);

          await game.jaune.cancel();

          final over = await game.rouge.next(EnumGameEventType.gameOver);
          expect(over.winner, isNull);
          expect(over.endReason, EnumGameEndReason.cancelled);
          await waitForStatus(game.partieId, EnumStatut.abandoned);
        },
      );

      test(
        'when a player abandons after a move then the opponent wins by forfeit',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final game = await startGame(alice, bob);
          await endpoints.game.playMove(
            game.rougeSession,
            game.partieId,
            3,
          );

          await endpoints.game.abandon(game.rougeSession, game.partieId);

          final over = await game.jaune.next(EnumGameEventType.gameOver);
          expect(over.winner, EnumOutcome.jaune);
          expect(over.endReason, EnumGameEndReason.forfeit);
          await waitForStatus(game.partieId, EnumStatut.finished);
        },
      );

      test(
        'when the player to move lets the clock run out then the opponent wins on time',
        () async {
          ServerGameConfig.turnTimeout = const Duration(milliseconds: 400);
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final game = await startGame(alice, bob);
          await endpoints.game.playMove(
            game.rougeSession,
            game.partieId,
            3,
          );
          await endpoints.game.playMove(
            game.jauneSession,
            game.partieId,
            4,
          );

          final over = await game.rouge.next(EnumGameEventType.gameOver);
          expect(over.winner, EnumOutcome.jaune);
          expect(over.endReason, EnumGameEndReason.timeout);
        },
      );

      test(
        'when the server restarts with a partie still in progress then resumePending ends it',
        () async {
          ServerGameConfig.turnTimeout = const Duration(milliseconds: 200);
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final game = await startGame(alice, bob);
          await endpoints.game.playMove(
            game.rougeSession,
            game.partieId,
            3,
          );
          // Simule un redémarrage : streams et rappels en mémoire perdus.
          scheduler.cancelAll();
          await game.rouge.cancel();
          await game.jaune.cancel();
          scheduler.cancelAll();
          await Future<void>.delayed(const Duration(milliseconds: 300));
          final stuck = await Partie.db.findById(
            sessionBuilder.build(),
            game.partieId,
          );
          expect(stuck!.status, EnumStatut.inProgress);

          await ServerGame.resumePending(sessionBuilder.build());

          final ended = await waitForStatus(
            game.partieId,
            EnumStatut.abandoned,
          );
          expect(ended.winner, isNull);
        },
      );

      test(
        'when the host started another game after opening the room then the guest cannot join',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          await Bot.db.insertRow(
            sessionBuilder.build(),
            Bot(botName: 'Medium', elo: 1200, pathModel: '', description: ''),
          );
          final host = listen(endpoints.multiplayer.hostRoom(alice, false));
          final code = (await host.next(EnumGameEventType.roomCreated)).code!;
          final ranked = await endpoints.ranked.startRanked(alice);

          final guest = listen(endpoints.multiplayer.joinRoom(bob, code));

          expect(
            await guest.nextError(),
            _gameError(EnumGameError.roomNotFound),
          );
          await host.next(EnumGameEventType.roomClosed);
          expect((await parties()).map((p) => p.id), [ranked]);
        },
      );

      test(
        'when a player abandons before playing any move then the partie is cancelled even if the opponent played',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final game = await startGame(alice, bob);
          await endpoints.game.playMove(game.rougeSession, game.partieId, 3);

          await endpoints.game.abandon(game.jauneSession, game.partieId);

          final over = await game.rouge.next(EnumGameEventType.gameOver);
          expect(over.winner, isNull);
          expect(over.endReason, EnumGameEndReason.cancelled);
          await waitForStatus(game.partieId, EnumStatut.abandoned);
        },
      );

      test(
        'when a player reconnects while the opponent is away then gameStarted says so',
        () async {
          ServerGameConfig.disconnectGrace = const Duration(seconds: 10);
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final game = await startGame(alice, bob);
          await endpoints.game.playMove(game.rougeSession, game.partieId, 3);
          await game.jaune.cancel();
          await game.rouge.next(EnumGameEventType.opponentDisconnected);
          await game.rouge.cancel();

          final back = listen(
            endpoints.game.watchPartie(game.rougeSession, game.partieId),
          );
          final resumed = await back.next(EnumGameEventType.gameStarted);

          expect(resumed.opponentConnected, isFalse);
          expect(game.jaune.all.last.opponentConnected, isTrue);
        },
      );

      test(
        'when the server restarts after an outage then players get a fresh grace period and turn, and a stream opened at boot survives',
        () async {
          ServerGameConfig.disconnectGrace = const Duration(seconds: 10);
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final game = await startGame(alice, bob);
          await endpoints.game.playMove(game.rougeSession, game.partieId, 3);
          await endpoints.game.playMove(game.jauneSession, game.partieId, 4);
          await game.rouge.cancel();
          await game.jaune.cancel();
          await waitForPresence(
            game.partieId,
            (p) => p.rougeConnectionId == null && p.jauneConnectionId == null,
          );
          // Simule un arrêt d'une heure : rappels perdus, Rouge encore marqué
          // connecté (stream mort avec le serveur), Jaune déjà en délai de
          // grâce au moment de la panne.
          scheduler.cancelAll();
          final session = sessionBuilder.build();
          final hourAgo = DateTime.now().toUtc().subtract(
            const Duration(hours: 1),
          );
          final partie = await Partie.db.findById(session, game.partieId);
          await Partie.db.updateRow(
            session,
            partie!.copyWith(
              updatedAt: hourAgo,
              rougeConnectionId: const Uuid().v4obj(),
              rougeDisconnectedAt: null,
              jauneDisconnectedAt: hourAgo,
            ),
          );

          ServerGame.holdStreamsUntilResumed();
          // Client qui se reconnecte dès l'ouverture du serveur.
          final back = listen(
            endpoints.game.watchPartie(game.rougeSession, game.partieId),
          );
          await ServerGame.resumePending(sessionBuilder.build());
          final resumed = await back.next(EnumGameEventType.gameStarted);

          final bootTime = DateTime.now().toUtc().subtract(
            const Duration(seconds: 5),
          );
          expect(resumed.turnDeadline!.isAfter(DateTime.now().toUtc()), isTrue);
          final saved = await Partie.db.findById(session, game.partieId);
          expect(saved!.status, EnumStatut.inProgress);
          // La connexion ouverte au démarrage n'est pas effacée.
          expect(saved.rougeConnectionId, isNotNull);
          expect(saved.rougeDisconnectedAt, isNull);
          expect(saved.jauneDisconnectedAt!.isAfter(bootTime), isTrue);
        },
      );

      test(
        'when a player who has not moved yet runs out of time then the partie is cancelled like an abandon',
        () async {
          ServerGameConfig.turnTimeout = const Duration(milliseconds: 400);
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');
          final game = await startGame(alice, bob);
          await endpoints.game.playMove(game.rougeSession, game.partieId, 3);

          final over = await game.rouge.next(EnumGameEventType.gameOver);
          expect(over.winner, isNull);
          expect(over.endReason, EnumGameEndReason.cancelled);
        },
      );
    },
  );
}
