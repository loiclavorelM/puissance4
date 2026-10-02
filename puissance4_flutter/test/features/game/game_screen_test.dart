import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_flutter/features/game/model/game_launch.dart';
import 'package:puissance4_flutter/features/game/model/game_participant.dart';
import 'package:puissance4_flutter/features/game/model/local_game_engine.dart';
import 'package:puissance4_flutter/features/game/view/game_screen.dart';
import 'package:puissance4_flutter/features/game/view/widgets/connect4_board_view.dart';
import 'package:puissance4_flutter/features/game/view/widgets/replay_bar.dart';
import 'package:puissance4_flutter/features/review/model/move_advisor.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

/// Expert sans isolate : `compute` ne se termine pas sous `pumpAndSettle`.
class _InlineAdvisor implements MoveAdvisor {
  const _InlineAdvisor();

  @override
  Future<MoveAnalysis> analyze(List<int> moves, int index) async =>
      MoveAnalysis.of(moves, index);
}

void main() {
  Future<void> pump(
    WidgetTester tester,
    GameLaunch launch, {
    Size size = const Size(1080, 2340),
    double pixelRatio = 3,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = pixelRatio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: GameScreen(launch: launch)),
      ),
    );
  }

  testWidgets('a local game is played by tapping the board', (tester) async {
    final launch = GameLaunch(
      title: 'Deux joueurs',
      createEngine: (_) => LocalGameEngine(
        rougeSeat: const HumanSeat(),
        jauneSeat: const HumanSeat(),
        rouge: const HumanParticipant(username: 'alice'),
        jaune: const HumanParticipant(username: 'bob'),
      ),
    );
    await pump(tester, launch);

    expect(find.text('À alice de jouer'), findsOneWidget);
    expect(find.text('Abandonner'), findsOneWidget);
    expect(find.byType(ReplayBar), findsNothing);

    await tester.tap(find.byType(Connect4BoardView));
    await tester.pumpAndSettle();

    expect(find.text('À bob de jouer'), findsOneWidget);
  });

  testWidgets('a replay shows its controls and ignores taps', (tester) async {
    final launch = GameLaunch.replay(
      moves: const [3, 4, 3],
      rouge: const HumanParticipant(username: 'alice'),
      jaune: const BotParticipant(name: 'Test'),
      myColor: EnumColor.rouge,
      advisor: const _InlineAdvisor(),
    );
    await pump(tester, launch);

    expect(find.byType(ReplayBar), findsOneWidget);
    expect(find.text('Coup 0 / 3'), findsOneWidget);
    expect(find.text('Abandonner'), findsNothing);

    await tester.tap(find.byTooltip('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Coup 1 / 3'), findsOneWidget);
    expect(find.text('Tu as joué la colonne 4'), findsOneWidget);
    expect(find.text('Expliquer ce coup'), findsOneWidget);

    await tester.tap(find.byType(Connect4BoardView));
    await tester.pumpAndSettle();
    expect(find.text('Coup 1 / 3'), findsOneWidget);
  });

  for (final (name, size, ratio) in [
    ('wide desktop window', const Size(2560, 1342), 1.0),
    ('phone', const Size(1080, 2340), 3.0),
  ]) {
    testWidgets('on a $name the whole board fits on screen', (tester) async {
      final launch = GameLaunch(
        title: 'Normal',
        createEngine: (_) => LocalGameEngine(
          rougeSeat: const HumanSeat(),
          jauneSeat: const HumanSeat(),
          rouge: const HumanParticipant(username: 'alice'),
          jaune: const HumanParticipant(username: 'bob'),
        ),
      );
      await pump(tester, launch, size: size, pixelRatio: ratio);

      expect(tester.takeException(), isNull);
      final screen = Offset.zero & (size / ratio);
      final board = tester.getRect(find.byType(Connect4BoardView));
      expect(screen.contains(board.topLeft), isTrue);
      expect(screen.contains(board.bottomRight - const Offset(1, 1)), isTrue);
      expect(
        tester.getRect(find.text('Abandonner')).bottom,
        lessThanOrEqualTo(screen.bottom),
      );
    });
  }
}
