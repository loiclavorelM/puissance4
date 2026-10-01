import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/action_banner.dart';
import '../../game/model/game_launch.dart';
import '../../game/view/game_screen.dart';
import '../../game/viewmodel/game_home_viewmodel.dart';
import '../viewmodel/ranked_viewmodel.dart';

/// Classé : une partie contre un bot joué par le serveur, qui compte pour
/// l'Elo. Le bot dépend de l'Elo du joueur (annoncé avant de jouer).
class RankedScreen extends ConsumerWidget {
  const RankedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rankedViewModelProvider);
    final viewModel = ref.read(rankedViewModelProvider.notifier);
    final elo = ref.watch(gameHomeViewModelProvider).elo;
    final opponent = ref.watch(rankedOpponentProvider);
    final resumable = state.resumablePartieId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: const Text('Classé'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (resumable != null) ...[
                ActionBanner(
                  text: 'Tu as une partie en cours.',
                  actionLabel: 'Reprendre',
                  onAction: () => _open(context, viewModel.resume(resumable)),
                ),
                const SizedBox(height: 20),
              ],
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.yellow.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TON ELO',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$elo',
                      style: const TextStyle(
                        color: AppColors.yellow,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      opponent == null
                          ? 'Adversaire choisi selon ton Elo'
                          : 'Adversaire : Bot ${opponent.botName} '
                                '(ELO ${opponent.elo})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chaque coup est validé par le serveur. Victoire, défaite ou '
                'nul font varier ton Elo ; quitter la partie compte comme une '
                'défaite (sauf si tu n\'as joué aucun coup). 60 s par coup.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const Spacer(),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    state.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.yellow),
                  ),
                ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: state.isStarting
                    ? null
                    : () async {
                        final launch = await viewModel.start();
                        if (launch != null && context.mounted) {
                          await _open(context, launch);
                        }
                      },
                child: Text(
                  state.isStarting ? 'Lancement…' : 'Lancer une partie classée',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _open(BuildContext context, GameLaunch launch) =>
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => GameScreen(launch: launch)),
      );
}
