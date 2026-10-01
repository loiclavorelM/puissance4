import 'dart:async';

import 'package:puissance4_client/puissance4_client.dart';

import 'game_engine.dart';
import 'game_participant.dart';
import 'game_snapshot.dart';
import 'server_game_repository.dart';

/// Partie jouée sur le serveur, seul juge (Multi : l'adversaire est un joueur
/// connecté ; Classé : un bot serveur). Les coups de l'appareil partent par
/// `playMove`, tout le reste arrive par le stream de la partie. En cas de
/// coupure, reconnexion par `watchPartie` dans le délai de grâce du serveur.
class ServerGameEngine extends GameEngineBase {
  /// Suit la partie [partieId] depuis le début (Classé, reprise).
  ServerGameEngine.watch(this._repository, UuidValue partieId)
    : _partieId = partieId,
      super(const GameSnapshot.connecting()) {
    _listen(_repository.watchPartie(partieId));
  }

  /// Reprend un stream déjà ouvert (salle Multi dont la partie vient de
  /// commencer) sans le fermer : le serveur ne voit ni départ ni retour.
  ServerGameEngine.adopt(
    this._repository,
    StreamSubscription<GameEvent> subscription,
    GameEvent started,
  ) : _partieId = started.partieId!,
      super(const GameSnapshot.connecting()) {
    _subscription = subscription
      ..onData(_onEvent)
      ..onError(_onError)
      ..onDone(_onDone);
    _onEvent(started);
  }

  /// Délai avant la tentative de reconnexion n° [attempt] : 1, 2, 3 s, puis
  /// toutes les 4 s tant que la partie peut être en cours. On n'abandonne
  /// jamais de soi-même : c'est le serveur qui termine la partie, et après
  /// une panne serveur il redonne à chacun un délai de grâce complet.
  /// Modifiable pour les tests.
  static Duration Function(int attempt) reconnectDelay = (attempt) =>
      Duration(seconds: attempt < 4 ? attempt : 4);

  /// Tentatives rapides avant de prévenir le joueur que ça dure.
  static const _quickReconnectAttempts = 4;

  /// Après une erreur réseau sur mon coup, délai au bout duquel le plateau
  /// est rendu si le serveur n'a annoncé aucun nouveau coup : le coup n'est
  /// sans doute jamais arrivé. S'il était arrivé quand même, rejouer est
  /// simplement refusé (`notYourTurn`). Modifiable pour les tests.
  static Duration pendingMoveTimeout = const Duration(seconds: 3);

  final ServerGameRepository _repository;
  final UuidValue _partieId;
  StreamSubscription<GameEvent>? _subscription;
  var _reconnectAttempts = 0;

  /// Nombre de coups au départ de mon coup : l'entrée reste bloquée jusqu'à
  /// ce que le serveur annonce une partie plus longue. La réponse de
  /// `playMove` arrive souvent avant `moveApplied` sur le stream ; rouvrir
  /// l'entrée dès cette réponse laisserait jouer un second coup, refusé.
  int? _pendingMoveCount;
  Timer? _pendingMoveTimer;

  UuidValue get partieId => _partieId;

  @override
  Future<void> play(int column) async {
    if (!current.acceptsInput) return;
    _pendingMoveCount = current.moves.length;
    emit(current.copyWith(acceptsInput: false));
    try {
      // Le plateau se met à jour à la réception de `moveApplied`.
      await _repository.playMove(_partieId, column);
    } on GameException catch (error) {
      // Refus du serveur : le coup n'a pas été joué.
      _pendingMoveCount = null;
      notice(_messageFor(error, 'Coup refusé. Réessaie.'));
      emit(current.copyWith(acceptsInput: _acceptsInput(current)));
    } catch (_) {
      // Erreur réseau : le coup a pu être joué (seule la réponse s'est
      // perdue). Le plateau reste bloqué jusqu'au prochain coup annoncé par
      // le stream, ou jusqu'à [pendingMoveTimeout].
      notice('Connexion instable — coup en attente de confirmation.');
      _pendingMoveTimer?.cancel();
      _pendingMoveTimer = Timer(pendingMoveTimeout, _releasePendingMove);
    }
  }

  void _releasePendingMove() {
    final pending = _pendingMoveCount;
    if (isDisposed || pending == null || current.moves.length > pending) {
      return;
    }
    _pendingMoveCount = null;
    emit(current.copyWith(acceptsInput: _acceptsInput(current)));
  }

  @override
  Future<void> abandon() async {
    if (current.isOver) return;
    try {
      await _repository.abandon(_partieId);
    } catch (_) {
      // Sans réseau, fermer l'écran suffit : le serveur conclura la partie
      // à la fin du délai de grâce.
    }
  }

  void _listen(Stream<GameEvent> stream) {
    unawaited(_subscription?.cancel());
    _subscription = stream.listen(
      _onEvent,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: true,
    );
  }

  void _onEvent(GameEvent event) {
    switch (event.type) {
      case EnumGameEventType.gameStarted ||
          EnumGameEventType.moveApplied ||
          EnumGameEventType.gameOver:
        _reconnectAttempts = 0;
        final over = event.type == EnumGameEventType.gameOver;
        if (over) _subscription = null;
        final pending = _pendingMoveCount;
        if (pending != null && (event.moves?.length ?? 0) > pending) {
          _pendingMoveCount = null;
          _pendingMoveTimer?.cancel();
        }
        final snapshot = GameSnapshot(
          rouge: event.rouge != null
              ? GameParticipant.fromInfo(event.rouge!)
              : current.rouge,
          jaune: event.jaune != null
              ? GameParticipant.fromInfo(event.jaune!)
              : current.jaune,
          myColor: event.yourColor ?? current.myColor,
          moves: event.moves ?? current.moves,
          turnDeadline: event.turnDeadline,
          result: over
              ? GameResult(
                  winner: event.winner,
                  endReason: event.endReason,
                  eloVariation: event.eloVariation,
                )
              : null,
          // `gameStarted` arrive aussi après ma propre reconnexion : il dit
          // si l'adversaire est là, ce que je n'ai pas pu suivre entre-temps.
          opponentConnected: event.type == EnumGameEventType.gameStarted
              ? event.opponentConnected ?? true
              : current.opponentConnected,
        );
        emit(snapshot.copyWith(acceptsInput: _acceptsInput(snapshot)));
      case EnumGameEventType.opponentDisconnected:
        emit(current.copyWith(opponentConnected: false));
      case EnumGameEventType.opponentReconnected:
        emit(current.copyWith(opponentConnected: true));
      case EnumGameEventType.roomCreated || EnumGameEventType.roomClosed:
        // Propres aux salles d'attente, jamais relayés en partie.
        break;
    }
  }

  bool _acceptsInput(GameSnapshot snapshot) =>
      !snapshot.isOver &&
      !snapshot.isConnecting &&
      !snapshot.isReconnecting &&
      _pendingMoveCount == null &&
      snapshot.myColor != null &&
      snapshot.colorToPlay == snapshot.myColor;

  void _onError(Object error) {
    _subscription = null;
    if (error is GameException) {
      notice(_messageFor(error, 'Partie introuvable.'));
      return;
    }
    _connectionLost();
  }

  void _onDone() {
    // Fin normale après `gameOver` : `_subscription` déjà nul.
    if (_subscription == null || isDisposed) return;
    _subscription = null;
    _connectionLost();
  }

  void _connectionLost() {
    if (isDisposed || current.isOver) return;
    _reconnectAttempts++;
    if (_reconnectAttempts == _quickReconnectAttempts + 1) {
      notice('Connexion perdue — nouvelles tentatives en cours.');
    }
    emit(current.copyWith(isReconnecting: true, acceptsInput: false));
    Future<void>.delayed(reconnectDelay(_reconnectAttempts), () {
      if (isDisposed || current.isOver) return;
      _listen(_repository.watchPartie(_partieId));
    });
  }

  static String _messageFor(Object error, String fallback) {
    if (error is! GameException) return fallback;
    return switch (error.reason) {
      EnumGameError.notYourTurn => "Ce n'est pas ton tour.",
      EnumGameError.invalidMove => 'Colonne pleine.',
      EnumGameError.gameOver => 'La partie est terminée.',
      _ => fallback,
    };
  }

  @override
  void dispose() {
    // Fermer le stream en pleine partie = départ : le serveur lance le délai
    // de grâce (l'écran a déjà demandé confirmation et abandonné).
    unawaited(_subscription?.cancel());
    _subscription = null;
    _pendingMoveTimer?.cancel();
    super.dispose();
  }
}
