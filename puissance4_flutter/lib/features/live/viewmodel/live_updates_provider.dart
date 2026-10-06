import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../friends/viewmodel/friends_viewmodel.dart';
import '../../history/viewmodel/history_viewmodel.dart';
import '../../leaderboard/viewmodel/leaderboard_viewmodel.dart';
import '../../offline/model/server_connection_tracker.dart';
import '../../offline/viewmodel/server_connection_provider.dart';
import '../../profile/viewmodel/profile_provider.dart';
import '../model/live_updates_repository.dart';

final liveUpdatesRepositoryProvider = Provider<LiveUpdatesRepository>(
  (ref) => LiveUpdatesRepository(),
);

/// Garde un abonnement au stream temps réel du serveur tant qu'on a une
/// session serveur, et recharge (cache puis réseau) le profil, l'historique,
/// le classement ou les amis dès que le serveur annonce qu'ils ont changé —
/// ex. un autre joueur qui passe devant soi au classement.
///
/// Le stream tombe avec la connexion (WebSocket) : on se réabonne avec un
/// délai croissant, ou tout de suite au retour du serveur. Après une coupure
/// on recharge tout, puisqu'on a pu rater des événements entre-temps.
/// `void` : même schéma que `offlineSyncOnReconnectProvider`, gardé vivant
/// par un `ref.watch` dans `_MainShell`.
final liveUpdatesProvider = Provider<void>((ref) {
  final isAuthenticated =
      ref.watch(authViewModelProvider).status == AuthStatus.serverAuthenticated;
  if (!isAuthenticated) return;

  StreamSubscription<LiveEvent>? subscription;
  Timer? retryTimer;
  var retryDelay = const Duration(seconds: 2);
  var missedEvents = false;
  var disposed = false;

  void refreshAll() {
    ref.invalidate(myProfileProvider);
    ref.invalidate(serverHistoryProvider);
    ref.invalidate(leaderboardProvider);
    ref.invalidate(friendsOverviewProvider);
    ref.invalidate(friendChallengesProvider);
  }

  void onEvent(LiveEvent event) {
    // Le serveur répond : la connexion est rétablie.
    retryDelay = const Duration(seconds: 2);
    switch (event.type) {
      case EnumLiveEventType.profileChanged:
        ref.invalidate(myProfileProvider);
      case EnumLiveEventType.historyChanged:
        ref.invalidate(serverHistoryProvider);
      case EnumLiveEventType.leaderboardChanged:
        ref.invalidate(leaderboardProvider);
      case EnumLiveEventType.friendsChanged:
        ref.invalidate(friendsOverviewProvider);
      case EnumLiveEventType.challengesChanged:
        ref.invalidate(friendChallengesProvider);
      case EnumLiveEventType.lobbyChanged:
        // Propre au lobby Multi, qui a son stream (`lobbyRoomsProvider`).
        break;
    }
  }

  late void Function() subscribe;

  void scheduleRetry() {
    subscription = null;
    missedEvents = true;
    if (disposed || retryTimer != null) return;
    retryTimer = Timer(retryDelay, () {
      retryTimer = null;
      subscribe();
    });
    final doubled = retryDelay * 2;
    retryDelay = doubled > const Duration(seconds: 30)
        ? const Duration(seconds: 30)
        : doubled;
  }

  subscribe = () {
    if (disposed || subscription != null) return;
    if (missedEvents) {
      missedEvents = false;
      refreshAll();
    }
    subscription = ref
        .read(liveUpdatesRepositoryProvider)
        .watch()
        .listen(
          onEvent,
          onError: (_) => scheduleRetry(),
          onDone: scheduleRetry,
          cancelOnError: true,
        );
  };

  // Réabonnement immédiat quand le serveur redevient joignable, sans
  // attendre la fin du délai en cours.
  ref.listen(serverConnectionTrackerProvider, (previous, next) {
    if (next.status == ServerConnectionStatus.connected &&
        subscription == null) {
      retryTimer?.cancel();
      retryTimer = null;
      subscribe();
    }
  });

  ref.onDispose(() {
    disposed = true;
    retryTimer?.cancel();
    unawaited(subscription?.cancel());
  });

  subscribe();
});
