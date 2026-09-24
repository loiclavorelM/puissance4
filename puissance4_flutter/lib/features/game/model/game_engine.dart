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

  /// Messages ponctuels à afficher (coup refusé, erreur réseau…).
  Stream<String> get notices;

  /// Coup du joueur de cet appareil ; ignoré si `current.acceptsInput` est
  /// faux.
  Future<void> play(int column);

  Future<void> abandon();

  /// Non nul pour un replay.
  ReplayControls? get replay;

  void dispose();
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
  final _notices = StreamController<String>.broadcast();
  GameSnapshot _current;
  bool _disposed = false;

  @override
  GameSnapshot get current => _current;

  @override
  Stream<GameSnapshot> get snapshots => _snapshots.stream;

  @override
  Stream<String> get notices => _notices.stream;

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
  void notice(String message) {
    if (!_disposed) _notices.add(message);
  }

  @override
  @mustCallSuper
  void dispose() {
    _disposed = true;
    unawaited(_snapshots.close());
    unawaited(_notices.close());
  }
}
