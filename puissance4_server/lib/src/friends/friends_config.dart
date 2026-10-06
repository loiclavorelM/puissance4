import 'presence_store.dart';

/// Réglages des Amis (E15). Passage en cluster (Redis) : remplacer
/// [presence] par une implémentation partagée (voir `PresenceStore`).
abstract final class FriendsConfig {
  static PresenceStore presence = InMemoryPresenceStore();

  /// Durée d'un défi : la salle privée ouverte pour l'ami se ferme ensuite.
  static Duration challengeLifetime = const Duration(minutes: 2);
}
