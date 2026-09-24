import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'game_stream.dart';
import 'server_game.dart';

/// Partie serveur en cours, quel que soit le mode (Multi ou Classé) : la
/// suivre, y jouer, l'abandonner. Les parties naissent ailleurs
/// (`MultiplayerEndpoint`, `RankedEndpoint`) ; voir `server_game.dart` pour
/// les garanties de fin.
class GameEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Partie serveur en cours de l'appelant (à reprendre par [watchPartie]),
  /// ou `null`.
  Future<UuidValue?> getActivePartie(Session session) async {
    final me = await ServerGame.requireUser(session);
    return (await ServerGame.findActivePartie(session, me.id!))?.id;
  }

  /// Suit la partie : `gameStarted` (photo complète) puis les événements, ou
  /// directement `gameOver` si elle est déjà terminée. Sert aussi à revenir
  /// après une coupure, dans le délai de grâce.
  Stream<GameEvent> watchPartie(Session session, UuidValue partieId) =>
      GameStream(
        session,
        (stream) => followPartie(session, stream, partieId),
      ).events;

  Future<void> playMove(
    Session session,
    UuidValue partieId,
    int column,
  ) async {
    final me = await ServerGame.requireUser(session);
    await ServerGame.playMove(session, partieId, me, column);
  }

  Future<void> abandon(Session session, UuidValue partieId) async {
    final me = await ServerGame.requireUser(session);
    await ServerGame.abandon(session, partieId, me);
  }
}
