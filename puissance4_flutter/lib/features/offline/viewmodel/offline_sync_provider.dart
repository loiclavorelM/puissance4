import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/offline_game_repository.dart';
import '../model/offline_sync_session_holder.dart';
import '../model/server_connection_tracker.dart';
import 'server_connection_provider.dart';

final offlineSyncSessionHolderProvider = Provider<OfflineSyncSessionHolder>(
  (ref) => OfflineSyncSessionHolder(),
);

/// Déclenche `syncIfOpen()` à chaque retour de connexion serveur — sans ça,
/// une écriture locale faite hors-ligne ne remonte qu'à la prochaine action
/// qui appelle `syncOnce()` explicitement (ex. le bouton dev "Simuler une
/// partie"), jamais toute seule. `void` : pas d'état à exposer, juste un
/// effet de bord à garder vivant — `_MainShell` le `ref.watch` une fois pour
/// ça (voir main.dart), le même schéma que `AuthViewModel`.
final offlineSyncOnReconnectProvider = Provider<void>((ref) {
  ref.listen(serverConnectionTrackerProvider, (previous, next) {
    if (next.status == ServerConnectionStatus.connected) {
      unawaited(ref.read(offlineSyncSessionHolderProvider).syncIfOpen());
    }
  });
});

final offlineGameRepositoryProvider = Provider<OfflineGameRepository>(
  (ref) => OfflineGameRepository(ref.watch(offlineSyncSessionHolderProvider)),
);
