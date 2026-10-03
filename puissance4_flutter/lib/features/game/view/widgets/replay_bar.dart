import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
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
          Icons.first_page,
          l10n.replayFirst,
          atStart ? null : controls.first,
        ),
        _button(
          Icons.chevron_left,
          l10n.replayPrevious,
          atStart ? null : controls.previous,
        ),
        _button(
          position.isPlaying ? Icons.pause : Icons.play_arrow,
          position.isPlaying ? l10n.replayPause : l10n.replayPlay,
          position.total == 0 ? null : controls.togglePlay,
        ),
        _button(
          Icons.chevron_right,
          l10n.replayNext,
          atEnd ? null : controls.next,
        ),
        _button(Icons.last_page, l10n.replayLast, atEnd ? null : controls.last),
      ],
    );
  }

  Widget _button(IconData icon, String tooltip, VoidCallback? onPressed) =>
      IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon),
        color: Colors.white,
        disabledColor: Colors.white24,
        iconSize: 30,
      );
}
