import 'package:flutter/material.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _button(Icons.first_page, 'Début', atStart ? null : controls.first),
        _button(
          Icons.chevron_left,
          'Précédent',
          atStart ? null : controls.previous,
        ),
        _button(
          position.isPlaying ? Icons.pause : Icons.play_arrow,
          position.isPlaying ? 'Pause' : 'Lecture',
          position.total == 0 ? null : controls.togglePlay,
        ),
        _button(Icons.chevron_right, 'Suivant', atEnd ? null : controls.next),
        _button(Icons.last_page, 'Fin', atEnd ? null : controls.last),
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
