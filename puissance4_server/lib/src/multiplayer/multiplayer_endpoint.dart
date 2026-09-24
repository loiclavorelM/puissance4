import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../game/game_stream.dart';
import '../game/server_game.dart';
import '../generated/protocol.dart';
import 'multiplayer_config.dart';

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

  /// Ouvre une salle : émet `roomCreated` (avec le code), puis, à l'arrivée
  /// de l'adversaire, les événements de la partie. Fermer ce stream avant
  /// ferme la salle ; à expiration il émet `roomClosed` et se termine.
  Stream<GameEvent> hostRoom(Session session) =>
      GameStream(session, (stream) => _host(session, stream)).events;

  /// Rejoint la salle [code] : crée la partie et émet ses événements, à
  /// commencer par `gameStarted`.
  Stream<GameEvent> joinRoom(Session session, String code) =>
      GameStream(session, (stream) => _join(session, stream, code)).events;

  Future<void> _host(Session session, GameStream stream) async {
    final me = await ServerGame.requireUser(session);
    await ServerGame.ensureNotInGame(session, me);

    final (:room, :replaced) = await MultiplayerConfig.rooms.create(
      hostAuthUserId: me.authUserId!,
      hostUserId: me.id!,
      lifetime: MultiplayerConfig.roomLifetime,
    );
    if (replaced != null) {
      await session.messages.postMessage(
        roomChannel(replaced.code),
        GameEvent(type: EnumGameEventType.roomClosed, code: replaced.code),
      );
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
    } catch (_) {
      // Salle déjà retirée : libérer l'hôte plutôt que le laisser attendre.
      await session.messages.postMessage(
        roomChannel(room.code),
        GameEvent(type: EnumGameEventType.roomClosed, code: room.code),
      );
      rethrow;
    }
    await session.messages.postMessage(
      roomChannel(room.code),
      GameEvent(type: EnumGameEventType.gameStarted, partieId: partie.id),
    );
    await followPartie(session, stream, partie.id!);
  }
}
