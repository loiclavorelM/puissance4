import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_flutter/features/game/model/game_participant.dart';
import 'package:puissance4_flutter/features/game/model/server_game_engine.dart';

import 'fake_server_game_repository.dart';

void main() {
  late FakeServerGameRepository repository;

  setUp(() => repository = FakeServerGameRepository());

  test('the engine follows the server stream and sends my moves', () async {
    final engine = ServerGameEngine.watch(repository, testPartieId);
    expect(engine.current.isConnecting, isTrue);

    repository.lastWatch.add(gameEvent(EnumGameEventType.gameStarted, []));
    await pumpEventQueue();
    expect(engine.current.isConnecting, isFalse);
    expect(engine.current.acceptsInput, isTrue);
    expect(engine.current.jaune.displayName, 'bob');

    await engine.play(3);
    expect(repository.played, [3]);

    repository.lastWatch.add(gameEvent(EnumGameEventType.moveApplied, [3]));
    await pumpEventQueue();
    expect(engine.current.moves, [3]);
    expect(engine.current.acceptsInput, isFalse);
    engine.dispose();
  });

  test('a server bot opponent is shown as a bot', () async {
    final engine = ServerGameEngine.watch(repository, testPartieId);
    repository.lastWatch.add(
      gameEvent(EnumGameEventType.gameStarted, [], opponentIsBot: true),
    );
    await pumpEventQueue();
    expect(engine.current.jaune, isA<BotParticipant>());
    engine.dispose();
  });

  test('gameOver carries the result and the Elo variation', () async {
    final engine = ServerGameEngine.watch(repository, testPartieId);
    repository.lastWatch.add(
      gameEvent(EnumGameEventType.gameOver, [3]).copyWith(
        winner: EnumOutcome.jaune,
        endReason: EnumGameEndReason.forfeit,
        eloVariation: -8,
      ),
    );
    await pumpEventQueue();

    expect(engine.current.isOver, isTrue);
    expect(engine.current.result?.eloVariation, -8);
    expect(engine.current.isLive, isFalse);
    engine.dispose();
  });

  test('losing the stream mid-game reconnects through watchPartie', () async {
    final engine = ServerGameEngine.watch(repository, testPartieId);
    repository.lastWatch.add(gameEvent(EnumGameEventType.gameStarted, [3]));
    await pumpEventQueue();

    await repository.lastWatch.close();
    await pumpEventQueue();
    expect(engine.current.isReconnecting, isTrue);
    expect(engine.current.acceptsInput, isFalse);

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(repository.watches, hasLength(2));

    repository.lastWatch.add(gameEvent(EnumGameEventType.gameStarted, [3, 4]));
    await pumpEventQueue();
    expect(engine.current.isReconnecting, isFalse);
    expect(engine.current.moves, [3, 4]);
    engine.dispose();
  });
}
