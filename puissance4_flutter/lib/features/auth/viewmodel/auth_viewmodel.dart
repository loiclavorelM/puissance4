import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../client.dart';
import '../../offline/model/server_connection_tracker.dart';
import '../../offline/viewmodel/local_cache_provider.dart';
import '../../offline/viewmodel/offline_sync_provider.dart';
import '../../offline/viewmodel/server_connection_provider.dart';
import '../model/guest_profile.dart';
import '../model/guest_repository.dart';

enum AuthStatus { loading, unauthenticated, serverAuthenticated, localGuest }

class AuthState {
  const AuthState({required this.status, this.guestProfile});

  static const initial = AuthState(status: AuthStatus.loading);

  final AuthStatus status;
  final GuestProfile? guestProfile;
}

final guestRepositoryProvider = Provider<GuestRepository>(
  (ref) => GuestRepository(),
);

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

/// Owns the app's sign-in state: a real Serverpod session
/// ([AuthStatus.serverAuthenticated]), a device-local guest profile
/// ([AuthStatus.localGuest]) used when "Continuer sans compte" can't reach
/// the server, or neither yet ([AuthStatus.unauthenticated]).
class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() {
    client.auth.authInfoListenable.addListener(_onAuthInfoChanged);
    ref.onDispose(() {
      client.auth.authInfoListenable.removeListener(_onAuthInfoChanged);
    });

    // Silently promotes a local guest to a real (anonymous) server session
    // as soon as the server becomes reachable — no loading spinner, no
    // error on failure, since the player is already happily using the app
    // as a guest and this is a background upgrade, not something they
    // asked for. Reacts to actual server reachability (real RPC outcomes),
    // not raw OS connectivity — see ServerConnectionTracker.
    ref.listen(serverConnectionTrackerProvider, (previous, next) {
      if (next.status == ServerConnectionStatus.connected &&
          state.status == AuthStatus.localGuest) {
        unawaited(_tryAnonymousLogin());
      }
    });

    if (client.auth.isAuthenticated) {
      return const AuthState(status: AuthStatus.serverAuthenticated);
    }

    _loadPersistedGuest();
    return AuthState.initial;
  }

  GuestRepository get _repository => ref.read(guestRepositoryProvider);

  void _onAuthInfoChanged() {
    if (client.auth.isAuthenticated) {
      state = const AuthState(status: AuthStatus.serverAuthenticated);
    }
  }

  /// Attempts the server's anonymous sign-in with a short timeout. Returns
  /// whether it succeeded; on success, [_onAuthInfoChanged] moves [state] to
  /// [AuthStatus.serverAuthenticated] on its own.
  Future<bool> _tryAnonymousLogin() async {
    final controller = AnonymousAuthController(client: client);
    try {
      await controller.login().timeout(const Duration(seconds: 5));
      return controller.state == AnonymousAuthState.authenticated;
    } catch (_) {
      return false;
    } finally {
      controller.dispose();
    }
  }

  Future<void> _loadPersistedGuest() async {
    final profile = await _repository.read();
    // A real session may have appeared while we were reading storage.
    if (client.auth.isAuthenticated) return;
    state = profile != null
        ? AuthState(status: AuthStatus.localGuest, guestProfile: profile)
        : const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Tries the server's anonymous sign-in; on any failure (no network,
  /// server unreachable, timeout) falls back to a locally persisted guest
  /// profile instead of surfacing an error.
  Future<void> continueAsGuest() async {
    state = AuthState(
      status: AuthStatus.loading,
      guestProfile: state.guestProfile,
    );

    final success = await _tryAnonymousLogin();
    if (!success) {
      await _fallBackToLocalGuest();
    }
    // On success, authInfoListenable's listener moves us to
    // serverAuthenticated.
  }

  Future<void> _fallBackToLocalGuest() async {
    final existing = await _repository.read();
    final profile = existing ?? GuestProfile.generate();
    if (existing == null) {
      await _repository.save(profile);
    }
    state = AuthState(status: AuthStatus.localGuest, guestProfile: profile);
  }

  Future<void> signOut() async {
    switch (state.status) {
      case AuthStatus.serverAuthenticated:
        // Don't block on the network call: signOutDevice() first closes
        // streaming connections, which can hang indefinitely offline — sign
        // out should feel instant regardless of connectivity. The server
        // revocation + local session cleanup happen best-effort in the
        // background either way.
        state = const AuthState(status: AuthStatus.unauthenticated);
        unawaited(client.auth.signOutDevice());
        unawaited(ref.read(offlineSyncSessionHolderProvider).closeAndWipe());
        unawaited(ref.read(localCacheProvider).clear());
      case AuthStatus.localGuest:
        // Don't block on storage I/O: sign-out should feel instant, and the
        // guest profile no longer matters once we're unauthenticated even
        // if clearing it lags behind.
        state = const AuthState(status: AuthStatus.unauthenticated);
        unawaited(_repository.clear());
      case AuthStatus.loading:
      case AuthStatus.unauthenticated:
        break;
    }
  }
}
