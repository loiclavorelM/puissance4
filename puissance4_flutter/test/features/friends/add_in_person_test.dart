import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_flutter/features/friends/model/friend_code_scan.dart';
import 'package:puissance4_flutter/features/friends/model/friends_repository.dart';
import 'package:puissance4_flutter/features/friends/view/add_friend_tab.dart';
import 'package:puissance4_flutter/features/friends/view/shake_to_add_sheet.dart';
import 'package:puissance4_flutter/features/friends/viewmodel/add_in_person_viewmodel.dart';
import 'package:puissance4_flutter/features/friends/viewmodel/friends_viewmodel.dart';
import 'package:puissance4_flutter/features/sensors/viewmodel/motion_sensors_provider.dart';
import 'package:puissance4_flutter/features/sensors/viewmodel/shake_provider.dart';

import '../../helpers/l10n.dart';

class _FakeFriendsRepository implements FriendsRepository {
  /// Réponse de [shakeToAdd] ; une exception est levée telle quelle.
  Object? shakeAnswer;
  var shakes = 0;

  @override
  Future<PlayerSearchResultDto?> shakeToAdd() async {
    shakes++;
    final answer = shakeAnswer;
    if (answer is Exception) throw answer;
    return answer as PlayerSearchResultDto?;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PlayerSearchResultDto _bob() => PlayerSearchResultDto(
  player: FriendUserDto(
    userId: UuidValue.fromString('00000000-0000-4000-8000-000000000002'),
    username: 'bob',
    elo: 1000,
  ),
  relation: EnumFriendRelation.none,
);

void main() {
  group('friendCodeFromScan', () {
    test('reads the code, whatever its case or separator', () {
      expect(friendCodeFromScan('P4-7KQ2X9'), 'P4-7KQ2X9');
      expect(friendCodeFromScan(' p4 7kq2x9 '), 'P4-7KQ2X9');
      expect(friendCodeFromScan('p47kq2x9'), 'P4-7KQ2X9');
    });

    test('ignores what is not a friend code', () {
      expect(friendCodeFromScan('https://example.com'), isNull);
      // `O`, `I` et `L` ne sont jamais dans un code (ambigus).
      expect(friendCodeFromScan('P4-7KQ2XO'), isNull);
      expect(friendCodeFromScan('P4-7KQ2'), isNull);
    });
  });

  group('ShakeToAddViewModel', () {
    late _FakeFriendsRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = _FakeFriendsRepository();
      container = ProviderContainer(
        overrides: [
          ...l10nOverrides,
          friendsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      container.listen(shakeToAddProvider, (_, _) {});
    });
    tearDown(() => container.dispose());

    ShakeToAddState read() => container.read(shakeToAddProvider);

    test('a shake that meets another shows that player', () async {
      repository.shakeAnswer = _bob();

      await container.read(shakeToAddProvider.notifier).onShake();

      expect(read().phase, ShakePhase.found);
      expect(read().found?.player.username, 'bob');
    });

    test('a lone shake finds nobody', () async {
      await container.read(shakeToAddProvider.notifier).onShake();

      expect(read().phase, ShakePhase.nobody);
    });

    test('a guest is told to create an account', () async {
      repository.shakeAnswer = FriendsException(
        reason: EnumFriendsError.guestNotAllowed,
      );

      await container.read(shakeToAddProvider.notifier).onShake();

      expect(read().phase, ShakePhase.waiting);
      expect(read().errorMessage, contains('Crée un compte'));
    });
  });

  testWidgets('a shake in the sheet shows the player who shook too', (
    tester,
  ) async {
    final repository = _FakeFriendsRepository()..shakeAnswer = _bob();
    final shakes = StreamController<DateTime>();
    addTearDown(shakes.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...l10nOverrides,
          friendsRepositoryProvider.overrideWithValue(repository),
          shakeProvider.overrideWith((ref) => shakes.stream),
        ],
        child: localizedApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showShakeToAddSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
      find.text('Secoue ton téléphone en même temps que ton ami'),
      findsOneWidget,
    );

    shakes.add(DateTime.now());
    await tester.pumpAndSettle();

    expect(repository.shakes, 1);
    expect(find.text('Trouvé !'), findsOneWidget);
    expect(find.text('bob'), findsOneWidget);
  });

  Future<void> pumpAddTab(
    WidgetTester tester, {
    required bool camera,
    required bool sensors,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...l10nOverrides,
          qrScanSupportedProvider.overrideWithValue(camera),
          motionSensorsProvider.overrideWithValue(sensors),
          friendsOverviewProvider.overrideWith(
            (ref) => Stream.value(
              FriendsOverviewDto(
                friendCode: '7KQ2X9',
                friends: [],
                incoming: [],
                outgoing: [],
              ),
            ),
          ),
          recentOpponentsProvider.overrideWith((ref) async => []),
        ],
        child: localizedApp(home: const Scaffold(body: AddFriendTab())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('on a phone both in-person ways are offered', (tester) async {
    await pumpAddTab(tester, camera: true, sensors: true);

    expect(find.text('Scanner un QR'), findsOneWidget);
    expect(find.text('Secouer'), findsOneWidget);
    expect(find.byTooltip('Afficher mon QR code'), findsOneWidget);
  });

  testWidgets('on a computer only the QR code is shown', (tester) async {
    await pumpAddTab(tester, camera: false, sensors: false);

    expect(find.text('Scanner un QR'), findsNothing);
    expect(find.text('Secouer'), findsNothing);
    expect(find.byTooltip('Afficher mon QR code'), findsOneWidget);
  });
}
