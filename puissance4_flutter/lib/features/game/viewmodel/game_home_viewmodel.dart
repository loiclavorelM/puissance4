import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/viewmodel/auth_viewmodel.dart';

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

/// Pas encore de vrai profil/stats côté serveur (E2 profil, E9 historique
/// pas construits) : pseudo invité si disponible, sinon générique, et des
/// stats à zéro plutôt que d'inventer un endpoint hors périmètre.
final gameHomeViewModelProvider = Provider<GameHomeState>((ref) {
  final auth = ref.watch(authViewModelProvider);
  return GameHomeState(
    username: auth.guestProfile?.username ?? 'Joueur',
    elo: 1000,
    parties: 0,
    victoires: 0,
  );
});
