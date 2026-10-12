import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_flutter/features/game/model/game_participant.dart';
import 'package:puissance4_flutter/features/game/model/game_snapshot.dart';
import 'package:puissance4_flutter/features/game/model/replay_game_engine.dart';
import 'package:puissance4_flutter/features/review/model/move_advisor.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

/// Avis calculés en direct, appels comptés.
class _CountingAdvisor implements MoveAdvisor {
  final requested = <int>[];

  @override
  Future<MoveAnalysis> analyze(List<int> moves, int index) async {
    requested.add(index);
    return MoveAnalysis.of(moves, index);
  }
}

void main() {
  ReplayGameEngine replay() => ReplayGameEngine(
    moves: const [0, 1, 0, 1, 0, 1, 0],
    rouge: const HumanParticipant(username: 'alice'),
    jaune: const BotParticipant(name: 'Test'),
    myColor: EnumColor.rouge,
    result: const GameResult(
      winner: EnumOutcome.rouge,
      endReason: EnumGameEndReason.connectFour,
    ),
  );

  test('a replay starts on an empty board and never accepts input', () async {
    final engine = replay();
    expect(engine.current.moves, isEmpty);
    expect(engine.current.replay?.total, 7);
    expect(engine.current.acceptsInput, isFalse);
    expect(engine.current.isLive, isFalse);

    await engine.play(3);
    expect(engine.current.moves, isEmpty);
  });

  test('next / previous move the cursor within bounds', () {
    final engine = replay();
    engine.previous();
    expect(engine.current.replay?.cursor, 0);

    engine
      ..next()
      ..next();
    expect(engine.current.moves, [0, 1]);

    engine.previous();
    expect(engine.current.moves, [0]);
  });

  test('the result only shows once the last move is reached', () {
    final engine = replay();
    engine.next();
    expect(engine.current.result, isNull);

    engine.last();
    expect(engine.current.result?.winner, EnumOutcome.rouge);
    expect(engine.current.winningCells, hasLength(4));

    engine.first();
    expect(engine.current.moves, isEmpty);
  });

  test('autoplay steps through the moves', () async {
    final engine = replay();
    engine.togglePlay();
    expect(engine.current.replay?.isPlaying, isTrue);

    await Future<void>.delayed(
      ReplayGameEngine.autoPlayInterval * 2 + const Duration(milliseconds: 100),
    );
    expect(engine.current.replay?.cursor, 2);

    engine.togglePlay();
    expect(engine.current.replay?.isPlaying, isFalse);
    engine.dispose();
  });

  test('with an advisor each shown move gets the Expert analysis', () async {
    final advisor = _CountingAdvisor();
    // Jaune (coup d'indice 5) ne bloque pas Rouge en colonne 3.
    final engine = ReplayGameEngine(
      moves: const [0, 6, 1, 6, 2, 6, 3],
      rouge: const HumanParticipant(username: 'alice'),
      jaune: const BotParticipant(name: 'Test'),
      advisor: advisor,
    );
    expect(engine.current.replay?.analysis, isNull);

    for (var i = 0; i < 6; i++) {
      engine.next();
    }
    await pumpEventQueue();
    final analysis = engine.current.replay?.analysis;
    expect(analysis?.played, 6);
    expect(analysis?.recommended, 3);
    expect(analysis?.playedVerdict, MoveVerdict.forcedLoss);

    // Revenir sur un coup déjà analysé ne relance pas l'analyse.
    engine
      ..previous()
      ..next();
    await pumpEventQueue();
    expect(advisor.requested.where((i) => i == 5), hasLength(1));
    expect(engine.current.replay?.analysis?.played, 6);
    engine.dispose();
  });
}
