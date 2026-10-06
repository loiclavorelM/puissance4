import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../client.dart';
import '../../../core/l10n/l10n.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../offline/viewmodel/local_cache_provider.dart';
import '../../profile/viewmodel/profile_provider.dart';
import '../../settings/viewmodel/locale_provider.dart';
import '../model/friends_repository.dart';

final friendsRepositoryProvider = Provider<FriendsRepository>(
  (ref) => FriendsRepository(ref.watch(localCacheProvider)),
);

/// Qui peut utiliser l'onglet Amis (E15) : seuls les comptes email.
enum FriendsAccess {
  /// Profil pas encore connu.
  loading,

  /// Invité hors-ligne (`AuthStatus.localGuest`) : pas de compte serveur.
  localGuest,

  /// Invité connecté en anonyme : peut créer un compte (US0.2).
  guest,

  member,
}

final friendsAccessProvider = Provider<FriendsAccess>((ref) {
  final status = ref.watch(authViewModelProvider).status;
  if (status == AuthStatus.localGuest) return FriendsAccess.localGuest;
  if (status != AuthStatus.serverAuthenticated) return FriendsAccess.loading;
  final profile = ref.watch(myProfileProvider);
  return switch (profile.valueOrNull?.isGuest) {
    true => FriendsAccess.guest,
    false => FriendsAccess.member,
    // Profil illisible (hors-ligne sans cache) : l'onglet affiche sa propre
    // erreur de chargement.
    null when profile.hasError => FriendsAccess.member,
    null => FriendsAccess.loading,
  };
});

/// Amis, demandes et code ami — `null` hors compte email. Cache d'abord,
/// puis serveur ; relancé sur chaque `friendsChanged` temps réel.
final friendsOverviewProvider = StreamProvider<FriendsOverviewDto?>((ref) {
  final authUserId = client.auth.authInfo?.authUserId;
  if (ref.watch(friendsAccessProvider) != FriendsAccess.member ||
      authUserId == null) {
    return Stream.value(null);
  }
  return ref.read(friendsRepositoryProvider).watchOverview(authUserId);
});

/// Sous-onglet de l'onglet Amis à afficher, demandé depuis un autre écran
/// (ex. « Ajouter des amis » du Classement) — remis à `null` une fois
/// affiché.
final friendsTabRequestProvider =
    NotifierProvider<FriendsTabRequestViewModel, int?>(
      FriendsTabRequestViewModel.new,
    );

class FriendsTabRequestViewModel extends Notifier<int?> {
  @override
  int? build() => null;

  void open(int tabIndex) => state = tabIndex;

  void clear() => state = null;
}

/// Défis reçus encore ouverts (E15, US15.5) — vide hors compte email.
/// Relancé sur chaque `challengesChanged` temps réel.
final friendChallengesProvider = FutureProvider<List<FriendChallengeDto>>((
  ref,
) async {
  if (ref.watch(friendsAccessProvider) != FriendsAccess.member) return [];
  return ref.read(friendsRepositoryProvider).challenges();
});

/// « Rencontrés récemment » de l'onglet Ajouter : derniers adversaires
/// Multi, avec leur relation.
final recentOpponentsProvider =
    FutureProvider.autoDispose<List<PlayerSearchResultDto>>(
      (ref) => ref.read(friendsRepositoryProvider).recentOpponents(),
    );

/// Badge de l'onglet Amis et du sous-onglet Demandes.
final incomingFriendRequestCountProvider = Provider<int>(
  (ref) => ref.watch(friendsOverviewProvider).valueOrNull?.incoming.length ?? 0,
);

final friendActionsProvider =
    NotifierProvider<FriendActionsViewModel, Set<UuidValue>>(
      FriendActionsViewModel.new,
    );

/// Actions sur les demandes et les amis. L'état est l'ensemble des joueurs
/// (ou demandes) dont une action est en cours, pour griser leurs boutons.
/// Chaque action renvoie le message à afficher (succès ou refus), `null` si
/// rien à dire.
class FriendActionsViewModel extends Notifier<Set<UuidValue>> {
  @override
  Set<UuidValue> build() => const {};

  Future<String?> sendRequest(FriendUserDto player) =>
      _run(player.userId, (repository, l10n) async {
        final friendship = await repository.sendRequest(player.userId);
        // Il nous avait déjà envoyé une demande : la nôtre l'a acceptée.
        return friendship.status == EnumFriendshipStatus.accepted
            ? l10n.friendAccepted(player.username)
            : l10n.friendRequestSent(player.username);
      });

  Future<String?> accept(FriendshipDto request) =>
      _run(request.id, (repository, l10n) async {
        await repository.accept(request.id);
        return l10n.friendAccepted(request.other.username);
      });

  Future<String?> decline(FriendshipDto request) =>
      _run(request.id, (repository, _) async {
        await repository.decline(request.id);
        return null;
      });

  Future<String?> cancel(UuidValue friendshipId) =>
      _run(friendshipId, (repository, _) async {
        await repository.cancel(friendshipId);
        return null;
      });

  /// Refuse le défi [challenge] : la salle de l'ami se ferme.
  Future<String?> declineChallenge(FriendChallengeDto challenge) =>
      _run(challenge.from.userId, (repository, _) async {
        await repository.declineChallenge(challenge.code);
        return null;
      });

  Future<String?> remove(FriendUserDto friend) =>
      _run(friend.userId, (repository, _) async {
        await repository.remove(friend.userId);
        return null;
      });

  Future<String?> _run(
    UuidValue key,
    Future<String?> Function(FriendsRepository, AppLocalizations) action,
  ) async {
    if (state.contains(key)) return null;
    state = {...state, key};
    final l10n = ref.read(l10nProvider);
    try {
      return await action(ref.read(friendsRepositoryProvider), l10n);
    } on FriendsException catch (e) {
      return friendsErrorMessage(l10n, e.reason);
    } catch (_) {
      return l10n.serverUnreachableLater;
    } finally {
      state = {...state}..remove(key);
      // Sans attendre l'événement temps réel, au cas où le stream serait
      // coupé.
      ref
        ..invalidate(friendsOverviewProvider)
        ..invalidate(friendChallengesProvider)
        ..invalidate(recentOpponentsProvider);
    }
  }
}

String friendsErrorMessage(AppLocalizations l10n, EnumFriendsError reason) =>
    switch (reason) {
      EnumFriendsError.guestNotAllowed => l10n.friendsGuestMessage,
      EnumFriendsError.userNotFound => l10n.friendsErrorUserNotFound,
      EnumFriendsError.cannotAddSelf => l10n.friendsErrorSelf,
      EnumFriendsError.alreadyFriends => l10n.friendsErrorAlreadyFriends,
      EnumFriendsError.requestAlreadySent => l10n.friendsErrorAlreadySent,
      EnumFriendsError.requestNotFound => l10n.friendsErrorRequestNotFound,
      EnumFriendsError.notFriends => l10n.friendsErrorNotFriends,
      EnumFriendsError.tooManyFriends => l10n.friendsErrorTooMany,
      EnumFriendsError.challengeNotFound => l10n.challengeGone,
    };

/// Recherche de l'onglet « Ajouter » : [results] vaut `null` tant que la
/// saisie est trop courte pour lancer une recherche.
class FriendSearchState {
  const FriendSearchState({this.query = '', this.results});

  final String query;
  final AsyncValue<List<PlayerSearchResultDto>>? results;
}

final friendSearchProvider =
    NotifierProvider.autoDispose<FriendSearchViewModel, FriendSearchState>(
      FriendSearchViewModel.new,
    );

class FriendSearchViewModel extends AutoDisposeNotifier<FriendSearchState> {
  /// Mêmes seuils que `FriendsEndpoint.minSearchLength` (un code ami fait
  /// 6 caractères, donc passe aussi).
  static const minLength = 3;
  static const debounce = Duration(milliseconds: 350);

  Timer? _timer;

  /// Numéro de la dernière recherche : une réponse plus ancienne arrivée
  /// en retard est ignorée.
  var _generation = 0;

  @override
  FriendSearchState build() {
    ref.onDispose(() => _timer?.cancel());
    return const FriendSearchState();
  }

  void setQuery(String query) {
    _timer?.cancel();
    _generation++;
    if (query.trim().length < minLength) {
      state = FriendSearchState(query: query);
      return;
    }
    state = FriendSearchState(query: query, results: const AsyncLoading());
    _timer = Timer(debounce, refresh);
  }

  /// Relance la recherche en cours (ex. après une demande envoyée, pour
  /// mettre à jour la relation affichée).
  Future<void> refresh() async {
    final query = state.query.trim();
    if (query.length < minLength) return;
    final generation = ++_generation;
    final results = await AsyncValue.guard(
      () => ref.read(friendsRepositoryProvider).search(query),
    );
    if (generation == _generation) {
      state = FriendSearchState(query: state.query, results: results);
    }
  }
}
