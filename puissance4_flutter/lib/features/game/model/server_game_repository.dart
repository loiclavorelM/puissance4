import 'package:puissance4_client/puissance4_client.dart';

import '../../../client.dart';

/// Appels communs aux parties jouées sur le serveur (Multi, Classé) —
/// `GameEndpoint`, plus le replay d'une partie serveur (`HistoryEndpoint`).
class ServerGameRepository {
  Stream<GameEvent> watchPartie(UuidValue partieId) =>
      client.game.watchPartie(partieId);

  Future<UuidValue?> getActivePartie() => client.game.getActivePartie();

  Future<void> playMove(UuidValue partieId, int column) =>
      client.game.playMove(partieId, column);

  Future<void> abandon(UuidValue partieId) => client.game.abandon(partieId);

  Future<ReplayDto> getReplay(UuidValue partieId) =>
      client.history.getReplay(idPartie: partieId);
}
