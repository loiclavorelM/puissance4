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

  @override
  Stream<GameEvent> hostRoom() => host.stream;

  @override
  Stream<GameEvent> joinRoom(String code) => const Stream.empty();
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
}

/// Le moteur adopté ignore le `Ref` qu'on lui passe.
class _NoRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
