import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../client.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../offline/viewmodel/local_cache_provider.dart';
import '../model/leaderboard_repository.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
  (ref) => LeaderboardRepository(ref.watch(localCacheProvider)),
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
/// acceptée pour `historyListProvider`/`myProfileProvider`. Cache d'abord,
/// puis serveur ; relancé sur chaque `leaderboardChanged` temps réel.
final leaderboardProvider = StreamProvider<LeaderboardState?>((ref) {
  final isAuthenticated =
      ref.watch(authViewModelProvider).status == AuthStatus.serverAuthenticated;
  final authUserId = client.auth.authInfo?.authUserId;
  if (!isAuthenticated || authUserId == null) return Stream.value(null);

  return ref
      .read(leaderboardRepositoryProvider)
      .watchLeaderboard(authUserId)
      .map(
        (snapshot) => LeaderboardState(
          entries: snapshot.entries,
          myRank: snapshot.myRank,
        ),
      );
});
