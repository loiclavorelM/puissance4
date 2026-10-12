import 'package:flutter/material.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_palette.dart';
import '../../model/game_participant.dart';
import '../participant_name.dart';
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
    final disc = Connect4BoardView.colorOf(color);
    // Bordure du joueur actif : accent du thème, lisible sur une carte
    // claire (le jaune vif du jeton ne l'est pas).
    final accent = color == EnumColor.rouge
        ? context.colors.primary
        : context.colors.yellow;
    final elo = participant.elo;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? accent : context.colors.divider,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 8, backgroundColor: disc),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participantName(context.l10n, participant),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  elo == null ? label : context.l10n.labelWithElo(label, elo),
                  style: TextStyle(
                    color: context.colors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
