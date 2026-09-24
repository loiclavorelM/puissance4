import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'server_game.dart';

/// Stream renvoyé au client, alimenté par [body]. Contrairement à un
/// générateur `async*` — qui ne voit une annulation qu'à son prochain
/// `yield` —, [cancelled] se déclenche dès que le client ferme le stream
/// (ou perd sa connexion), pour libérer tout de suite salle et présence.
class GameStream {
  GameStream(Session session, Future<void> Function(GameStream) body) {
    _controller
      ..onListen = () {
        _done = () async {
          try {
            await body(this);
          } catch (error, stackTrace) {
            if (isCancelled) {
              session.log(
                'Game stream failed after cancel',
                level: LogLevel.warning,
                exception: error,
                stackTrace: stackTrace,
              );
            } else {
              _controller.addError(error, stackTrace);
            }
          } finally {
            // Pas d'`await` : après une annulation, `close()` attend la fin de
            // `onCancel`, qui attend elle-même ce corps.
            unawaited(_controller.close());
          }
        }();
      }
      ..onCancel = () {
        if (!_cancelled.isCompleted) _cancelled.complete();
        // La session du stream reste ouverte jusqu'à la fin du nettoyage.
        return _done;
      };
  }

  final _controller = StreamController<GameEvent>();
  final _cancelled = Completer<void>();
  Future<void>? _done;

  Stream<GameEvent> get events => _controller.stream;
  Future<void> get cancelled => _cancelled.future;
  bool get isCancelled => _cancelled.isCompleted;

  void emit(GameEvent event) {
    if (!isCancelled) _controller.add(event);
  }
}

/// Relaie à l'appelant les événements de la partie [partieId], en tenant sa
/// présence à jour : sa connexion est enregistrée à l'ouverture et, si le
/// stream se ferme avant la fin, son départ déclenche le délai de grâce.
/// Commun aux streams Multi (`hostRoom`, `joinRoom`) et à `watchPartie`.
Future<void> followPartie(
  Session session,
  GameStream stream,
  UuidValue partieId,
) async {
  final me = await ServerGame.requireUser(session);
  final (_, seats, color) = await ServerGame.loadAsPlayer(
    session,
    partieId,
    me,
  );

  // Abonné avant de lire l'état : aucun coup ne peut passer entre les deux
  // (au pire un doublon, sans effet puisque chaque événement est complet).
  final inbox = StreamIterator(
    session.messages.createStream<GameEvent>(
      ServerGame.partieChannel(partieId),
    ),
  );
  UuidValue? connectionId;
  var over = false;
  try {
    final attached = await ServerGame.attach(session, partieId, color);
    connectionId = attached.connectionId;
    if (attached.partie.status != EnumStatut.inProgress) {
      over = true;
      stream.emit(
        await _forRecipient(
          session,
          ServerGame.snapshot(
            attached.partie,
            seats,
            EnumGameEventType.gameOver,
          ),
          me,
          color,
        ),
      );
      return;
    }
    stream.emit(
      ServerGame.snapshot(
        attached.partie,
        seats,
        EnumGameEventType.gameStarted,
      ).copyWith(yourColor: color),
    );

    while (!over) {
      final hasNext = await Future.any([
        inbox.moveNext(),
        stream.cancelled.then((_) => false),
      ]);
      if (!hasNext || stream.isCancelled) break;
      final event = inbox.current;
      // Présence : on ne relaie que celle de l'adversaire.
      if (event.aboutColor == color) continue;
      over = event.type == EnumGameEventType.gameOver;
      stream.emit(await _forRecipient(session, event, me, color));
    }
  } finally {
    await inbox.cancel();
    final id = connectionId;
    if (!over && id != null) {
      // Session propre : celle du stream se ferme avec lui.
      await session.serverpod.withSession(
        (fresh) => ServerGame.detach(fresh, partieId, color, id),
      );
    }
  }
}

/// Personnalise [event] pour son destinataire : sa couleur et, en fin de
/// partie Classé, sa variation d'Elo.
Future<GameEvent> _forRecipient(
  Session session,
  GameEvent event,
  User me,
  EnumColor color,
) async {
  var personal = event.copyWith(yourColor: color);
  if (event.type == EnumGameEventType.gameOver &&
      event.typePartie == EnumType.classe) {
    final history = await EloHistory.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(me.id) & t.partieId.equals(event.partieId),
    );
    personal = personal.copyWith(eloVariation: history?.eloVariation);
  }
  return personal;
}
