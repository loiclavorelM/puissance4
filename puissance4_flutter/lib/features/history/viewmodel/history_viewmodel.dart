import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../client.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../offline/viewmodel/local_cache_provider.dart';
import '../../offline/viewmodel/offline_sync_provider.dart';
import '../../game/viewmodel/game_viewmodel.dart';
import '../model/history_item.dart';
import '../model/history_replay_repository.dart';
import '../model/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(localCacheProvider)),
);

final historyReplayRepositoryProvider = Provider<HistoryReplayRepository>(
  (ref) => HistoryReplayRepository(
    ref.watch(serverGameRepositoryProvider),
    ref.watch(offlineGameRepositoryProvider),
  ),
);

/// Filtre sélectionné par les chips Tous/Normal/Classé/Multi — `null` = Tous.
class HistoryFilterNotifier extends Notifier<EnumType?> {
  @override
  EnumType? build() => null;

  void select(EnumType? typePartie) => state = typePartie;
}

final historyFilterProvider =
    NotifierProvider<HistoryFilterNotifier, EnumType?>(
      HistoryFilterNotifier.new,
    );

/// Parties Multi/Classé (serveur), cache d'abord — relancé sur chaque
/// `historyChanged` temps réel (voir `liveUpdatesProvider`).
final serverHistoryProvider = StreamProvider<List<HistoryItem>>((ref) {
  final isAuthenticated =
      ref.watch(authViewModelProvider).status == AuthStatus.serverAuthenticated;
  final authUserId = client.auth.authInfo?.authUserId;
  if (!isAuthenticated || authUserId == null) return Stream.value(const []);
  return ref.read(historyRepositoryProvider).watchServerHistory(authUserId);
});

/// Parties Normal (session de synchro locale), miroir local d'abord.
final offlineHistoryProvider = StreamProvider<List<HistoryItem>>((ref) async* {
  final isAuthenticated =
      ref.watch(authViewModelProvider).status == AuthStatus.serverAuthenticated;
  if (!isAuthenticated) {
    yield const [];
    return;
  }
  final session = await ref
      .read(offlineSyncSessionHolderProvider)
      .getOrCreate();
  yield* ref.read(historyRepositoryProvider).watchOfflineHistory(session);
});

/// Fusionne les deux sources pertinentes pour le filtre courant, triées par
/// date décroissante. Vide tant qu'il n'y a pas de session serveur — même
/// limitation déjà acceptée ailleurs pour la synchro hors-ligne. Changer de
/// filtre ne refait aucun appel : les deux sources sont déjà chargées.
final historyListProvider = Provider<AsyncValue<List<HistoryItem>>>((ref) {
  final filter = ref.watch(historyFilterProvider);
  final sources = [
    if (filter != EnumType.normal) ref.watch(serverHistoryProvider),
    if (filter == null || filter == EnumType.normal)
      ref.watch(offlineHistoryProvider),
  ];

  // Tant qu'une source n'a encore rien émis (ni cache ni réseau), on
  // attend ; une source en erreur sans aucune donnée fait échouer l'écran.
  for (final source in sources) {
    if (!source.hasValue) {
      return source.hasError
          ? AsyncError(source.error!, source.stackTrace!)
          : const AsyncLoading();
    }
  }

  final items =
      sources
          .expand((source) => source.requireValue)
          .where((item) => filter == null || item.mode == filter)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  return AsyncData(items);
});
