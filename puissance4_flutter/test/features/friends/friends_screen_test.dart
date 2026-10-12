import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_flutter/features/friends/model/friends_repository.dart';
import 'package:puissance4_flutter/features/friends/view/friends_screen.dart';
import 'package:puissance4_flutter/features/friends/viewmodel/friends_viewmodel.dart';

import '../../helpers/l10n.dart';

class _FakeFriendsRepository implements FriendsRepository {
  _FakeFriendsRepository(this.results);

  final List<PlayerSearchResultDto> results;
  final queries = <String>[];

  @override
  Future<List<PlayerSearchResultDto>> search(String query) async {
    queries.add(query);
    return results;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  var nextId = 0;
  UuidValue id() => UuidValue.fromString(
    '00000000-0000-4000-8000-${(nextId++).toString().padLeft(12, '0')}',
  );
  FriendUserDto player(String username) =>
      FriendUserDto(userId: id(), username: username, elo: 1000);
  FriendshipDto friendship(
    String username, {
    EnumFriendshipStatus status = EnumFriendshipStatus.accepted,
    bool incoming = false,
  }) => FriendshipDto(
    id: id(),
    other: player(username),
    status: status,
    incoming: incoming,
    createdAt: DateTime.now(),
  );

  var recentLoads = 0;
  setUp(() => recentLoads = 0);

  Future<void> pump(
    WidgetTester tester, {
    FriendsAccess access = FriendsAccess.member,
    FriendsOverviewDto? overview,
    FriendsRepository? repository,
    List<PlayerSearchResultDto> recent = const [],
    List<RivalryDto> rivalries = const [],
    List<FriendActivityDto> activity = const [],
  }) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...l10nOverrides,
          friendsAccessProvider.overrideWithValue(access),
          friendsOverviewProvider.overrideWith((ref) => Stream.value(overview)),
          rivalriesProvider.overrideWith((ref) async => rivalries),
          friendsActivityProvider.overrideWith((ref) async => activity),
          recentOpponentsProvider.overrideWith((ref) async {
            recentLoads++;
            return recent;
          }),
          if (repository != null)
            friendsRepositoryProvider.overrideWithValue(repository),
        ],
        child: localizedApp(home: const Scaffold(body: FriendsScreen())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('another screen can open the Add tab', (tester) async {
    await pump(
      tester,
      overview: FriendsOverviewDto(
        friendCode: '7KQ2X9',
        friends: [],
        incoming: [],
        outgoing: [],
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(FriendsScreen)),
    );

    container
        .read(friendsTabRequestProvider.notifier)
        .open(FriendsScreen.addTabIndex);
    await tester.pumpAndSettle();

    expect(find.text('P4-7KQ2X9'), findsOneWidget);
    expect(container.read(friendsTabRequestProvider), isNull);
  });

  testWidgets('a guest is invited to create an account', (tester) async {
    await pump(tester, access: FriendsAccess.guest);

    expect(find.text('Créer un compte'), findsOneWidget);
    expect(find.text('Mes amis'), findsNothing);
  });

  testWidgets('friends are listed and requests are counted', (tester) async {
    await pump(
      tester,
      overview: FriendsOverviewDto(
        friendCode: '7KQ2X9',
        friends: [friendship('bob')],
        incoming: [
          friendship(
            'carol',
            status: EnumFriendshipStatus.pending,
            incoming: true,
          ),
        ],
        outgoing: [],
      ),
    );

    expect(find.text('bob'), findsOneWidget);
    // Badge du sous-onglet Demandes.
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('Demandes'));
    await tester.pumpAndSettle();
    expect(find.text('carol'), findsOneWidget);
    expect(find.text('REÇUES'), findsOneWidget);
  });

  testWidgets('searching shows my code and the matching players', (
    tester,
  ) async {
    final repository = _FakeFriendsRepository([
      PlayerSearchResultDto(
        player: player('dave'),
        relation: EnumFriendRelation.none,
      ),
      PlayerSearchResultDto(
        player: player('davina'),
        relation: EnumFriendRelation.friend,
      ),
    ]);
    await pump(
      tester,
      repository: repository,
      overview: FriendsOverviewDto(
        friendCode: '7KQ2X9',
        friends: [],
        incoming: [],
        outgoing: [],
      ),
    );

    await tester.tap(find.text('Ajouter').first);
    await tester.pumpAndSettle();
    expect(find.text('P4-7KQ2X9'), findsOneWidget);

    // Trop court : pas d'appel serveur.
    await tester.enterText(find.byType(TextField), 'da');
    await tester.pump(FriendSearchViewModel.debounce);
    expect(repository.queries, isEmpty);

    await tester.enterText(find.byType(TextField), 'dav');
    await tester.pump(FriendSearchViewModel.debounce);
    await tester.pumpAndSettle();
    expect(repository.queries, ['dav']);
    expect(find.text('dave'), findsOneWidget);
    expect(find.text('Ami'), findsOneWidget);
  });

  testWidgets('friends show their presence; only online ones can be '
      'challenged', (tester) async {
    FriendshipDto withPresence(
      String name,
      EnumFriendPresence presence, {
      EnumType? playing,
      DateTime? lastSeenAt,
    }) => friendship(name).copyWith(
      presence: presence,
      playing: playing,
      lastSeenAt: lastSeenAt,
    );
    await pump(
      tester,
      overview: FriendsOverviewDto(
        friendCode: '7KQ2X9',
        friends: [
          withPresence('ana', EnumFriendPresence.online),
          withPresence(
            'ben',
            EnumFriendPresence.playing,
            playing: EnumType.classe,
          ),
          withPresence(
            'cleo',
            EnumFriendPresence.offline,
            lastSeenAt: DateTime.now().subtract(const Duration(hours: 3)),
          ),
        ],
        incoming: [],
        outgoing: [],
      ),
    );

    expect(find.text('En ligne'), findsOneWidget);
    expect(find.text('En partie · Classé'), findsOneWidget);
    expect(find.text('Vu il y a 3 h'), findsOneWidget);
    final challengeButtons = tester
        .widgetList<IconButton>(
          find.widgetWithIcon(IconButton, Icons.sports_esports),
        )
        .map((b) => b.onPressed != null)
        .toList();
    expect(challengeButtons, [true, false, false]);
  });

  testWidgets('recent opponents are offered under an empty search', (
    tester,
  ) async {
    await pump(
      tester,
      overview: FriendsOverviewDto(
        friendCode: '7KQ2X9',
        friends: [],
        incoming: [],
        outgoing: [],
      ),
      recent: [
        PlayerSearchResultDto(
          player: player('rival'),
          relation: EnumFriendRelation.none,
        ),
      ],
    );

    await tester.tap(find.text('Ajouter').first);
    await tester.pumpAndSettle();

    expect(find.text('RENCONTRÉS RÉCEMMENT'), findsOneWidget);
    expect(find.text('rival'), findsOneWidget);
  });

  testWidgets('without recent opponents the section explains itself', (
    tester,
  ) async {
    await pump(
      tester,
      overview: FriendsOverviewDto(
        friendCode: '7KQ2X9',
        friends: [],
        incoming: [],
        outgoing: [],
      ),
    );

    await tester.tap(find.text('Ajouter').first);
    await tester.pumpAndSettle();

    expect(find.text('RENCONTRÉS RÉCEMMENT'), findsOneWidget);
    expect(
      find.text(
        'Tes adversaires en Multi apparaîtront ici, pour les ajouter en un tap.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('opening the Add tab reloads recent opponents', (tester) async {
    await pump(
      tester,
      overview: FriendsOverviewDto(
        friendCode: '7KQ2X9',
        friends: [friendship('bob')],
        incoming: [],
        outgoing: [],
      ),
    );

    await tester.tap(find.text('Ajouter').first);
    await tester.pumpAndSettle();
    final first = recentLoads;
    expect(first, greaterThan(0));

    await tester.tap(find.text('Mes amis'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajouter').first);
    await tester.pumpAndSettle();

    expect(recentLoads, greaterThan(first));
  });

  testWidgets('rivalries show the activity feed and head-to-head records', (
    tester,
  ) async {
    final bob = player('bob');
    await pump(
      tester,
      overview: FriendsOverviewDto(
        friendCode: '7KQ2X9',
        friends: [friendship('bob')],
        incoming: [],
        outgoing: [],
      ),
      rivalries: [
        RivalryDto(
          friend: bob,
          wins: 3,
          losses: 1,
          draws: 0,
          streak: 2,
          partieIds: [id()],
          lastPlayedAt: DateTime.now(),
        ),
        RivalryDto(
          friend: player('cleo'),
          wins: 0,
          losses: 0,
          draws: 0,
          streak: 0,
          partieIds: [],
        ),
      ],
      activity: [
        FriendActivityDto(
          partieId: id(),
          friend: bob,
          typePartie: EnumType.classe,
          result: EnumMatchResult.win,
          opponent: 'Expert',
          eloVariation: 24,
          at: DateTime.now(),
        ),
      ],
    );

    await tester.tap(find.text('Rivalités'));
    await tester.pumpAndSettle();

    expect(find.text('ACTIVITÉ DE TES AMIS'), findsOneWidget);
    expect(find.textContaining('bob a gagné en Classé'), findsOneWidget);
    expect(find.text('+24'), findsOneWidget);
    expect(find.text('3 V · 1 D · 0 N'), findsOneWidget);
    expect(find.text('🔥 2'), findsOneWidget);
    expect(find.text('Pas encore joué ensemble'), findsOneWidget);
  });
}
