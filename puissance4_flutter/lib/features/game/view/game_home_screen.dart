import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../bot/view/normal_mode_screen.dart';
import '../../multiplayer/view/multiplayer_screen.dart';
import '../../ranked/view/ranked_screen.dart';
import '../../sensors/viewmodel/flat_provider.dart';
import '../../sensors/viewmodel/motion_sensors_provider.dart';
import '../model/game_launch.dart';
import '../viewmodel/game_home_viewmodel.dart';
import 'game_screen.dart';
import '../../../core/l10n/l10n.dart';
import '../../profile/view/profile_avatar.dart';

/// Écran "Jouer" (onglet par défaut) — reprend `maquette-2.png` : résumé du
/// profil, stats, et les modes de jeu : Normal (bot sur le téléphone, E5),
/// Classé (bot joué par le serveur, compte pour l'Elo) et Multijoueur (E7) —
/// ces deux derniers réservés à une session serveur. Posé à plat, le
/// téléphone fait apparaître « Face à face » (E10) : deux joueurs autour de
/// la table, sur l'appareil. Sans capteurs de mouvement (web, ordinateur),
/// ce mode est toujours proposé.
class GameHomeScreen extends ConsumerStatefulWidget {
  const GameHomeScreen({super.key, required this.onOpenSettings});

  /// Ouvre l'onglet Réglages — appelé par l'icône engrenage du header,
  /// géré par la coquille de navigation (`_MainShell`).
  final VoidCallback onOpenSettings;

  @override
  ConsumerState<GameHomeScreen> createState() => _GameHomeScreenState();
}

class _GameHomeScreenState extends ConsumerState<GameHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameHomeViewModelProvider);
    // Classé et Multi exigent une session serveur (pas d'authUserId en
    // AuthStatus.localGuest).
    final isAuthenticated =
        ref.watch(authViewModelProvider).status ==
        AuthStatus.serverAuthenticated;
    final showFaceToFace =
        !ref.watch(motionSensorsProvider) ||
        (ref.watch(isFlatProvider).valueOrNull ?? false);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(
                username: state.username,
                thumbnailUrl: state.thumbnailUrl,
                radius: 26,
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
                      context.l10n.eloLabel(state.elo),
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
                tooltip: context.l10n.settings,
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
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                context.l10n.statsLoadError,
                style: TextStyle(color: AppColors.yellow, fontSize: 12),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: state.isProfileLoading ? '…' : '${state.parties}',
                  label: context.l10n.statGames,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  value: state.isProfileLoading ? '…' : '${state.victoires}',
                  label: context.l10n.statWins,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  value: state.isProfileLoading ? '…' : '${state.elo}',
                  label: context.l10n.statElo,
                  color: AppColors.yellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            context.l10n.chooseMode,
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
            title: context.l10n.modeNormal,
            subtitle: context.l10n.modeNormalSubtitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NormalModeScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            icon: Icons.emoji_events,
            color: AppColors.yellow,
            title: context.l10n.modeRanked,
            subtitle: context.l10n.modeRankedSubtitle,
            onTap: () =>
                _openOnline(context, isAuthenticated, const RankedScreen()),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            icon: Icons.people,
            color: AppColors.green,
            title: context.l10n.modeMultiplayer,
            subtitle: context.l10n.modeMultiplayerSubtitle,
            onTap: () => _openOnline(
              context,
              isAuthenticated,
              const MultiplayerScreen(),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SizeTransition(sizeFactor: animation, child: child),
            ),
            child: showFaceToFace
                ? _ModeCard(
                    key: const ValueKey('face-a-face'),
                    icon: Icons.table_restaurant,
                    color: AppColors.blue,
                    title: context.l10n.modeFaceToFace,
                    subtitle: context.l10n.modeFaceToFaceSubtitle,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            GameScreen(launch: GameLaunch.faceToFace()),
                      ),
                    ),
                  )
                : Padding(
                    key: ValueKey('face-a-face-hint'),
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.table_restaurant,
                          color: Colors.white38,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            context.l10n.layFlatHint,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Classé et Multijoueur passent par le serveur : sans session serveur
  /// (invité hors-ligne), on explique plutôt que d'ouvrir un écran inutile.
  static void _openOnline(
    BuildContext context,
    bool isAuthenticated,
    Widget screen,
  ) {
    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.needsServer),
        ),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
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
    super.key,
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
