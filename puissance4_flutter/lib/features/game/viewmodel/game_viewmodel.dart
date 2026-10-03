import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../model/game_engine.dart';
import '../model/game_launch.dart';
import '../model/game_snapshot.dart';
import '../model/server_game_repository.dart';

final serverGameRepositoryProvider = Provider<ServerGameRepository>(
  (ref) => ServerGameRepository(),
);

final gameViewModelProvider = NotifierProvider.autoDispose
    .family<GameViewModel, GameSnapshot, GameLaunch>(GameViewModel.new);

/// Partie affichée par `GameScreen`, quel que soit le mode : relaie l'état
/// du `GameEngine` fourni par le [GameLaunch] et lui transmet les actions.
/// Fermer l'écran dispose le moteur (et donc le stream d'une partie serveur).
class GameViewModel
    extends AutoDisposeFamilyNotifier<GameSnapshot, GameLaunch> {
  late GameEngine _engine;

  @override
  GameSnapshot build(GameLaunch launch) {
    _engine = launch.createEngine(ref);
    final subscription = _engine.snapshots.listen((s) => state = s);
    ref.onDispose(() {
      unawaited(subscription.cancel());
      _engine.dispose();
    });
    return _engine.current;
  }

  Stream<String> get notices => _engine.notices;

  ReplayControls? get replay => _engine.replay;

  Future<void> play(int column) => _engine.play(column);

  Future<void> abandon() => _engine.abandon();

  /// La partie peut être recommencée (Normal, E10 : secousse).
  bool get canRestart => arg.restart != null && !state.isReplay;

  /// Arrêter maintenant compte comme un abandon : la partie est en cours et
  /// le joueur de cet appareil a déjà joué (même règle que « Abandonner »).
  bool get stopForfeits {
    final snapshot = state;
    if (!snapshot.isLive) return false;
    final firstOwnMove = snapshot.myColor == EnumColor.jaune ? 1 : 0;
    return snapshot.moves.length > firstOwnMove;
  }

  /// Clôt la partie en cours (abandon, ou annulation si le joueur n'a pas
  /// encore joué) puis prépare la suivante. Lève si elle n'a pas pu être
  /// créée.
  Future<GameLaunch> restart() async {
    final restart = arg.restart;
    if (restart == null) throw StateError('This game cannot be restarted.');
    // Sans attendre que l'abandon soit enregistré : en Normal, sa fin
    // synchronise la partie avec le serveur, et la nouvelle partie
    // n'ouvrirait qu'au retour du réseau. La partie close est déjà à jour
    // (`emit`) et son écriture locale passe avant la création de la suivante.
    if (state.isLive) unawaited(_engine.abandon());
    return restart(ref);
  }

  /// Replay de la partie qui vient de se terminer, sans appel réseau : tous
  /// les coups sont déjà là.
  GameLaunch? replayOfFinishedGame() {
    final snapshot = state;
    if (!snapshot.isOver || snapshot.isReplay) return null;
    return GameLaunch.replay(
      moves: snapshot.moves,
      rouge: snapshot.rouge,
      jaune: snapshot.jaune,
      myColor: snapshot.myColor,
      result: snapshot.result,
    );
  }
}
