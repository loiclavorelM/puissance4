import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../offline/viewmodel/offline_sync_provider.dart';
import '../model/history_item.dart';
import '../model/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(),
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

/// Fusionne les deux sources pertinentes pour le filtre courant (serveur
/// pour Multi/Classé, session de synchro locale pour Normal), triées par
/// date décroissante. Vide tant qu'il n'y a pas de session serveur — même
/// limitation déjà acceptée ailleurs pour la synchro hors-ligne.
final historyListProvider = FutureProvider<List<HistoryItem>>((ref) async {
  final filter = ref.watch(historyFilterProvider);
  final isAuthenticated =
      ref.watch(authViewModelProvider).status == AuthStatus.serverAuthenticated;
  if (!isAuthenticated) return const [];

  final repository = ref.read(historyRepositoryProvider);
  final fetches = <Future<List<HistoryItem>>>[];

  if (filter != EnumType.normal) {
    fetches.add(repository.fetchServerHistory(typePartie: filter));
  }
  if (filter == null || filter == EnumType.normal) {
    fetches.add(
      ref
          .read(offlineSyncSessionHolderProvider)
          .getOrCreate()
          .then(repository.fetchOfflineHistory),
    );
  }

  final results = await Future.wait(fetches);
  return results.expand((r) => r).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});
