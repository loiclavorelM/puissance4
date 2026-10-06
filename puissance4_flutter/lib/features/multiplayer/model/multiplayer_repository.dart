import 'package:puissance4_client/puissance4_client.dart';

import '../../../client.dart';

/// Salles d'attente Multi (`MultiplayerEndpoint`). Les deux streams
/// continuent avec la partie une fois l'adversaire arrivé ; les annuler
/// avant ferme la salle. La partie elle-même passe par
/// `ServerGameRepository` (`GameEndpoint`).
class MultiplayerRepository {
  /// Une salle [isPublic] apparaît dans le lobby des autres joueurs. Avec
  /// [challengeUserId], c'est un défi réservé à cet ami (E15).
  Stream<GameEvent> hostRoom({
    bool isPublic = false,
    UuidValue? challengeUserId,
  }) => client.multiplayer.hostRoom(isPublic, challengeUserId: challengeUserId);

  Stream<GameEvent> joinRoom(String code) => client.multiplayer.joinRoom(code);

  /// Salles publiques ouvertes (sauf la sienne), à jour en temps réel.
  Stream<List<LobbyRoom>> watchLobby() =>
      client.multiplayer.watchLobby().map((lobby) => lobby.rooms);
}
