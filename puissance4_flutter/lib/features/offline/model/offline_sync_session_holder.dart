import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_offline_sync_client/serverpod_offline_sync_client.dart';

import '../../../client.dart';

/// Détient (et réutilise) la session `serverpod_offline_sync` de l'appareil
/// — un fichier SQLite persistant contenant les modèles `database: sync`
/// (ex. [OfflineMatchResult]) créés hors-ligne.
///
/// `persistentUserId` DOIT être l'`authUserId` du compte authentifié : le
/// serveur ne synchronise que les spaces qu'il reconnaît comme appartenant
/// à l'utilisateur authentifié (vérifié empiriquement — un id local
/// arbitraire crée un space que le serveur ignore silencieusement, sans
/// erreur). Une session ne peut donc être ouverte que si `client.auth` a un
/// utilisateur authentifié (y compris anonyme) ; pas de mode 100% hors-ligne
/// pour ce modèle, limitation acceptée pour l'instant.
class OfflineSyncSessionHolder {
  // Le Future lui-même est mis en cache (pas seulement la session une fois
  // résolue) : deux appels concurrents à getOrCreate doivent attendre la
  // même création plutôt que d'appeler `createSyncSession` chacun de son
  // côté — sinon le serveur voit deux enregistrements concurrents du même
  // space et l'un des deux échoue avec une violation de contrainte unique
  // (observé en test).
  Future<OfflineSyncDatabaseSession>? _sessionFuture;

  Future<OfflineSyncDatabaseSession> getOrCreate() {
    final authUserId = client.auth.authInfo?.authUserId;
    if (authUserId == null) {
      throw StateError(
        'Impossible d\'ouvrir une session de synchro hors-ligne sans '
        'authUserId : connecte-toi (même anonyme) au préalable.',
      );
    }
    return _sessionFuture ??= _open(authUserId);
  }

  Future<OfflineSyncDatabaseSession> _open(UuidValue authUserId) async {
    return client.createSyncSession(
      await _resolveDatabasePath(),
      isDebugMode: kDebugMode,
      persistentUserId: authUserId,
    );
  }

  /// Ferme la session courante et supprime le fichier SQLite local —
  /// utilisé à la déconnexion pour qu'un changement de compte sur le même
  /// appareil ne réutilise pas une session mise en cache pour l'ancien
  /// `authUserId`.
  Future<void> closeAndWipe() async {
    final pending = _sessionFuture;
    _sessionFuture = null;
    if (pending != null) {
      try {
        await (await pending).close();
      } catch (_) {
        // La session n'a jamais fini de s'ouvrir — rien à fermer.
      }
    }
    if (kIsWeb) return;
    final path = await _resolveDatabasePath();
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  Future<String> _resolveDatabasePath() async {
    if (kIsWeb) return 'offline_sync.db';
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'offline_sync.db');
  }
}
