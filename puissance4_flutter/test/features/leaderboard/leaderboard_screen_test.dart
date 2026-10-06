import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_flutter/features/friends/viewmodel/friends_viewmodel.dart';
import 'package:puissance4_flutter/features/leaderboard/view/leaderboard_screen.dart';
import 'package:puissance4_flutter/features/leaderboard/viewmodel/leaderboard_viewmodel.dart';

import '../../helpers/l10n.dart';

void main() {
  LeaderboardEntryDto entry(int rank, String username) => LeaderboardEntryDto(
    id: UuidValue.fromString('00000000-0000-4000-8000-00000000000$rank'),
    rank: rank,
    username: username,
    elo: 1600 - rank * 100,
  );

  Future<void> pump(
    WidgetTester tester,
    LeaderboardState state, {
    FriendsAccess access = FriendsAccess.member,
    List<FriendshipDto> friends = const [],
    VoidCallback? onAddFriends,
  }) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...l10nOverrides,
          leaderboardProvider.overrideWith((ref) => Stream.value(state)),
          friendsAccessProvider.overrideWithValue(access),
          friendsOverviewProvider.overrideWith(
            (ref) => Stream.value(
              FriendsOverviewDto(
                friendCode: '7KQ2X9',
                friends: friends,
                incoming: [],
                outgoing: [],
              ),
            ),
          ),
        ],
        child: localizedApp(
          home: Scaffold(body: LeaderboardScreen(onAddFriends: onAddFriends)),
        ),
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

  FriendshipDto friendOf(LeaderboardEntryDto entry) => FriendshipDto(
    id: entry.id,
    other: FriendUserDto(
      userId: entry.id,
      username: entry.username,
      elo: entry.elo,
    ),
    status: EnumFriendshipStatus.accepted,
    incoming: false,
    createdAt: DateTime(2026),
  );

  testWidgets('the friends filter ranks me among my friends only', (
    tester,
  ) async {
    // Classement global : je suis 9e, hors page ; mes amis sont ana et eve.
    await pump(
      tester,
      LeaderboardState(entries: entries, myRank: entry(9, 'zoe')),
      friends: [friendOf(entries[0]), friendOf(entries[4])],
    );

    await tester.tap(find.text('Amis'));
    await tester.pumpAndSettle();

    expect(find.text('ben'), findsNothing);
    expect(find.text('ana'), findsOneWidget);
    expect(find.text('eve'), findsOneWidget);
    // 3e sur 3 : sur le podium, plus de ligne épinglée.
    expect(find.text('Toi · zoe'), findsOneWidget);
    expect(find.text('···'), findsNothing);
  });

  testWidgets('without friends the filter offers to add some', (tester) async {
    var opened = false;
    await pump(
      tester,
      LeaderboardState(entries: entries, myRank: entries[1]),
      onAddFriends: () => opened = true,
    );

    await tester.tap(find.text('Amis'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajouter des amis'));

    expect(
      find.text('Ajoute des amis pour te comparer à eux.'),
      findsOneWidget,
    );
    expect(opened, isTrue);
  });

  testWidgets('a guest is invited to create an account', (tester) async {
    await pump(
      tester,
      LeaderboardState(entries: entries, myRank: entries[1]),
      access: FriendsAccess.guest,
    );

    await tester.tap(find.text('Amis'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Crée un compte pour ajouter des amis : tu gardes ta progression.',
      ),
      findsOneWidget,
    );
  });
}
