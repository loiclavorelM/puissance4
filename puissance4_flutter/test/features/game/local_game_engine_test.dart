import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_flutter/features/game/model/game_participant.dart';
import 'package:puissance4_flutter/features/game/model/game_snapshot.dart';
import 'package:puissance4_flutter/features/game/model/local_game_engine.dart';

class _Recorder implements LocalGameRecorder {
  final moves = <List<int>>[];
  GameResult? ended;

  @override
  Future<void> onMove(List<int> moves) async => this.moves.add(moves);

  @override
  Future<void> onEnd(List<int> moves, GameResult result) async =>
      ended = result;
}

void main() {
  late _Recorder recorder;

  /// Humain (rouge) contre un bot qui joue toujours la colonne 6.
  LocalGameEngine humanVsBot() => LocalGameEngine(
    rougeSeat: const HumanSeat(),
    jauneSeat: BotSeat((_) async => 6, thinkingTime: Duration.zero),
    rouge: const HumanParticipant(username: 'alice'),
    jaune: const BotParticipant(name: 'Test'),
    myColor: EnumColor.rouge,
    recorder: recorder,
  );

  setUp(() => recorder = _Recorder());

  test(
    'the human plays, then the bot answers and it is the human again',
    () async {
      final engine = humanVsBot();
      expect(engine.current.acceptsInput, isTrue);

      await engine.play(3);

      expect(engine.current.moves, [3, 6]);
      expect(engine.current.acceptsInput, isTrue);
      expect(recorder.moves.last, [3, 6]);
    },
  );

  test('a full column is ignored', () async {
    final engine = LocalGameEngine(
      rougeSeat: const HumanSeat(),
      jauneSeat: const HumanSeat(),
      rouge: const HumanParticipant(username: 'a'),
      jaune: const HumanParticipant(username: 'b'),
    );
    for (var i = 0; i < 6; i++) {
      await engine.play(0);
    }
    await engine.play(0);
    expect(engine.current.moves, hasLength(6));
  });

  test('four in a column ends the game with a connectFour win', () async {
    final engine = humanVsBot();
    for (var i = 0; i < 4; i++) {
      await engine.play(0);
    }

    final result = engine.current.result!;
    expect(result.winner, EnumOutcome.rouge);
    expect(result.endReason, EnumGameEndReason.connectFour);
    expect(engine.current.acceptsInput, isFalse);
    expect(engine.current.winningCells, hasLength(4));
    expect(recorder.ended?.winner, EnumOutcome.rouge);
  });

  test('abandoning after a move is a forfeit loss', () async {
    final engine = humanVsBot();
    await engine.play(3);

    await engine.abandon();

    expect(engine.current.result?.winner, EnumOutcome.jaune);
    expect(engine.current.result?.endReason, EnumGameEndReason.forfeit);
    expect(recorder.ended?.winner, EnumOutcome.jaune);
  });

  test('abandoning before any move cancels the game', () async {
    final engine = humanVsBot();

    await engine.abandon();

    expect(engine.current.result?.winner, isNull);
    expect(engine.current.result?.endReason, EnumGameEndReason.cancelled);
  });

  test('a bot playing rouge opens the game by itself', () async {
    final engine = LocalGameEngine(
      rougeSeat: BotSeat((_) async => 3, thinkingTime: Duration.zero),
      jauneSeat: const HumanSeat(),
      rouge: const BotParticipant(name: 'Test'),
      jaune: const HumanParticipant(username: 'alice'),
      myColor: EnumColor.jaune,
    );
    expect(engine.current.acceptsInput, isFalse);
    await pumpEventQueue();
    expect(engine.current.moves, [3]);
    expect(engine.current.acceptsInput, isTrue);
  });
}
