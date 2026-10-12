import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

import '../../../core/theme/app_palette.dart';
import '../../game/model/color_mapping.dart';
import '../../game/model/game_snapshot.dart';
import '../viewmodel/move_explanation_viewmodel.dart';
import '../../../core/l10n/l10n.dart';
import '../../game/view/participant_name.dart';

/// Revue du dernier coup affiché d'un replay (E14) : le coup joué, celui
/// que l'Expert aurait joué, et à la demande une explication par IA.
class MoveReviewCard extends StatelessWidget {
  const MoveReviewCard({super.key, required this.snapshot});

  final GameSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final replay = snapshot.replay;
    if (replay == null || replay.cursor == 0 || replay.isPlaying) {
      return const SizedBox.shrink();
    }
    final analysis = replay.analysis;
    final index = replay.cursor - 1;
    final color = MoveAnalysis.playerOf(index).color;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.divider),
      ),
      child: analysis == null
          ? const _Analysing()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  color == snapshot.myColor
                      ? l10n.youPlayedColumn(analysis.played + 1)
                      : l10n.playerPlayedColumn(
                          participantName(l10n, snapshot.participant(color)),
                          analysis.played + 1,
                        ),
                  style: TextStyle(color: context.colors.text, fontSize: 15),
                ),
                const SizedBox(height: 4),
                _Verdict(analysis: analysis),
                _Explanation(
                  positionKey: MoveExplanationViewModel.keyFor(
                    snapshot.moves,
                    index,
                  ),
                ),
              ],
            ),
    );
  }
}

class _Analysing extends StatelessWidget {
  const _Analysing();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        SizedBox.square(
          dimension: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            context.l10n.expertAnalysing,
            style: TextStyle(color: context.colors.textMuted),
          ),
        ),
      ],
    ),
  );
}

class _Verdict extends StatelessWidget {
  const _Verdict({required this.analysis});

  final MoveAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final column = analysis.recommended + 1;
    final (icon, text, color) = analysis.isBest
        ? (Icons.check_circle, l10n.bestMove, context.colors.green)
        : analysis.playedVerdict == MoveVerdict.forcedLoss
        ? (Icons.error, l10n.losingMove(column), context.colors.primary)
        : (
            Icons.lightbulb,
            l10n.expertWouldPlay(column),
            context.colors.yellow,
          );
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: TextStyle(color: color, fontSize: 14)),
        ),
      ],
    );
  }
}

/// Bouton « Expliquer » puis le texte du LLM (ou l'erreur).
class _Explanation extends ConsumerWidget {
  const _Explanation({required this.positionKey});

  final String positionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moveExplanationProvider(positionKey));
    void explain() =>
        ref.read(moveExplanationProvider(positionKey).notifier).explain();

    return switch (state) {
      ExplanationIdle() => Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: context.colors.textSecondary,
            padding: EdgeInsets.zero,
          ),
          onPressed: explain,
          icon: const Icon(Icons.auto_awesome, size: 18),
          label: Text(context.l10n.explainMove),
        ),
      ),
      ExplanationLoading() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      ),
      ExplanationReady(:final text) => ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 140),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            text,
            style: TextStyle(color: context.colors.textSecondary, height: 1.35),
          ),
        ),
      ),
      ExplanationFailed(:final message) => Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: context.colors.textMuted, fontSize: 13),
            ),
          ),
          TextButton(onPressed: explain, child: Text(context.l10n.retry)),
        ],
      ),
    };
  }
}

/// Case où l'Expert aurait posé son jeton, sur le plateau affiché (après le
/// coup joué) — `null` si le coup joué était le meilleur.
(int, int, EnumColor)? recommendedCell(GameSnapshot snapshot) {
  final analysis = snapshot.replay?.analysis;
  if (analysis == null || analysis.isBest || snapshot.replay!.isPlaying) {
    return null;
  }
  final before = snapshot.moves.sublist(0, snapshot.moves.length - 1);
  final row = Connect4Rules.stacks(before)[analysis.recommended].length;
  return (
    analysis.recommended,
    row,
    MoveAnalysis.playerOf(before.length).color,
  );
}
