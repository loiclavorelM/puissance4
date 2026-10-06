import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../sensors/viewmodel/shake_provider.dart';
import '../viewmodel/add_in_person_viewmodel.dart';
import 'add_friend_tab.dart';

/// « Secouer pour s'ajouter » (US15.6) : tant que la feuille est ouverte,
/// chaque secousse cherche un joueur qui secoue au même moment.
Future<void> showShakeToAddSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      showDragHandle: true,
      builder: (_) => const _ShakeToAddSheet(),
    );

class _ShakeToAddSheet extends ConsumerWidget {
  const _ShakeToAddSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(shakeProvider, (_, shake) {
      if (shake.hasValue) ref.read(shakeToAddProvider.notifier).onShake();
    });
    final state = ref.watch(shakeToAddProvider);
    final l10n = context.l10n;
    final found = state.found;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.vibration,
              size: 48,
              color: state.phase == ShakePhase.matching
                  ? AppColors.yellow
                  : AppColors.green,
            ),
            const SizedBox(height: 12),
            Text(
              switch (state.phase) {
                ShakePhase.waiting => l10n.shakeToAddWaiting,
                ShakePhase.matching => l10n.shakeToAddMatching,
                ShakePhase.found => l10n.shakeToAddFound,
                ShakePhase.nobody => l10n.shakeToAddNobody,
              },
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state.errorMessage ?? l10n.shakeToAddHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: state.errorMessage == null
                    ? Colors.white54
                    : AppColors.yellow,
                fontSize: 13,
              ),
            ),
            if (state.phase == ShakePhase.matching) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            if (found != null) ...[
              const SizedBox(height: 16),
              PlayerResultRow(
                found,
                onSent: () => Navigator.of(context).pop(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
