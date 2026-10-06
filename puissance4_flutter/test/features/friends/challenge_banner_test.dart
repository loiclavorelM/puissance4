import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_flutter/features/friends/view/challenge_banner.dart';
import 'package:puissance4_flutter/features/friends/viewmodel/friends_viewmodel.dart';

import '../../helpers/l10n.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    List<FriendChallengeDto> challenges,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...l10nOverrides,
          friendChallengesProvider.overrideWith((ref) async => challenges),
        ],
        child: localizedApp(home: const Scaffold(body: ChallengeBanner())),
      ),
    );
    await tester.pump();
  }

  testWidgets('a received challenge is shown with accept and decline', (
    tester,
  ) async {
    await pump(tester, [
      FriendChallengeDto(
        code: 'ABC234',
        from: FriendUserDto(
          userId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
          username: 'alice',
          elo: 1100,
        ),
        expiresAt: DateTime.now().add(const Duration(minutes: 2)),
      ),
    ]);

    expect(find.text('alice te défie !'), findsOneWidget);
    expect(find.text('Accepter'), findsOneWidget);
    expect(find.byTooltip('Refuser'), findsOneWidget);
  });

  testWidgets('no challenge, no banner', (tester) async {
    await pump(tester, []);

    expect(find.byType(FilledButton), findsNothing);
  });
}
