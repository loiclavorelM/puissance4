import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/l10n/l10n.dart';
import '../../settings/viewmodel/locale_provider.dart';

import '../../review/model/move_advisor.dart';
import 'game_engine.dart';
import 'game_participant.dart';
import 'local_game_engine.dart';
import 'game_snapshot.dart';
import 'replay_game_engine.dart';

/// Ce que l'écran de partie reçoit, quel que soit le mode : un titre et de
/// quoi fabriquer le moteur. L'écran ne dépend que de ça, jamais de l'écran
/// qui l'a lancé (contrat `GameLaunchParams`, US4.2).
class GameLaunch {
  const GameLaunch({
    required this.title,
    required this.createEngine,
    this.restart,
  });

  /// Face à face (E10) : deux joueurs sur le même téléphone, posé à plat
  /// entre eux. Tout se joue sur l'appareil — ni réseau, ni enregistrement,
  /// ni Elo. Recommençable (secousse, « Nouvelle partie »).
  factory GameLaunch.faceToFace() => GameLaunch(
    title: (l10n) => l10n.modeFaceToFace,
    createEngine: (ref) {
      final l10n = ref.read(l10nProvider);
      return LocalGameEngine(
        rougeSeat: const HumanSeat(),
        jauneSeat: const HumanSeat(),
        rouge: HumanParticipant(username: l10n.player1),
        jaune: HumanParticipant(username: l10n.player2),
      );
    },
    restart: (_) async => GameLaunch.faceToFace(),
  );

  /// Replay d'une partie terminée (historique, ou "Revoir la partie"),
  /// avec l'avis de l'Expert sur chaque coup.
  factory GameLaunch.replay({
    required List<int> moves,
    required GameParticipant rouge,
    required GameParticipant jaune,
    EnumColor? myColor,
    GameResult? result,
    MoveAdvisor advisor = const ExpertMoveAdvisor(),
  }) => GameLaunch(
    title: (l10n) => l10n.replayTitle,
    createEngine: (_) => ReplayGameEngine(
      moves: moves,
      rouge: rouge,
      jaune: jaune,
      myColor: myColor,
      result: result,
      advisor: advisor,
    ),
  );

  /// Titre de l'écran de partie, dans la langue de l'app.
  final String Function(AppLocalizations l10n) title;
  final GameEngine Function(Ref ref) createEngine;

  /// Nouvelle partie dans les mêmes conditions (secousse, bouton « Nouvelle
  /// partie »). `null` si le mode ne se recommence pas : Classé et Multi
  /// (un autre joueur ou l'Elo en dépendent), replay.
  final Future<GameLaunch> Function(Ref ref)? restart;
}
