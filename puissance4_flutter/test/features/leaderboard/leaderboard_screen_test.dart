import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_flutter/features/leaderboard/view/leaderboard_screen.dart';
import 'package:puissance4_flutter/features/leaderboard/viewmodel/leaderboard_viewmodel.dart';

void main() {
  LeaderboardEntryDto entry(int rank, String username) => LeaderboardEntryDto(
    id: UuidValue.fromString('00000000-0000-4000-8000-00000000000$rank'),
    rank: rank,
    username: username,
    elo: 1600 - rank * 100,
  );

  Future<void> pump(WidgetTester tester, LeaderboardState state) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          leaderboardProvider.overrideWith((ref) => Stream.value(state)),
        ],
        child: const MaterialApp(home: Scaffold(body: LeaderboardScreen())),
      ),
    );
    await tester.pumpAndSettle();
  }

  final entries = [
    for (final (i, name) in ['ana', 'ben', 'cleo', 'dan', 'eve'].indexed)
      entry(i + 1, name),
  ];

  testWidgets('my row is marked inside the list', (tester) async {
    await pump(tester, LeaderboardState(entries: entries, myRank: entries[3]));

    expect(find.text('Toi · dan'), findsOneWidget);
    expect(find.text('eve'), findsOneWidget);
  });

  testWidgets('my place is marked on the podium', (tester) async {
    await pump(tester, LeaderboardState(entries: entries, myRank: entries[1]));

    expect(find.text('Toi · ben'), findsOneWidget);
  });

  testWidgets('my row is pinned when outside the loaded page', (tester) async {
    await pump(
      tester,
      LeaderboardState(entries: entries, myRank: entry(9, 'zoe')),
    );

    expect(find.text('Toi · zoe'), findsOneWidget);
  });
}
