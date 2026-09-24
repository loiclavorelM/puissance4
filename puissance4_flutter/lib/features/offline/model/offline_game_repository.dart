import 'package:puissance4_client/puissance4_client.dart';
import 'package:serverpod_offline_sync_client/serverpod_offline_sync_client.dart';

import '../../../client.dart';
import 'offline_sync_session_holder.dart';

/// Écrit les parties Normal (`OfflineMatchResult`) dans la session de synchro
/// locale — marche sans réseau, la remontée au serveur se fait en
/// best-effort (ici, puis à chaque reconnexion via
/// `offlineSyncOnReconnectProvider`).
class OfflineGameRepository {
  OfflineGameRepository(this._sessionHolder);

  final OfflineSyncSessionHolder _sessionHolder;

  /// Crée la partie à l'état `inProgress` et renvoie son id.
  Future<UuidValue> createGame({
    required Bot bot,
    required EnumColor playedAs,
  }) async {
    final session = await _sessionHolder.getOrCreate();
    final row = await OfflineMatchResult.db.insertRow(
      session,
      OfflineMatchResult(
        status: EnumStatut.inProgress,
        botId: bot.id!,
        botName: bot.botName,
        playedAs: playedAs,
        moves: const [],
        playedAt: DateTime.now(),
      ),
    );
    return row.id!;
  }

  Future<void> finishGame(UuidValue id, EnumMatchResult result) async {
    final session = await _sessionHolder.getOrCreate();
    final row = await OfflineMatchResult.db.findById(session, id);
    if (row == null) {
      throw StateError('Partie hors-ligne $id introuvable.');
    }
    await OfflineMatchResult.db.updateRow(
      session,
      row.copyWith(status: EnumStatut.finished, result: result),
    );
    try {
      await client.offlineSync.syncOnce(session);
    } on ServerpodClientNetworkException {
      // Déjà enregistrée localement — sera synchronisée à la reconnexion.
    } on MethodStreamException {
      // Idem — syncOnce ouvre un method stream (WebSocket), ses échecs
      // réseau remontent ainsi, pas en ServerpodClientNetworkException.
    }
  }
}
