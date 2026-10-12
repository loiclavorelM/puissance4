import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_palette.dart';
import '../../model/game_engine.dart';
import '../../model/game_snapshot.dart';

/// Contrôles d'un replay : début, précédent, lecture/pause, suivant, fin.
class ReplayBar extends StatelessWidget {
  const ReplayBar({super.key, required this.controls, required this.position});

  final ReplayControls controls;
  final ReplayPosition position;

  @override
  Widget build(BuildContext context) {
    final atStart = position.cursor == 0;
    final atEnd = position.cursor == position.total;
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _button(
          context,
          Icons.first_page,
          l10n.replayFirst,
          atStart ? null : controls.first,
        ),
        _button(
          context,
          Icons.chevron_left,
          l10n.replayPrevious,
          atStart ? null : controls.previous,
        ),
        _button(
          context,
          position.isPlaying ? Icons.pause : Icons.play_arrow,
          position.isPlaying ? l10n.replayPause : l10n.replayPlay,
          position.total == 0 ? null : controls.togglePlay,
        ),
        _button(
          context,
          Icons.chevron_right,
          l10n.replayNext,
          atEnd ? null : controls.next,
        ),
        _button(
          context,
          Icons.last_page,
          l10n.replayLast,
          atEnd ? null : controls.last,
        ),
      ],
    );
  }

  Widget _button(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback? onPressed,
  ) => IconButton(
    onPressed: onPressed,
    tooltip: tooltip,
    icon: Icon(icon),
    color: context.colors.text,
    disabledColor: context.colors.outline,
    iconSize: 30,
  );
}
