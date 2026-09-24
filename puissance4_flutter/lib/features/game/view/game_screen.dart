import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/theme/app_colors.dart';
import '../model/game_setup.dart';
import '../viewmodel/game_viewmodel.dart';

/// Écran de partie temporaire — affiche le [GameSetup] reçu et permet de
/// clore la partie avec un résultat choisi à la main, en attendant le
/// plateau et le moteur de jeu (E4).
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key, required this.setup});

  final GameSetup setup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameViewModelProvider(setup));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Partie en cours'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoRow(label: 'Mode', value: _modeLabel(setup.mode)),
              _InfoRow(label: 'Partie', value: setup.partieId.toString()),
              _InfoRow(
                label: 'Joueur',
                value:
                    '${setup.user.displayName} (ELO ${setup.user.elo}) — '
                    '${_colorLabel(setup.userColor)}',
              ),
              _InfoRow(
                label: 'Adversaire',
                value: switch (setup.adversaire) {
                  BotParticipant(:final bot) =>
                    'Bot ${bot.botName} (ELO ${bot.elo})',
                  UserParticipant(:final username, :final elo) =>
                    '$username (ELO $elo)',
                },
              ),
              const Spacer(),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: AppColors.yellow),
                  ),
                ),
              const Text(
                'TERMINER LA PARTIE',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final (result, label, color) in const [
                    (EnumMatchResult.win, 'Victoire', AppColors.green),
                    (EnumMatchResult.loss, 'Défaite', AppColors.primary),
                    (EnumMatchResult.draw, 'Nul', Colors.white54),
                  ])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: color,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: state.isFinishing
                              ? null
                              : () => _finish(context, ref, result),
                          child: Text(label),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _finish(
    BuildContext context,
    WidgetRef ref,
    EnumMatchResult result,
  ) async {
    final finished = await ref
        .read(gameViewModelProvider(setup).notifier)
        .finish(result);
    if (finished && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  static String _modeLabel(EnumType mode) => switch (mode) {
    EnumType.normal => 'Normal',
    EnumType.multi => 'Multijoueur',
    EnumType.classe => 'Classé',
  };

  static String _colorLabel(EnumColor color) => switch (color) {
    EnumColor.rouge => 'Rouge',
    EnumColor.jaune => 'Jaune',
  };
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.white54)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
