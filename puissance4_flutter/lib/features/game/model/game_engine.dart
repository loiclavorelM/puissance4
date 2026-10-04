import 'dart:async';

import 'package:flutter/foundation.dart';

import 'game_snapshot.dart';

/// Ce qui fait avancer une partie : l'écran de partie ne connaît que cette
/// interface. Trois implémentations — `LocalGameEngine` (règles sur le
/// téléphone : Normal), `ServerGameEngine` (le serveur décide : Multi,
/// Classé), `ReplayGameEngine` (coups lus dans l'historique).
abstract interface class GameEngine {
  GameSnapshot get current;
  Stream<GameSnapshot> get snapshots;

  /// Messages ponctuels à afficher (coup refusé, erreur réseau…), traduits
  /// par l'écran de partie.
  Stream<GameNotice> get notices;

  /// Coup du joueur de cet appareil ; ignoré si `current.acceptsInput` est
  /// faux.
  Future<void> play(int column);

  Future<void> abandon();

  /// Non nul pour un replay.
  ReplayControls? get replay;

  void dispose();
}

/// Message ponctuel d'un moteur de partie — un code plutôt qu'un texte, pour
/// que l'écran l'affiche dans la langue de l'app (E11).
enum GameNotice {
  /// Partie locale : l'enregistrement sur l'appareil a échoué.
  saveFailed,

  /// Coup refusé par le serveur (raison non précisée).
  moveRefused,
  notYourTurn,
  columnFull,
  gameOver,

  /// Erreur réseau en envoyant un coup : il a peut-être été joué.
  moveUnconfirmed,
  gameNotFound,

  /// Plusieurs reconnexions ratées d'affilée.
  connectionLost,
}

abstract interface class ReplayControls {
  void first();
  void previous();
  void next();
  void last();
  void togglePlay();
}

/// Plomberie commune : état courant + diffusion des snapshots et messages.
abstract class GameEngineBase implements GameEngine {
  GameEngineBase(this._current);

  final _snapshots = StreamController<GameSnapshot>.broadcast();
  final _notices = StreamController<GameNotice>.broadcast();
  GameSnapshot _current;
  bool _disposed = false;

  @override
  GameSnapshot get current => _current;

  @override
  Stream<GameSnapshot> get snapshots => _snapshots.stream;

  @override
  Stream<GameNotice> get notices => _notices.stream;

  @override
  ReplayControls? get replay => null;

  bool get isDisposed => _disposed;

  @protected
  void emit(GameSnapshot snapshot) {
    if (_disposed) return;
    _current = snapshot;
    _snapshots.add(snapshot);
  }

  @protected
  void notice(GameNotice notice) {
    if (!_disposed) _notices.add(notice);
  }

  @override
  @mustCallSuper
  void dispose() {
    _disposed = true;
    unawaited(_snapshots.close());
    unawaited(_notices.close());
  }
}
