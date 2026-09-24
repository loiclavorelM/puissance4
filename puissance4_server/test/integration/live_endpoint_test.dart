import 'dart:async';

import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Given Live endpoint',
    // Les messages sont postés depuis d'autres sessions que celle du stream :
    // sans commit réel, la ligne `User` insérée par le test ne serait pas
    // visible pour les appels d'endpoint.
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      Future<TestSessionBuilder> signedInAs(String username) async {
        final session = sessionBuilder.build();
        final authUser = await const AuthUsers().create(session);
        await User.db.insertRow(
          session,
          User(authUserId: authUser.id, username: username),
        );
        return sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            authUser.id.uuid,
            {},
          ),
        );
      }

      tearDown(() async {
        final session = sessionBuilder.build();
        await User.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
      });

      test(
        'when a user renames then they get profileChanged and everyone gets leaderboardChanged',
        () async {
          final alice = await signedInAs('alice');
          final bob = await signedInAs('bob');

          final aliceEvents = <EnumLiveEventType>[];
          final bobEvents = <EnumLiveEventType>[];
          final aliceSub = endpoints.live
              .watchUpdates(alice)
              .listen((e) => aliceEvents.add(e.type));
          final bobSub = endpoints.live
              .watchUpdates(bob)
              .listen((e) => bobEvents.add(e.type));
          await flushEventQueue();

          await endpoints.profile.updateUsername(alice, 'alice_2');
          await flushEventQueue();

          expect(
            aliceEvents,
            containsAll([
              EnumLiveEventType.profileChanged,
              EnumLiveEventType.leaderboardChanged,
            ]),
          );
          expect(bobEvents, [EnumLiveEventType.leaderboardChanged]);

          await aliceSub.cancel();
          await bobSub.cancel();
        },
      );

      test(
        'when the leaderboard changes then the cached page is refreshed',
        () async {
          final alice = await signedInAs('alice');

          final before = await endpoints.leaderboard.getLeaderboard(
            alice,
            limit: 100,
            offset: 0,
          );
          expect(before.single.username, 'alice');

          await endpoints.profile.updateUsername(alice, 'alice_2');

          final after = await endpoints.leaderboard.getLeaderboard(
            alice,
            limit: 100,
            offset: 0,
          );
          expect(after.single.username, 'alice_2');
        },
      );
    },
  );
}
