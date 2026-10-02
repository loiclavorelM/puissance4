import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_flutter/features/game/model/game_launch.dart';
import 'package:puissance4_flutter/features/game/viewmodel/game_viewmodel.dart';
import 'package:puissance4_flutter/features/multiplayer/model/multiplayer_repository.dart';
import 'package:puissance4_flutter/features/multiplayer/viewmodel/multiplayer_viewmodel.dart';

import '../game/fake_server_game_repository.dart';

class _FakeLobbyRepository implements MultiplayerRepository {
  final host = StreamController<GameEvent>();
  bool? hostedPublic;

  /// Refus renvoyé par [joinRoom] (aucun si `null`).
  GameException? joinError;

  @override
  Stream<GameEvent> hostRoom({bool isPublic = false}) {
    hostedPublic = isPublic;
    return host.stream;
  }

  @override
  Stream<GameEvent> joinRoom(String code) =>
      joinError == null ? const Stream.empty() : Stream.error(joinError!);

  @override
  Stream<List<LobbyRoom>> watchLobby() => const Stream.empty();
}

void main() {
  late _FakeLobbyRepository lobby;
  late FakeServerGameRepository server;
  late ProviderContainer container;

  LobbyState read() => container.read(multiplayerViewModelProvider);
  MultiplayerViewModel viewModel() =>
      container.read(multiplayerViewModelProvider.notifier);

  setUp(() {
    lobby = _FakeLobbyRepository();
    server = FakeServerGameRepository();
    container = ProviderContainer(
      overrides: [
        multiplayerRepositoryProvider.overrideWithValue(lobby),
        serverGameRepositoryProvider.overrideWithValue(server),
      ],
    );
    // autoDispose : garder le provider en vie pendant le test.
    container.listen(multiplayerViewModelProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  test('hosting shows the code, then hands the game to the engine', () async {
    final launches = <GameLaunch>[];
    viewModel().launches.listen(launches.add);

    viewModel().host();
    expect(read().phase, LobbyPhase.connecting);
    lobby.host.add(
      GameEvent(type: EnumGameEventType.roomCreated, code: 'ABC234'),
    );
    await pumpEventQueue();
    expect(read().phase, LobbyPhase.hosting);
    expect(read().code, 'ABC234');

    lobby.host.add(gameEvent(EnumGameEventType.gameStarted, []));
    await pumpEventQueue();
    expect(launches, hasLength(1));
    expect(read().phase, LobbyPhase.idle);

    // Le même stream (jamais refermé) alimente désormais le moteur.
    final engine = launches.single.createEngine(_NoRef());
    lobby.host.add(gameEvent(EnumGameEventType.moveApplied, [3]));
    await pumpEventQueue();
    expect(engine.current.moves, [3]);
    expect(server.watches, isEmpty);
    engine.dispose();
  });

  test(
    'alreadyInGame goes back to the lobby with a resumable partie',
    () async {
      viewModel().host();
      lobby.host.addError(
        GameException(
          reason: EnumGameError.alreadyInGame,
          partieId: testPartieId,
        ),
      );
      await pumpEventQueue();

      expect(read().phase, LobbyPhase.idle);
      expect(read().resumablePartieId, testPartieId);
      expect(read().errorMessage, isNotNull);
    },
  );

  test('a room is private unless asked otherwise', () {
    viewModel().host();
    expect(lobby.hostedPublic, isFalse);
  });

  test('a public room is requested as such', () {
    viewModel().host(isPublic: true);
    expect(lobby.hostedPublic, isTrue);
  });

  test('a room gone from the lobby reads as already taken', () async {
    lobby.joinError = GameException(reason: EnumGameError.roomNotFound);

    viewModel().join('ABC234', fromLobby: true);
    await pumpEventQueue();
    expect(read().errorMessage, 'Salle déjà prise ou fermée.');

    viewModel().join('ABC234');
    await pumpEventQueue();
    expect(read().errorMessage, 'Code inconnu ou salle déjà fermée.');
  });
}

/// Le moteur adopté ignore le `Ref` qu'on lui passe.
class _NoRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
