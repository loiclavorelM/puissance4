import 'package:flutter/material.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../../core/theme/app_colors.dart';
import '../../model/game_participant.dart';
import 'connect4_board_view.dart';

/// Carte d'un camp : couleur, nom, Elo, et un liseré quand c'est son tour.
class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.participant,
    required this.color,
    required this.label,
    required this.isActive,
  });

  final GameParticipant participant;
  final EnumColor color;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final tint = Connect4BoardView.colorOf(color);
    final elo = participant.elo;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? tint : Colors.white10,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 8, backgroundColor: tint),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  elo == null ? label : '$label · ELO $elo',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
