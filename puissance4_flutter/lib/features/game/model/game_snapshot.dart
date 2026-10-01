import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

import 'color_mapping.dart';
import 'game_participant.dart';

/// Fin d'une partie.
class GameResult {
  const GameResult({this.winner, this.endReason, this.eloVariation});

  /// `null` : partie annulée, sans vainqueur.
  final EnumOutcome? winner;
  final EnumGameEndReason? endReason;

  /// Classé : variation d'Elo du joueur de cet appareil.
  final int? eloVariation;
}

/// Position dans un replay.
class ReplayPosition {
  const ReplayPosition({
    required this.cursor,
    required this.total,
    this.isPlaying = false,
  });

  /// Nombre de coups affichés (0 = plateau vide).
  final int cursor;
  final int total;
  final bool isPlaying;
}

/// Tout ce que l'écran de partie affiche, quel que soit le mode : l'écran ne
/// lit jamais le mode, seulement cet état produit par le `GameEngine`.
class GameSnapshot {
  const GameSnapshot({
    required this.rouge,
    required this.jaune,
    this.myColor,
    this.moves = const [],
    this.turnDeadline,
    this.result,
    this.acceptsInput = false,
    this.isConnecting = false,
    this.isReconnecting = false,
    this.opponentConnected = true,
    this.replay,
  });

  /// État d'attente avant le premier événement du serveur.
  const GameSnapshot.connecting()
    : this(
        rouge: const HumanParticipant(username: '…'),
        jaune: const HumanParticipant(username: '…'),
        isConnecting: true,
      );

  final GameParticipant rouge;
  final GameParticipant jaune;

  /// Couleur du joueur de cet appareil ; `null` si les deux camps jouent sur
  /// cet appareil (deux joueurs, un téléphone).
  final EnumColor? myColor;
  final List<int> moves;

  /// Fin du tour en cours (parties serveur) : au-delà, le joueur au trait
  /// perd au temps.
  final DateTime? turnDeadline;

  /// Non nul une fois la partie terminée.
  final GameResult? result;

  /// Le plateau réagit au toucher (c'est au joueur de cet appareil de jouer
  /// et rien n'est en cours d'envoi).
  final bool acceptsInput;
  final bool isConnecting;

  /// La connexion au serveur est tombée ; reconnexion en cours dans le délai
  /// de grâce.
  final bool isReconnecting;
  final bool opponentConnected;

  /// Non nul pour un replay.
  final ReplayPosition? replay;

  bool get isOver => result != null;
  bool get isReplay => replay != null;

  /// Partie réellement en cours : la quitter compte comme un abandon.
  bool get isLive => !isOver && !isReplay && !isConnecting;

  EnumColor get colorToPlay => Connect4Rules.discToPlay(moves).color;

  GameParticipant participant(EnumColor color) =>
      color == EnumColor.rouge ? rouge : jaune;

  /// Cases de l'alignement gagnant, à mettre en évidence.
  List<(int, int)>? get winningCells =>
      result?.endReason == EnumGameEndReason.connectFour ||
          (isReplay && replay!.cursor == replay!.total)
      ? Connect4Rules.winningCells(moves)
      : null;

  GameSnapshot copyWith({
    List<int>? moves,
    DateTime? turnDeadline,
    bool clearDeadline = false,
    GameResult? result,
    bool? acceptsInput,
    bool? isReconnecting,
    bool? opponentConnected,
    ReplayPosition? replay,
  }) => GameSnapshot(
    rouge: rouge,
    jaune: jaune,
    myColor: myColor,
    moves: moves ?? this.moves,
    turnDeadline: clearDeadline ? null : turnDeadline ?? this.turnDeadline,
    result: result ?? this.result,
    acceptsInput: acceptsInput ?? this.acceptsInput,
    isConnecting: isConnecting,
    isReconnecting: isReconnecting ?? this.isReconnecting,
    opponentConnected: opponentConnected ?? this.opponentConnected,
    replay: replay ?? this.replay,
  );
}
