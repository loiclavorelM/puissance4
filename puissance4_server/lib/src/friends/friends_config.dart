import 'presence_store.dart';
import 'shake_matcher.dart';

/// Réglages des Amis (E15). Passage en cluster (Redis) : remplacer
/// [presence] et [shakes] par des implémentations partagées (voir
/// `PresenceStore`, `ShakeMatcher`).
abstract final class FriendsConfig {
  static PresenceStore presence = InMemoryPresenceStore();

  /// Durée d'un défi : la salle privée ouverte pour l'ami se ferme ensuite.
  static Duration challengeLifetime = const Duration(minutes: 2);

  static ShakeMatcher shakes = InMemoryShakeMatcher();

  /// Deux secousses à moins de cet écart sont appariées.
  static Duration shakeWindow = const Duration(seconds: 2);
}
