import 'package:flutter/material.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_palette.dart';
import '../../model/game_participant.dart';
import '../../model/game_snapshot.dart';
import '../participant_name.dart';
import 'countdown.dart';

/// Ligne d'état sous les joueurs : résultat, position du replay, trait,
/// chrono, problèmes de connexion — tout vient du [GameSnapshot].
class GameStatus extends StatelessWidget {
  const GameStatus({super.key, required this.snapshot});

  final GameSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final replay = snapshot.replay;
    if (snapshot.isOver) {
      final (text, color) = resultLabel(l10n, context.colors, snapshot);
      return _Line(text: text, color: color, big: true);
    }
    if (replay != null) {
      return _Line(
        text: l10n.replayMove(replay.cursor, replay.total),
        color: context.colors.textSecondary,
      );
    }
    if (snapshot.isConnecting) {
      return _Line(text: l10n.gameConnecting, color: context.colors.textMuted);
    }
    if (snapshot.isReconnecting) {
      return _Line(text: l10n.gameReconnecting, color: context.colors.yellow);
    }

    final toPlay = snapshot.participant(snapshot.colorToPlay);
    final myTurn =
        snapshot.myColor == null || snapshot.colorToPlay == snapshot.myColor;
    final text = snapshot.myColor == null
        ? l10n.turnOf(participantName(l10n, toPlay))
        : myTurn
        ? l10n.yourTurn
        : toPlay is BotParticipant
        ? l10n.botThinking(participantName(l10n, toPlay))
        : l10n.opponentTurn;
    final deadline = snapshot.turnDeadline;

    return Column(
      children: [
        _Line(text: text, color: context.colors.text, big: true),
        if (deadline != null)
          Countdown(
            deadline: deadline,
            builder: (remaining) => Text(
              l10n.secondsLeft(remaining.inSeconds),
              style: TextStyle(
                color: remaining.inSeconds <= 10
                    ? context.colors.primary
                    : context.colors.textMuted,
              ),
            ),
          ),
        if (!snapshot.opponentConnected)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.opponentDisconnected,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.yellow, fontSize: 12),
            ),
          ),
      ],
    );
  }

  /// Texte et couleur du résultat, du point de vue du joueur de l'appareil.
  static (String, Color) resultLabel(
    AppLocalizations l10n,
    AppPalette colors,
    GameSnapshot snapshot,
  ) {
    final result = snapshot.result!;
    final winner = result.winner;
    final elo = _elo(l10n, result);
    if (winner == null) return (l10n.gameCancelled, colors.textSecondary);
    if (winner == EnumOutcome.draw) {
      return ('${l10n.gameDraw}$elo', colors.textSecondary);
    }
    final winnerColor = winner == EnumOutcome.rouge
        ? EnumColor.rouge
        : EnumColor.jaune;
    final myColor = snapshot.myColor;
    if (myColor == null) {
      return (
        l10n.playerWins(
          participantName(l10n, snapshot.participant(winnerColor)),
        ),
        colors.green,
      );
    }
    final won = winnerColor == myColor;
    final label = switch (result.endReason) {
      EnumGameEndReason.forfeit =>
        won ? l10n.gameWonByForfeit : l10n.gameLostByForfeit,
      EnumGameEndReason.disconnect =>
        won ? l10n.gameWonByDisconnect : l10n.gameLostByDisconnect,
      EnumGameEndReason.timeout =>
        won ? l10n.gameWonOnTime : l10n.gameLostOnTime,
      _ => won ? l10n.gameWon : l10n.gameLost,
    };
    return ('$label$elo', won ? colors.green : colors.primary);
  }

  static String _elo(AppLocalizations l10n, GameResult result) {
    final variation = result.eloVariation;
    if (variation == null) return '';
    return l10n.eloVariation('${variation >= 0 ? '+' : ''}$variation');
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.text, required this.color, this.big = false});

  final String text;
  final Color color;
  final bool big;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      color: color,
      fontSize: big ? 18 : 14,
      fontWeight: big ? FontWeight.bold : FontWeight.normal,
    ),
  );
}
