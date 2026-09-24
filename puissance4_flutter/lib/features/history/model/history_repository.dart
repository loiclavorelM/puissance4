import 'package:puissance4_client/puissance4_client.dart';
import 'package:serverpod_offline_sync_client/serverpod_offline_sync_client.dart';

import '../../../client.dart';
import '../../offline/model/local_cache.dart';
import 'history_item.dart';

/// Lit les deux sources qui composent l'Historique (E9) : `Partie`
/// (Multi/Classé, serveur) et `OfflineMatchResult` (Normal, miroir local déjà
/// synchronisé) — voir le plan Historique pour pourquoi elles restent deux
/// tables distinctes plutôt que d'être fusionnées en base.
class HistoryRepository {
  HistoryRepository(this._cache);

  final LocalCache _cache;

  /// Toutes les parties Multi/Classé (pas de filtre serveur) : le filtre des
  /// chips est appliqué côté client, ce qui le rend instantané et permet de
  /// n'avoir qu'une seule entrée en cache.
  Stream<List<HistoryItem>> watchServerHistory(UuidValue authUserId) => _cache
      .cacheThenNetwork<List<HistoryDto>>(
        authUserId: authUserId,
        name: 'history.server',
        fetch: () => client.history.getListHistories(limit: 200, offset: 0),
        decode: (json) => (json as List)
            .map((e) => HistoryDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        encode: (dtos) => dtos.map((dto) => dto.toJson()).toList(),
      )
      .map((dtos) => dtos.map(HistoryItem.fromDto).toList());

  /// Émet d'abord le miroir SQLite local tel quel (instantané, marche
  /// hors-ligne), puis de nouveau après un `syncOnce` — qui ramène ce qui
  /// existe déjà côté serveur pour cet utilisateur (ex. après une
  /// réinstallation, ou depuis un autre appareil). Best-effort : si le
  /// réseau manque, on s'arrête au miroir local.
  Stream<List<HistoryItem>> watchOfflineHistory(
    OfflineSyncDatabaseSession session,
  ) async* {
    yield await _readOffline(session);
    try {
      await client.offlineSync.syncOnce(session);
    } on ServerpodClientNetworkException {
      return;
    } on MethodStreamException {
      // syncOnce ouvre un method stream (WebSocket) : ses échecs réseau
      // remontent ainsi, pas en ServerpodClientNetworkException.
      return;
    }
    yield await _readOffline(session);
  }

  // Pas de tri ici : la session locale de synchro n'expose pas le même
  // opérateur `.desc()` que l'ORM serveur pour cette colonne — la fusion
  // avec les résultats serveur est de toute façon re-triée par date dans
  // `historyListProvider`.
  Future<List<HistoryItem>> _readOffline(
    OfflineSyncDatabaseSession session,
  ) async {
    // Les parties encore `inProgress` (en cours, ou abandonnées sans être
    // terminées) n'ont pas de résultat : pas leur place dans l'Historique.
    final rows = await OfflineMatchResult.db.find(
      session,
      where: (t) => t.status.equals(EnumStatut.finished),
    );
    return rows.map(HistoryItem.fromOfflineMatchResult).toList();
  }
}
