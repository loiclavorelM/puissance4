import 'package:puissance4_client/puissance4_client.dart';
import 'package:serverpod_offline_sync_client/serverpod_offline_sync_client.dart';

import '../../../client.dart';
import 'history_item.dart';

/// Lit les deux sources qui composent l'Historique (E9) : `Partie`
/// (Multi/Classé, serveur) et `OfflineMatchResult` (Normal, miroir local déjà
/// synchronisé) — voir le plan Historique pour pourquoi elles restent deux
/// tables distinctes plutôt que d'être fusionnées en base.
class HistoryRepository {
  Future<List<HistoryItem>> fetchServerHistory({EnumType? typePartie}) async {
    final dtos = await client.history.getListHistories(
      typePartie: typePartie,
      limit: 200,
      offset: 0,
    );
    return dtos.map(HistoryItem.fromDto).toList();
  }

  // Pas de tri ici : la session locale de synchro n'expose pas le même
  // opérateur `.desc()` que l'ORM serveur pour cette colonne — la fusion
  // avec les résultats serveur est de toute façon re-triée par date dans
  // `historyListProvider`.
  Future<List<HistoryItem>> fetchOfflineHistory(
    OfflineSyncDatabaseSession session,
  ) async {
    // `OfflineMatchResult.db.find` ne lit QUE le miroir SQLite local — sans
    // ce syncOnce, on ne voit que ce qu'un autre appel (ex. le bouton dev
    // "Simuler une partie") a synchronisé par hasard, jamais ce qui existe
    // déjà côté serveur pour cet utilisateur (ex. après une réinstallation,
    // ou depuis un autre appareil). Best-effort : si le réseau manque, on
    // affiche quand même le miroir local tel quel plutôt que planter
    // l'écran — mêmes exceptions que `_simulateMatch` (game_home_screen).
    try {
      await client.offlineSync.syncOnce(session);
    } on ServerpodClientNetworkException {
      // Pas de réseau — miroir local affiché tel quel.
    } on MethodStreamException {
      // syncOnce ouvre un method stream (WebSocket) : ses échecs réseau
      // remontent ainsi, pas en ServerpodClientNetworkException.
    }

    final rows = await OfflineMatchResult.db.find(session);
    return rows.map(HistoryItem.fromOfflineMatchResult).toList();
  }
}
