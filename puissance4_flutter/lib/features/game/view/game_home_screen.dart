import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/initials.dart';
import '../../../core/widgets/coming_soon_tab.dart';
import '../../../client.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../bot/view/normal_mode_screen.dart';
import '../../profile/viewmodel/profile_provider.dart';
import '../viewmodel/game_home_viewmodel.dart';

/// Écran "Jouer" (onglet par défaut) — reprend `maquette-2.png` : résumé du
/// profil, stats, et les modes de jeu. Normal ouvre le choix du bot (E5) ;
/// Multijoueur ne mène encore nulle part (appui = SnackBar "Bientôt
/// disponible").
class GameHomeScreen extends ConsumerStatefulWidget {
  const GameHomeScreen({super.key, required this.onOpenSettings});

  /// Ouvre l'onglet Réglages — appelé par l'icône engrenage du header,
  /// géré par la coquille de navigation (`_MainShell`).
  final VoidCallback onOpenSettings;

  @override
  ConsumerState<GameHomeScreen> createState() => _GameHomeScreenState();
}

class _GameHomeScreenState extends ConsumerState<GameHomeScreen> {
  bool _isSimulatingPartie = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameHomeViewModelProvider);
    // `devSimulate` exige une session serveur : rien à simuler en
    // AuthStatus.localGuest (pas d'authUserId du tout).
    final isAuthenticated =
        ref.watch(authViewModelProvider).status ==
        AuthStatus.serverAuthenticated;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.card,
                child: Text(
                  initialsOf(state.username),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'ELO ${state.elo}',
                      style: const TextStyle(
                        color: AppColors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onOpenSettings,
                tooltip: 'Réglages',
                icon: const Icon(Icons.settings, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (state.hasProfileError)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                "Impossible de charger tes stats à jour — "
                "valeurs par défaut affichées.",
                style: TextStyle(color: AppColors.yellow, fontSize: 12),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: state.isProfileLoading ? '…' : '${state.parties}',
                  label: 'Parties',
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  value: state.isProfileLoading ? '…' : '${state.victoires}',
                  label: 'Victoires',
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  value: state.isProfileLoading ? '…' : '${state.elo}',
                  label: 'ELO',
                  color: AppColors.yellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'CHOISIS TON MODE',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            icon: Icons.lock,
            color: AppColors.primary,
            title: 'Normal',
            subtitle: 'Choisis la difficulté du bot',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NormalModeScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            icon: Icons.people,
            color: AppColors.green,
            title: 'Multijoueur',
            subtitle: 'Défie un ami en 1v1',
            onTap: () => showComingSoonSnackBar(context),
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          const Text(
            'Outil de dev — à retirer une fois le moteur de jeu (E4) fait',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 8),
          // Outil de dev temporaire : pas de vrai moteur de jeu (E4) pour
          // générer de vraies Partie, donc ce bouton permet de tester
          // nbParties/nbVictoires (ProfileEndpoint.getMyProfile) depuis
          // l'app. À retirer une fois E4 fait.
          ElevatedButton(
            onPressed: (_isSimulatingPartie || !isAuthenticated)
                ? null
                : _simulatePartie,
            child: const Text('Simuler une partie classée/multi (stats)'),
          ),
        ],
      ),
    );
  }

  Future<void> _simulatePartie() async {
    setState(() => _isSimulatingPartie = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await client.devSimulate.simulatePartie();
      ref.invalidate(myProfileProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Partie simulée — stats mises à jour')),
      );
    } catch (error) {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Erreur : $error')));
      }
    } finally {
      if (mounted) setState(() => _isSimulatingPartie = false);
    }
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}
