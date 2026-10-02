import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

import '../../../core/theme/app_colors.dart';
import '../../game/model/color_mapping.dart';
import '../../game/model/game_snapshot.dart';
import '../viewmodel/move_explanation_viewmodel.dart';

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
    final who = color == snapshot.myColor
        ? 'Tu as'
        : '${snapshot.participant(color).displayName} a';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: analysis == null
          ? const _Analysing()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$who joué la colonne ${analysis.played + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 15),
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
  Widget build(BuildContext context) => const Padding(
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
            "L'Expert analyse ce coup…",
            style: TextStyle(color: Colors.white54),
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
    final (icon, text, color) = analysis.isBest
        ? (Icons.check_circle, "Meilleur coup selon l'Expert", AppColors.green)
        : analysis.playedVerdict == MoveVerdict.forcedLoss
        ? (
            Icons.error,
            "Coup perdant — l'Expert jouait la colonne "
                '${analysis.recommended + 1}',
            AppColors.primary,
          )
        : (
            Icons.lightbulb,
            "L'Expert jouait la colonne ${analysis.recommended + 1}",
            AppColors.yellow,
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
            foregroundColor: Colors.white70,
            padding: EdgeInsets.zero,
          ),
          onPressed: explain,
          icon: const Icon(Icons.auto_awesome, size: 18),
          label: const Text('Expliquer ce coup'),
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
            style: const TextStyle(color: Colors.white70, height: 1.35),
          ),
        ),
      ),
      ExplanationFailed(:final message) => Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          TextButton(onPressed: explain, child: const Text('Réessayer')),
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
