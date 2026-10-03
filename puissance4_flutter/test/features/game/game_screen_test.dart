import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_flutter/features/game/model/game_launch.dart';
import 'package:puissance4_flutter/features/game/model/game_participant.dart';
import 'package:puissance4_flutter/features/game/model/game_snapshot.dart';
import 'package:puissance4_flutter/features/game/model/local_game_engine.dart';
import 'package:puissance4_flutter/features/game/view/game_screen.dart';
import 'package:puissance4_flutter/features/game/view/widgets/connect4_board_view.dart';
import 'package:puissance4_flutter/features/game/view/widgets/replay_bar.dart';
import 'package:puissance4_flutter/features/review/model/move_advisor.dart';
import 'package:puissance4_flutter/features/sensors/viewmodel/shake_provider.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

/// Expert sans isolate : `compute` ne se termine pas sous `pumpAndSettle`.
class _InlineAdvisor implements MoveAdvisor {
  const _InlineAdvisor();

  @override
  Future<MoveAnalysis> analyze(List<int> moves, int index) async =>
      MoveAnalysis.of(moves, index);
}

/// Enregistrement qui ne finit jamais (synchro réseau bloquée).
class _StuckRecorder implements LocalGameRecorder {
  @override
  Future<void> onMove(List<int> moves) async {}

  @override
  Future<void> onEnd(List<int> moves, GameResult result) =>
      Completer<void>().future;
}

void main() {
  late StreamController<(double, double, double, DateTime)> accelerometer;
  setUp(() => accelerometer = StreamController.broadcast());
  tearDown(() => accelerometer.close());

  /// Horloge des mesures : chaque geste arrive après le délai entre deux
  /// secousses du précédent.
  var clock = DateTime(2026);

  /// Trois pics rapprochés : une secousse pour `ShakeDetector`.
  Future<void> shake(WidgetTester tester) async {
    clock = clock.add(const Duration(seconds: 5));
    for (var i = 0; i < 3; i++) {
      accelerometer.add((
        20,
        0,
        0,
        clock.add(Duration(milliseconds: 200 * i)),
      ));
    }
    await tester.pumpAndSettle();
  }

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
        overrides: [
          accelerationProvider.overrideWithValue(accelerometer.stream),
        ],
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

  group('a restartable game (Normal)', () {
    late int restarts;

    /// Normal contre un bot qui joue toujours la colonne 6.
    GameLaunch normal(String title, {LocalGameRecorder? recorder}) =>
        GameLaunch(
          title: title,
          createEngine: (_) => LocalGameEngine(
            rougeSeat: const HumanSeat(),
            jauneSeat: BotSeat((_) async => 6, thinkingTime: Duration.zero),
            rouge: const HumanParticipant(username: 'alice'),
            jaune: const BotParticipant(name: 'Test'),
            myColor: EnumColor.rouge,
            recorder: recorder,
          ),
          restart: (_) async => normal('Partie ${++restarts}'),
        );

    setUp(() => restarts = 0);

    testWidgets('restarts at once on a shake before any move', (tester) async {
      await pump(tester, normal('Partie 0'));
      expect(find.text('Secoue le téléphone pour recommencer'), findsOneWidget);

      await shake(tester);

      expect(find.text('Partie 1'), findsOneWidget);
      expect(find.text('Nouvelle partie !'), findsOneWidget);
    });

    testWidgets('asks first when the restart would count as a loss', (
      tester,
    ) async {
      await pump(tester, normal('Partie 0'));
      await tester.tap(find.byType(Connect4BoardView));
      await tester.pumpAndSettle();

      await shake(tester);
      expect(find.text('Recommencer la partie ?'), findsOneWidget);
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();
      expect(find.text('Partie 0'), findsOneWidget);

      await shake(tester);
      await tester.tap(find.text('Recommencer'));
      await tester.pumpAndSettle();
      expect(find.text('Partie 1'), findsOneWidget);
    });

    testWidgets('restarting does not wait for the forfeit to be saved', (
      tester,
    ) async {
      await pump(tester, normal('Partie 0', recorder: _StuckRecorder()));
      await tester.tap(find.byType(Connect4BoardView));
      await tester.pumpAndSettle();

      await shake(tester);
      await tester.tap(find.text('Recommencer'));
      await tester.pumpAndSettle();

      expect(find.text('Partie 1'), findsOneWidget);
    });

    testWidgets('a game without restart ignores shakes', (tester) async {
      await pump(
        tester,
        GameLaunch(
          title: 'Classé',
          createEngine: (_) => LocalGameEngine(
            rougeSeat: const HumanSeat(),
            jauneSeat: const HumanSeat(),
            rouge: const HumanParticipant(username: 'alice'),
            jaune: const HumanParticipant(username: 'bob'),
          ),
        ),
      );
      expect(find.text('Secoue le téléphone pour recommencer'), findsNothing);

      await shake(tester);
      expect(find.text('Classé'), findsOneWidget);
      expect(accelerometer.hasListener, isFalse);
    });
  });
}
