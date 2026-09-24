import 'dart:async';

import 'package:serverpod/serverpod.dart';

import 'server_game.dart';

/// Réglages et planificateur des parties serveur (Multi, Classé), en un seul
/// endroit.
///
/// Passage en cluster (Redis activé dans `config/*.yaml`) : remplacer
/// [scheduler] par une implémentation partagée (et `MultiplayerConfig.rooms`).
/// Rien d'autre à changer — l'état des parties est en base et les
/// événements passent par `session.messages` (portée `auto` : locale sans
/// Redis, globale avec).
abstract final class ServerGameConfig {
  /// Délai laissé à un joueur déconnecté pour revenir (`watchPartie`) avant
  /// de perdre par abandon — absorbe une micro-coupure réseau.
  static Duration disconnectGrace = const Duration(seconds: 15);

  /// Temps de réflexion par coup ; au-delà, le joueur au trait perd.
  static Duration turnTimeout = const Duration(seconds: 60);

  /// Pause avant le coup d'un bot serveur, pour que le joueur voie son propre
  /// coup se poser avant la réponse.
  static Duration botMoveDelay = const Duration(milliseconds: 600);

  static GameScheduler scheduler = LocalTimerScheduler();
}

/// Actions différées des parties serveur. Chacune est idempotente et relit
/// l'état en base avant d'agir, donc un rappel en trop (coup joué
/// entre-temps, joueur revenu) ne fait rien : pas besoin d'annuler quoi que
/// ce soit, ni de savoir quel serveur l'a programmé.
abstract interface class GameScheduler {
  /// Fait perdre au temps le joueur au trait si la partie en est toujours à
  /// [moveCount] coups après [delay].
  void scheduleTurnTimeout(UuidValue partieId, int moveCount, Duration delay);

  /// Fait perdre par abandon un joueur toujours déconnecté après [delay].
  void scheduleDisconnectCheck(UuidValue partieId, Duration delay);

  /// Fait jouer le bot serveur si la partie en est toujours à [moveCount]
  /// coups après [delay].
  void scheduleBotMove(UuidValue partieId, int moveCount, Duration delay);
}

/// [GameScheduler] par `Timer` en mémoire — précis, mais perdu si le serveur
/// s'arrête : `ServerGame.resumePending` reprogramme les parties en cours au
/// démarrage. En cluster, remplacer par des `FutureCall` (stockées en base,
/// exécutées par n'importe quel serveur).
class LocalTimerScheduler implements GameScheduler {
  final _timers = <Timer>{};

  @override
  void scheduleTurnTimeout(UuidValue partieId, int moveCount, Duration delay) {
    _schedule(
      delay,
      (session) => ServerGame.checkTurnTimeout(session, partieId, moveCount),
    );
  }

  @override
  void scheduleDisconnectCheck(UuidValue partieId, Duration delay) {
    _schedule(
      delay,
      (session) => ServerGame.checkDisconnect(session, partieId),
    );
  }

  @override
  void scheduleBotMove(UuidValue partieId, int moveCount, Duration delay) {
    _schedule(
      delay,
      (session) => ServerGame.playBotMove(session, partieId, moveCount),
    );
  }

  /// Annule tous les rappels en attente — pour les tests, qui arrêtent le
  /// serveur alors que des parties sont encore en cours.
  void cancelAll() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  void _schedule(Duration delay, Future<void> Function(Session) action) {
    late final Timer timer;
    timer = Timer(delay, () async {
      _timers.remove(timer);
      // Session propre : celle de l'appel qui a programmé le rappel est
      // fermée depuis longtemps. `withSession` journalise déjà l'erreur ; on
      // l'avale ici pour ne pas laisser d'erreur non gérée dans la zone.
      try {
        await Serverpod.instance.withSession(action);
      } catch (_) {}
    });
    _timers.add(timer);
  }
}
