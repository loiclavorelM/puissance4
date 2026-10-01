import 'package:flutter/material.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../../core/theme/app_colors.dart';
import '../../model/game_participant.dart';
import '../../model/game_snapshot.dart';
import 'countdown.dart';

/// Ligne d'état sous les joueurs : résultat, position du replay, trait,
/// chrono, problèmes de connexion — tout vient du [GameSnapshot].
class GameStatus extends StatelessWidget {
  const GameStatus({super.key, required this.snapshot});

  final GameSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final replay = snapshot.replay;
    if (snapshot.isOver) {
      final (text, color) = resultLabel(snapshot);
      return _Line(text: text, color: color, big: true);
    }
    if (replay != null) {
      return _Line(
        text: 'Coup ${replay.cursor} / ${replay.total}',
        color: Colors.white70,
      );
    }
    if (snapshot.isConnecting) {
      return const _Line(text: 'Connexion à la partie…', color: Colors.white54);
    }
    if (snapshot.isReconnecting) {
      return const _Line(
        text: 'Connexion perdue — reconnexion…',
        color: AppColors.yellow,
      );
    }

    final toPlay = snapshot.participant(snapshot.colorToPlay);
    final myTurn =
        snapshot.myColor == null || snapshot.colorToPlay == snapshot.myColor;
    final text = snapshot.myColor == null
        ? 'À ${toPlay.displayName} de jouer'
        : myTurn
        ? 'À toi de jouer'
        : toPlay is BotParticipant
        ? '${toPlay.displayName} réfléchit…'
        : "Tour de l'adversaire";
    final deadline = snapshot.turnDeadline;

    return Column(
      children: [
        _Line(text: text, color: Colors.white, big: true),
        if (deadline != null)
          Countdown(
            deadline: deadline,
            builder: (remaining) => Text(
              '${remaining.inSeconds} s',
              style: TextStyle(
                color: remaining.inSeconds <= 10
                    ? AppColors.primary
                    : Colors.white54,
              ),
            ),
          ),
        if (!snapshot.opponentConnected)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              "Adversaire déconnecté — victoire s'il ne revient pas.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.yellow, fontSize: 12),
            ),
          ),
      ],
    );
  }

  /// Texte et couleur du résultat, du point de vue du joueur de l'appareil.
  static (String, Color) resultLabel(GameSnapshot snapshot) {
    final result = snapshot.result!;
    final winner = result.winner;
    if (winner == null) return ('Partie annulée', Colors.white70);
    if (winner == EnumOutcome.draw) {
      return ('Match nul${_elo(result)}', Colors.white70);
    }
    final winnerColor = winner == EnumOutcome.rouge
        ? EnumColor.rouge
        : EnumColor.jaune;
    final myColor = snapshot.myColor;
    if (myColor == null) {
      return (
        '${snapshot.participant(winnerColor).displayName} gagne !',
        AppColors.green,
      );
    }
    final reason = switch (result.endReason) {
      EnumGameEndReason.forfeit => ' par abandon',
      EnumGameEndReason.disconnect => ' (déconnexion)',
      EnumGameEndReason.timeout => ' au temps',
      _ => '',
    };
    return winnerColor == myColor
        ? ('Victoire$reason !${_elo(result)}', AppColors.green)
        : ('Défaite$reason${_elo(result)}', AppColors.primary);
  }

  static String _elo(GameResult result) {
    final variation = result.eloVariation;
    if (variation == null) return '';
    return ' (${variation >= 0 ? '+' : ''}$variation Elo)';
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
