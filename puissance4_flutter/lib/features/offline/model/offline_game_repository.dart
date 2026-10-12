import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:serverpod_offline_sync_client/serverpod_offline_sync_client.dart';

import '../../../client.dart';
import 'offline_sync_session_holder.dart';

/// Écrit les parties Normal (`OfflineMatchResult`) dans la session de synchro
/// locale — marche sans réseau, la remontée au serveur se fait en
/// best-effort (en fin de partie, puis à chaque reconnexion via
/// `offlineSyncOnReconnectProvider`).
class OfflineGameRepository {
  OfflineGameRepository(this._sessionHolder);

  final OfflineSyncSessionHolder _sessionHolder;

  /// Écritures en file, dans l'ordre d'appel : chaque `updateRow` réécrit
  /// toute la ligne, donc un [recordMoves] encore en cours écraserait un
  /// [finishGame] arrivé entre-temps (partie restée `inProgress`, résultat
  /// perdu).
  Future<void> _writes = Future.value();

  Future<T> _inOrder<T>(Future<T> Function() write) {
    final result = _writes.then((_) => write());
    _writes = result.then((_) {}, onError: (_) {});
    return result;
  }

  /// Crée la partie à l'état `inProgress` et renvoie son id.
  ///
  /// Les parties restées `inProgress` (app fermée en pleine partie) passent
  /// d'abord en `abandoned` : pas de partie fantôme locale, et l'Historique
  /// les ignore déjà (il ne lit que `finished`).
  Future<UuidValue> createGame({
    required BotLevel bot,
    required EnumColor playedAs,
  }) => _inOrder(() async {
    final session = await _sessionHolder.getOrCreate();
    final stale = await OfflineMatchResult.db.find(
      session,
      where: (t) => t.status.equals(EnumStatut.inProgress),
    );
    for (final row in stale) {
      await OfflineMatchResult.db.updateRow(
        session,
        row.copyWith(status: EnumStatut.abandoned),
      );
    }
    final row = await OfflineMatchResult.db.insertRow(
      session,
      OfflineMatchResult(
        status: EnumStatut.inProgress,
        botId: UuidValue.fromString(bot.id),
        botName: bot.name,
        playedAs: playedAs,
        moves: const [],
        playedAt: DateTime.now(),
      ),
    );
    return row.id!;
  });

  Future<OfflineMatchResult?> findGame(UuidValue id) async {
    final session = await _sessionHolder.getOrCreate();
    return OfflineMatchResult.db.findById(session, id);
  }

  /// Enregistre les coups au fil de la partie (replay, E14). Sans effet une
  /// fois la partie close.
  Future<void> recordMoves(UuidValue id, List<int> moves) => _inOrder(() async {
    final session = await _sessionHolder.getOrCreate();
    final row = await _require(session, id);
    if (row.status != EnumStatut.inProgress) return;
    await OfflineMatchResult.db.updateRow(session, row.copyWith(moves: moves));
  });

  /// Clôt la partie : `finished` avec [result], ou `abandoned` si [result]
  /// est `null` (partie annulée).
  Future<void> finishGame(
    UuidValue id,
    EnumMatchResult? result,
    List<int> moves,
  ) async {
    final session = await _sessionHolder.getOrCreate();
    await _inOrder(() async {
      final row = await _require(session, id);
      await OfflineMatchResult.db.updateRow(
        session,
        row.copyWith(
          status: result == null ? EnumStatut.abandoned : EnumStatut.finished,
          result: result,
          moves: moves,
        ),
      );
    });
    if (result == null) return;
    try {
      await client.offlineSync.syncOnce(session);
    } on ServerpodClientNetworkException {
      // Déjà enregistrée localement — sera synchronisée à la reconnexion.
    } on MethodStreamException {
      // Idem — syncOnce ouvre un method stream (WebSocket), ses échecs
      // réseau remontent ainsi, pas en ServerpodClientNetworkException.
    }
  }

  Future<OfflineMatchResult> _require(
    OfflineSyncDatabaseSession session,
    UuidValue id,
  ) async {
    final row = await OfflineMatchResult.db.findById(session, id);
    if (row == null) {
      throw StateError('Partie hors-ligne $id introuvable.');
    }
    return row;
  }
}
