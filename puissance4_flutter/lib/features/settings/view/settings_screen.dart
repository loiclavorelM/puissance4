import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../offline/view/server_connection_indicator.dart';

/// Onglet "Réglages" (E2/E11) — pas encore implémenté, mais garde les deux
/// éléments déjà fonctionnels déplacés de l'ancien menu placeholder :
/// l'indicateur de connexion serveur et la déconnexion (cf. maquette, qui
/// place justement "Se déconnecter" ici).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            const Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: ServerConnectionIndicator(),
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
                      onPressed: () =>
                          ref.read(authViewModelProvider.notifier).signOut(),
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
