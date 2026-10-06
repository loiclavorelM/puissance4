import 'package:serverpod/serverpod.dart';

/// Qui est en ligne (E15) : un joueur l'est tant qu'au moins un de ses
/// appareils garde ouvert le stream temps réel (`LiveEndpoint.watchUpdates`).
/// Seule pièce des Amis à dépendre du nombre de serveurs : en cluster
/// (Redis), une implémentation partagée remplace [InMemoryPresenceStore]
/// dans `friends_config.dart`.
abstract interface class PresenceStore {
  /// Un stream de [authUserId] s'ouvre. `true` s'il vient de passer en ligne.
  Future<bool> connect(UuidValue authUserId);

  /// Un stream de [authUserId] se ferme. `true` s'il vient de passer hors
  /// ligne.
  Future<bool> disconnect(UuidValue authUserId);

  /// Ceux de [authUserIds] qui sont en ligne.
  Future<Set<UuidValue>> onlineAmong(Iterable<UuidValue> authUserIds);
}

/// [PresenceStore] en mémoire : un compteur de streams par joueur. Vidé au
/// redémarrage du serveur, comme les streams eux-mêmes — les clients s'y
/// réabonnent aussitôt.
class InMemoryPresenceStore implements PresenceStore {
  final _streams = <UuidValue, int>{};

  @override
  Future<bool> connect(UuidValue authUserId) async {
    final count = (_streams[authUserId] ?? 0) + 1;
    _streams[authUserId] = count;
    return count == 1;
  }

  @override
  Future<bool> disconnect(UuidValue authUserId) async {
    final count = (_streams[authUserId] ?? 0) - 1;
    if (count > 0) {
      _streams[authUserId] = count;
      return false;
    }
    return _streams.remove(authUserId) != null;
  }

  @override
  Future<Set<UuidValue>> onlineAmong(Iterable<UuidValue> authUserIds) async =>
      authUserIds.where(_streams.containsKey).toSet();
}
