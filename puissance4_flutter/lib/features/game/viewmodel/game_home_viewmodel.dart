import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../profile/viewmodel/profile_provider.dart';
import '../../settings/viewmodel/locale_provider.dart';

/// État affiché en tête de l'écran Jouer (maquette "Accueil").
class GameHomeState {
  const GameHomeState({
    required this.username,
    required this.elo,
    required this.parties,
    required this.victoires,
    required this.isProfileLoading,
    required this.hasProfileError,
    this.thumbnailUrl,
  });

  final String username;

  /// Photo de profil (E2), `null` : initiales.
  final String? thumbnailUrl;
  final int elo;
  final int parties;
  final int victoires;

  /// `true` tant que `myProfileProvider` n'a pas encore résolu — distinct
  /// de `hasProfileError` pour que la vue puisse afficher un état de
  /// chargement plutôt qu'un message d'erreur trompeur.
  final bool isProfileLoading;

  /// `true` si le dernier appel à `myProfileProvider` a échoué (ex. réseau
  /// coupé) — les stats affichées sont alors des valeurs par défaut/invité,
  /// pas les vraies stats serveur.
  final bool hasProfileError;
}

/// Pseudo invité local / placeholder tant que le vrai profil n'a pas encore
/// été chargé (démarrage, erreur réseau) ou qu'on est en `localGuest` (pas
/// d'`authUserId`, donc pas de profil serveur du tout).
final gameHomeViewModelProvider = Provider<GameHomeState>((ref) {
  final auth = ref.watch(authViewModelProvider);
  final profileAsync = ref.watch(myProfileProvider);
  final profile = profileAsync.when(
    data: (profile) => profile,
    loading: () => null,
    error: (_, _) => null,
  );
  return GameHomeState(
    username:
        profile?.username ??
        auth.guestProfile?.username ??
        ref.watch(l10nProvider).defaultPlayerName,
    thumbnailUrl: profile?.thumbnailUrl,
    elo: profile?.elo ?? 1000,
    parties: profile?.nbParties ?? 0,
    victoires: profile?.nbVictoires ?? 0,
    isProfileLoading: profileAsync.isLoading,
    hasProfileError: profileAsync.hasError,
  );
});
