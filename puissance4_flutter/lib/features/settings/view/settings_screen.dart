import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../offline/view/server_connection_indicator.dart';

/// "Réglages" (E2/E11) — pas encore implémenté, mais garde les deux éléments
/// déjà fonctionnels déplacés de l'ancien menu placeholder : l'indicateur de
/// connexion serveur et la déconnexion (cf. maquette, qui place justement
/// "Se déconnecter" ici). Pas d'onglet dédié : poussé en route depuis
/// l'icône engrenage de l'écran Jouer (`_MainShell._openSettings`), d'où le
/// bouton retour explicite ci-dessous — pas de nav bar ici pour en sortir.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  const ServerConnectionIndicator(),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Réglages',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pas encore implémenté',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: () {
                        // `signOut()` passe `authViewModelProvider` à
                        // `unauthenticated` de façon synchrone (avant son
                        // premier `await`), donc `_AuthGate` a déjà
                        // basculé sur `LoginScreen` en dessous au moment
                        // du pop ci-après — sans ce pop, cette route
                        // poussée depuis l'icône engrenage (voir
                        // `_MainShell._openSettings`) resterait affichée
                        // par-dessus indéfiniment.
                        ref.read(authViewModelProvider.notifier).signOut();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.logout, color: Colors.white70),
                      label: const Text(
                        'Se déconnecter',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
