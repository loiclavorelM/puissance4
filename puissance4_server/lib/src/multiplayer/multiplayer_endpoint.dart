import 'dart:async';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../game/game_stream.dart';
import '../game/server_game.dart';
import '../generated/protocol.dart';
import '../profile/profile_photo.dart';
import 'multiplayer_config.dart';
import 'room_store.dart';

/// Multijoueur en ligne (E7) : salles d'attente. Une salle n'existe que tant
/// que le stream de son hôte est ouvert ([hostRoom]) ; la `Partie` n'est
/// créée qu'à l'arrivée de l'adversaire ([joinRoom]). Une fois la partie
/// commencée, chaque joueur la suit par le même stream (ou par
/// `GameEndpoint.watchPartie` après une coupure) et joue par
/// `GameEndpoint.playMove`.
class MultiplayerEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static String roomChannel(String code) => 'multi.room.$code';

  /// Annonce qu'une salle publique a été ouverte, fermée, prise ou a expiré
  /// (US7.4). Locale tant que les salles sont en mémoire ; à passer en
  /// `global: true` avec un `RoomStore` partagé (Redis).
  static const lobbyChannel = 'multi.lobby';

  /// Ouvre une salle : émet `roomCreated` (avec le code), puis, à l'arrivée
  /// de l'adversaire, les événements de la partie. Fermer ce stream avant
  /// ferme la salle ; à expiration il émet `roomClosed` et se termine.
  /// Une salle [isPublic] apparaît dans le lobby ([watchLobby]) ; sinon elle
  /// ne se rejoint que par son code.
  Stream<GameEvent> hostRoom(Session session, bool isPublic) => GameStream(
    session,
    (stream) => _host(session, stream, isPublic: isPublic),
  ).events;

  /// Salles publiques ouvertes (sauf la sienne) : la liste au départ, puis
  /// une nouvelle liste à chaque changement. On les rejoint par [joinRoom]
  /// avec leur code — de deux joueurs qui choisissent la même, un seul
  /// l'obtient, l'autre reçoit `roomNotFound`.
  ///
  /// Pas de générateur `async*` : annulé pendant un `await for`, il ne le
  /// verrait qu'au changement suivant, et la session resterait ouverte.
  Stream<LobbySnapshot> watchLobby(Session session) {
    final me = session.authenticated!.authUserId;
    final controller = StreamController<LobbySnapshot>();
    StreamSubscription<LiveEvent>? changes;
    // Relectures enchaînées : les listes sortent dans l'ordre.
    var pending = Future<void>.value();
    void refresh() => pending = pending.then((_) async {
      final lobby = await _lobby(me);
      if (!controller.isClosed) controller.add(lobby);
    });

    controller
      ..onListen = () {
        // Abonné avant la première lecture : aucun changement ne se perd.
        changes = session.messages
            .createStream<LiveEvent>(lobbyChannel)
            .listen((_) => refresh());
        refresh();
      }
      ..onCancel = () async {
        await changes?.cancel();
        await controller.close();
      };
    return controller.stream;
  }

  static Future<LobbySnapshot> _lobby(UuidValue me) async => LobbySnapshot(
    rooms: [
      for (final room in await MultiplayerConfig.rooms.listPublic(
        exceptHost: me,
      ))
        room.toLobbyRoom(),
    ],
  );

  static Future<void> _lobbyChanged(Session session, Room? room) async {
    if (room == null || !room.isPublic) return;
    await session.messages.postMessage(
      lobbyChannel,
      LiveEvent(type: EnumLiveEventType.lobbyChanged),
    );
  }

  /// Rejoint la salle [code] : crée la partie et émet ses événements, à
  /// commencer par `gameStarted`.
  Stream<GameEvent> joinRoom(Session session, String code) =>
      GameStream(session, (stream) => _join(session, stream, code)).events;

  Future<void> _host(
    Session session,
    GameStream stream, {
    required bool isPublic,
  }) async {
    final me = await ServerGame.requireUser(session);
    await ServerGame.ensureNotInGame(session, me);

    final (:room, :replaced) = await MultiplayerConfig.rooms.create(
      hostAuthUserId: me.authUserId!,
      hostUserId: me.id!,
      lifetime: MultiplayerConfig.roomLifetime,
      listedAs: isPublic
          ? RoomHost(
              username: me.username,
              elo: me.elo,
              thumbnailUrl: await ProfilePhoto.url(session, me.thumbnailPath),
            )
          : null,
    );
    if (replaced != null) {
      await session.messages.postMessage(
        roomChannel(replaced.code),
        GameEvent(type: EnumGameEventType.roomClosed, code: replaced.code),
      );
      await _lobbyChanged(session, replaced);
    }

    // Écoute branchée avant d'annoncer le code : personne ne peut rejoindre
    // avant. `null` = expirée ou stream fermé par le client.
    final outcome = Completer<GameEvent?>();
    void settle(GameEvent? event) {
      if (!outcome.isCompleted) outcome.complete(event);
    }

    final subscription = session.messages
        .createStream<GameEvent>(roomChannel(room.code))
        .listen(settle);
    final expiry = Timer(
      room.expiresAt.difference(DateTime.now().toUtc()),
      () => settle(null),
    );
    unawaited(stream.cancelled.then((_) => settle(null)));

    GameEvent? event;
    try {
      await _lobbyChanged(session, room);
      stream.emit(
        GameEvent(
          type: EnumGameEventType.roomCreated,
          code: room.code,
          roomExpiresAt: room.expiresAt,
          typePartie: EnumType.multi,
        ),
      );
      event = await outcome.future;
    } finally {
      expiry.cancel();
      await subscription.cancel();
      if (event?.type != EnumGameEventType.gameStarted) {
        await MultiplayerConfig.rooms.remove(room.code, me.authUserId!);
        await _lobbyChanged(session, room);
      }
    }

    if (stream.isCancelled) return;
    if (event?.type != EnumGameEventType.gameStarted) {
      stream.emit(
        GameEvent(type: EnumGameEventType.roomClosed, code: room.code),
      );
      return;
    }
    await followPartie(session, stream, event!.partieId!);
  }

  Future<void> _join(Session session, GameStream stream, String code) async {
    final me = await ServerGame.requireUser(session);
    // Avant de réserver la salle : un refus ne doit pas la consommer.
    await ServerGame.ensureNotInGame(session, me);

    final room = await MultiplayerConfig.rooms.claim(
      code,
      guestAuthUserId: me.authUserId!,
    );
    if (room == null) {
      throw GameException(reason: EnumGameError.roomNotFound);
    }
    // Prise : elle sort du lobby (elle y revient si elle est rendue).
    await _lobbyChanged(session, room);

    final Partie partie;
    try {
      final host = await User.db.findById(session, room.hostUserId);
      if (host == null) throw GameException(reason: EnumGameError.roomNotFound);
      partie = await ServerGame.start(
        session,
        typePartie: EnumType.multi,
        first: GameSeat.human(host),
        second: GameSeat.human(me),
        code: room.code,
      );
    } catch (error) {
      // Invité déjà en partie (lancée entre `ensureNotInGame` et ici) : la
      // salle n'y est pour rien, elle est rendue à l'hôte qui attend
      // toujours. Sinon — ou s'il est trop tard pour la rendre —, libérer
      // l'hôte plutôt que le laisser attendre une salle déjà retirée.
      final guestBusy = error is SeatBusyException && error.user.id == me.id;
      if (guestBusy && await MultiplayerConfig.rooms.restore(room)) {
        await _lobbyChanged(session, room);
      } else {
        await session.messages.postMessage(
          roomChannel(room.code),
          GameEvent(type: EnumGameEventType.roomClosed, code: room.code),
        );
      }
      if (error is SeatBusyException) {
        throw guestBusy
            ? GameException(
                reason: EnumGameError.alreadyInGame,
                partieId: error.partieId,
              )
            // L'hôte a commencé une autre partie (ex. un Classé depuis un
            // autre appareil) depuis l'ouverture de sa salle.
            : GameException(reason: EnumGameError.roomNotFound);
      }
      rethrow;
    }
    await session.messages.postMessage(
      roomChannel(room.code),
      GameEvent(type: EnumGameEventType.gameStarted, partieId: partie.id),
    );
    await followPartie(session, stream, partie.id!);
  }
}
