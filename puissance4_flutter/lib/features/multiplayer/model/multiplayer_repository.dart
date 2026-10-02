import 'package:puissance4_client/puissance4_client.dart';

import '../../../client.dart';

/// Salles d'attente Multi (`MultiplayerEndpoint`). Les deux streams
/// continuent avec la partie une fois l'adversaire arrivé ; les annuler
/// avant ferme la salle. La partie elle-même passe par
/// `ServerGameRepository` (`GameEndpoint`).
class MultiplayerRepository {
  /// Une salle [isPublic] apparaît dans le lobby des autres joueurs.
  Stream<GameEvent> hostRoom({bool isPublic = false}) =>
      client.multiplayer.hostRoom(isPublic);

  Stream<GameEvent> joinRoom(String code) => client.multiplayer.joinRoom(code);

  /// Salles publiques ouvertes (sauf la sienne), à jour en temps réel.
  Stream<List<LobbyRoom>> watchLobby() =>
      client.multiplayer.watchLobby().map((lobby) => lobby.rooms);
}
