import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../game/model/game_launch.dart';
import '../../game/model/server_game_engine.dart';
import '../../game/viewmodel/game_viewmodel.dart';
import '../model/multiplayer_repository.dart';

enum LobbyPhase {
  /// Choix : créer une salle ou en rejoindre une.
  idle,
  connecting,

  /// Salle ouverte, en attente d'un adversaire.
  hosting,
}

class LobbyState {
  const LobbyState({
    this.phase = LobbyPhase.idle,
    this.code,
    this.roomExpiresAt,
    this.resumablePartieId,
    this.errorMessage,
  });

  final LobbyPhase phase;
  final String? code;
  final DateTime? roomExpiresAt;

  /// Partie serveur déjà en cours (app fermée en pleine partie) : le lobby
  /// propose de la reprendre.
  final UuidValue? resumablePartieId;
  final String? errorMessage;
}

final multiplayerRepositoryProvider = Provider<MultiplayerRepository>(
  (ref) => MultiplayerRepository(),
);

/// Salles publiques du lobby (US7.4) — séparé du viewmodel, qui ne gère
/// que créer / rejoindre / reprendre. Fermé en quittant l'écran.
final lobbyRoomsProvider = StreamProvider.autoDispose<List<LobbyRoom>>(
  (ref) => ref.read(multiplayerRepositoryProvider).watchLobby(),
);

final multiplayerViewModelProvider =
    NotifierProvider.autoDispose<MultiplayerViewModel, LobbyState>(
      MultiplayerViewModel.new,
    );

/// Salle d'attente Multi : créer / rejoindre / reprendre. Dès que la partie
/// commence, le stream de la salle est confié à un `ServerGameEngine`
/// (sans être fermé, sinon le serveur verrait un départ) et publié sur
/// [launches] pour ouvrir l'écran de partie commun. Quitter l'écran avant
/// dispose le provider et coupe le stream : le serveur ferme la salle.
class MultiplayerViewModel extends AutoDisposeNotifier<LobbyState> {
  StreamSubscription<GameEvent>? _subscription;
  final _launches = StreamController<GameLaunch>.broadcast();
  var _disposed = false;
  var _fromLobby = false;

  Stream<GameLaunch> get launches => _launches.stream;

  @override
  LobbyState build() {
    ref.onDispose(() {
      _disposed = true;
      unawaited(_subscription?.cancel());
      unawaited(_launches.close());
    });
    unawaited(_lookForActivePartie());
    return const LobbyState();
  }

  void host({bool isPublic = false}) {
    _fromLobby = false;
    _follow(
      ref.read(multiplayerRepositoryProvider).hostRoom(isPublic: isPublic),
    );
  }

  /// Rejoint la salle [code], tapé par le joueur ou choisi dans le lobby
  /// ([fromLobby] : une salle disparue y a été prise par quelqu'un d'autre).
  void join(String code, {bool fromLobby = false}) {
    _fromLobby = fromLobby;
    final normalized = code.trim().toUpperCase();
    if (normalized.length != 6) {
      state = LobbyState(
        resumablePartieId: state.resumablePartieId,
        errorMessage: 'Le code fait 6 caractères.',
      );
      return;
    }
    _follow(ref.read(multiplayerRepositoryProvider).joinRoom(normalized));
  }

  /// Reprend une partie serveur en cours (Multi ou Classé).
  void resume(UuidValue partieId) {
    final repository = ref.read(serverGameRepositoryProvider);
    _launches.add(
      GameLaunch(
        title: 'Partie en cours',
        createEngine: (_) => ServerGameEngine.watch(repository, partieId),
      ),
    );
  }

  /// Ferme la salle d'attente (l'hôte renonce).
  void leaveRoom() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    state = LobbyState(resumablePartieId: state.resumablePartieId);
  }

  Future<void> _lookForActivePartie() async {
    try {
      final partieId = await ref
          .read(serverGameRepositoryProvider)
          .getActivePartie();
      if (partieId != null && !_disposed && state.phase == LobbyPhase.idle) {
        state = LobbyState(resumablePartieId: partieId);
      }
    } catch (_) {
      // Pas bloquant : le lobby reste utilisable sans cette information.
    }
  }

  void _follow(Stream<GameEvent> stream) {
    unawaited(_subscription?.cancel());
    state = LobbyState(
      phase: LobbyPhase.connecting,
      resumablePartieId: state.resumablePartieId,
    );
    _subscription = stream.listen(
      _onEvent,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: true,
    );
  }

  void _onEvent(GameEvent event) {
    switch (event.type) {
      case EnumGameEventType.roomCreated:
        state = LobbyState(
          phase: LobbyPhase.hosting,
          code: event.code,
          roomExpiresAt: event.roomExpiresAt,
        );
      case EnumGameEventType.roomClosed:
        _subscription = null;
        state = const LobbyState(
          errorMessage: "Salle fermée : personne ne l'a rejointe à temps.",
        );
      case EnumGameEventType.gameStarted:
        // Passage de relais : le moteur prend l'abonnement tout de suite,
        // pour ne perdre aucun coup pendant la navigation.
        final subscription = _subscription!;
        _subscription = null;
        final engine = ServerGameEngine.adopt(
          ref.read(serverGameRepositoryProvider),
          subscription,
          event,
        );
        state = const LobbyState();
        _launches.add(
          GameLaunch(title: 'Multijoueur', createEngine: (_) => engine),
        );
      case EnumGameEventType.moveApplied ||
          EnumGameEventType.gameOver ||
          EnumGameEventType.opponentDisconnected ||
          EnumGameEventType.opponentReconnected:
        // Déjà confiés au moteur de partie.
        break;
    }
  }

  void _onError(Object error) {
    _subscription = null;
    if (_disposed) return;
    if (error is GameException) {
      state = LobbyState(
        resumablePartieId: error.reason == EnumGameError.alreadyInGame
            ? error.partieId
            : state.resumablePartieId,
        errorMessage: _fromLobby && error.reason == EnumGameError.roomNotFound
            ? 'Salle déjà prise ou fermée.'
            : _messageFor(error),
      );
      return;
    }
    state = LobbyState(
      resumablePartieId: state.resumablePartieId,
      errorMessage: 'Connexion au serveur perdue.',
    );
  }

  void _onDone() {
    // Fin normale après `roomClosed` : `_subscription` déjà nul.
    if (_subscription == null || _disposed) return;
    _subscription = null;
    state = LobbyState(
      resumablePartieId: state.resumablePartieId,
      errorMessage: 'Connexion au serveur perdue.',
    );
  }

  static String _messageFor(GameException error) => switch (error.reason) {
    EnumGameError.roomNotFound => 'Code inconnu ou salle déjà fermée.',
    EnumGameError.ownRoom =>
      "C'est ta propre salle : partage le code à un ami.",
    EnumGameError.alreadyInGame => 'Tu as déjà une partie en cours.',
    _ => 'Action impossible.',
  };
}
