import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/action_banner.dart';
import '../../game/model/game_launch.dart';
import '../../game/view/game_screen.dart';
import '../../game/viewmodel/game_home_viewmodel.dart';
import '../viewmodel/ranked_viewmodel.dart';
import '../../../core/l10n/l10n.dart';
import '../../bot/view/bot_labels.dart';

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
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.text,
        title: Text(context.l10n.modeRanked),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (resumable != null) ...[
                ActionBanner(
                  text: context.l10n.gameInProgressBanner,
                  actionLabel: context.l10n.resume,
                  onAction: () => _open(context, viewModel.resume(resumable)),
                ),
                const SizedBox(height: 20),
              ],
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.colors.yellow.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      context.l10n.yourElo,
                      style: TextStyle(
                        color: context.colors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$elo',
                      style: TextStyle(
                        color: context.colors.yellow,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.rankedOpponent(
                        localizedBotName(context.l10n, opponent.name),
                        opponent.elo,
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colors.text),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.rankedRules,
                style: TextStyle(color: context.colors.textMuted, fontSize: 13),
              ),
              const Spacer(),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    state.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.colors.yellow),
                  ),
                ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.yellow,
                  foregroundColor: context.colors.background,
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
                  state.isStarting
                      ? context.l10n.starting
                      : context.l10n.startRanked,
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
