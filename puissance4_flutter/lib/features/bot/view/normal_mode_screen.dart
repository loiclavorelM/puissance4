import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/theme/app_palette.dart';
import '../../game/view/game_screen.dart';
import '../viewmodel/normal_mode_viewmodel.dart';
import '../../../core/l10n/l10n.dart';
import 'bot_labels.dart';

/// Mode Normal — choix du bot parmi ceux renvoyés par le serveur, puis
/// lancement d'une partie hors-ligne.
class NormalModeScreen extends ConsumerWidget {
  const NormalModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final botsAsync = ref.watch(botsProvider);
    final state = ref.watch(normalModeViewModelProvider);
    final viewModel = ref.read(normalModeViewModelProvider.notifier);
    final canPlay = ref.watch(canPlayNormalProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.text,
        title: Text(context.l10n.modeNormal),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.chooseOpponent,
                style: TextStyle(
                  color: context.colors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: botsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.botsLoadError,
                          style: TextStyle(color: context.colors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () => ref.invalidate(botsProvider),
                          child: Text(context.l10n.retry),
                        ),
                      ],
                    ),
                  ),
                  data: (bots) => ListView.separated(
                    itemCount: bots.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final bot = bots[index];
                      return _BotCard(
                        bot: bot,
                        isSelected: state.selectedBot?.id == bot.id,
                        onTap: () => viewModel.select(bot),
                      );
                    },
                  ),
                ),
              ),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(color: context.colors.yellow),
                  ),
                ),
              if (!canPlay)
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    context.l10n.normalNeedsSession,
                    style: TextStyle(
                      color: context.colors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed:
                    (!canPlay || state.selectedBot == null || state.isStarting)
                    ? null
                    : () => _start(context, viewModel),
                child: state.isStarting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.start),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _start(
    BuildContext context,
    NormalModeViewModel viewModel,
  ) async {
    final launch = await viewModel.start();
    if (launch == null || !context.mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => GameScreen(launch: launch)),
    );
  }
}

class _BotCard extends StatelessWidget {
  const _BotCard({
    required this.bot,
    required this.isSelected,
    required this.onTap,
  });

  final Bot bot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? context.colors.primary : context.colors.divider,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.smart_toy, color: context.colors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizedBotName(context.l10n, bot.botName),
                      style: TextStyle(
                        color: context.colors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      context.l10n.eloLabel(bot.elo),
                      style: TextStyle(
                        color: context.colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      localizedBotDescription(context.l10n, bot),
                      style: TextStyle(
                        color: context.colors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Téléchargement du modèle du bot (T5.3.2) — pas encore
              // branché.
              IconButton(
                onPressed: () {},
                tooltip: context.l10n.download,
                icon: Icon(Icons.download, color: context.colors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
