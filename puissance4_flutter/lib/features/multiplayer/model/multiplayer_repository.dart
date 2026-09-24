import 'package:puissance4_client/puissance4_client.dart';

import '../../../client.dart';

/// Salles d'attente Multi (`MultiplayerEndpoint`). Les deux streams
/// continuent avec la partie une fois l'adversaire arrivé ; les annuler
/// avant ferme la salle. La partie elle-même passe par
/// `ServerGameRepository` (`GameEndpoint`).
class MultiplayerRepository {
  Stream<GameEvent> hostRoom() => client.multiplayer.hostRoom();

  Stream<GameEvent> joinRoom(String code) => client.multiplayer.joinRoom(code);
}
