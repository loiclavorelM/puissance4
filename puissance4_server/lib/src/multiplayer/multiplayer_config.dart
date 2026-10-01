import 'room_store.dart';

/// Réglages des salles d'attente Multi. Le reste (délais, planificateur) est
/// commun à toutes les parties serveur : voir `ServerGameConfig`.
///
/// Passage en cluster (Redis) : remplacer [rooms] par une implémentation
/// partagée (voir `RoomStore`).
abstract final class MultiplayerConfig {
  static Duration roomLifetime = const Duration(minutes: 10);

  static RoomStore rooms = InMemoryRoomStore();
}
