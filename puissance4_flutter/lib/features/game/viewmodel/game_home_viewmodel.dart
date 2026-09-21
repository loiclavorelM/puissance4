import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../profile/viewmodel/profile_provider.dart';

/// État affiché en tête de l'écran Jouer (maquette "Accueil").
class GameHomeState {
  const GameHomeState({
    required this.username,
    required this.elo,
    required this.parties,
    required this.victoires,
  });

  final String username;
  final int elo;
  final int parties;
  final int victoires;
}

/// Pseudo invité local / placeholder tant que le vrai profil n'a pas encore
/// été chargé (démarrage, erreur réseau) ou qu'on est en `localGuest` (pas
/// d'`authUserId`, donc pas de profil serveur du tout).
final gameHomeViewModelProvider = Provider<GameHomeState>((ref) {
  final auth = ref.watch(authViewModelProvider);
  final profile = ref.watch(myProfileProvider).valueOrNull;
  return GameHomeState(
    username: profile?.username ?? auth.guestProfile?.username ?? 'Joueur',
    elo: profile?.elo ?? 1000,
    parties: profile?.nbParties ?? 0,
    victoires: profile?.nbVictoires ?? 0,
  );
});
