import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../auth/viewmodel/auth_viewmodel.dart';
import '../model/leaderboard_repository.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
  (ref) => LeaderboardRepository(),
);

/// Combine la page top-N et le rang du joueur courant — deux appels séparés
/// côté serveur (voir plan Classement) pour reproduire le "gap + ligne
/// détachée" du mockup sans requête de fenêtrage compliquée.
class LeaderboardState {
  const LeaderboardState({required this.entries, required this.myRank});

  final List<LeaderboardEntryDto> entries;
  final LeaderboardEntryDto myRank;
}

/// Vide tant qu'il n'y a pas de session serveur — même limitation déjà
/// acceptée pour `historyListProvider`/`myProfileProvider`.
final leaderboardProvider = FutureProvider<LeaderboardState?>((ref) async {
  final isAuthenticated =
      ref.watch(authViewModelProvider).status == AuthStatus.serverAuthenticated;
  if (!isAuthenticated) return null;

  final repository = ref.read(leaderboardRepositoryProvider);
  final results = await Future.wait([
    repository.fetchTop(),
    repository.fetchMyRank(),
  ]);
  return LeaderboardState(
    entries: results[0] as List<LeaderboardEntryDto>,
    myRank: results[1] as LeaderboardEntryDto,
  );
});
