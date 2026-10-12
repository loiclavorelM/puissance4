import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:puissance4_server/src/live/live_notifier.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Leaderboard endpoint', (sessionBuilder, endpoints) {
    /// Crée un joueur avec cet Elo et renvoie sa session et son `User`.
    Future<(TestSessionBuilder, User)> player(String username, int elo) async {
      final session = sessionBuilder.build();
      final authUser = await const AuthUsers().create(session);
      final user = await User.db.insertRow(
        session,
        User(authUserId: authUser.id, username: username, elo: elo),
      );
      return (
        sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            authUser.id.uuid,
            {},
          ),
        ),
        user,
      );
    }

    test('when reading a page then players are ranked by Elo', () async {
      final (alice, _) = await player('alice', 1100);
      await player('bob', 1300);
      await player('carol', 900);

      final top = await endpoints.leaderboard.getLeaderboard(
        alice,
        limit: 2,
        offset: 0,
      );
      final next = await endpoints.leaderboard.getLeaderboard(
        alice,
        limit: 2,
        offset: 2,
      );

      expect(top.map((e) => (e.rank, e.username)), [(1, 'bob'), (2, 'alice')]);
      expect(next.map((e) => (e.rank, e.username)), [(3, 'carol')]);
    });

    test(
      'when asking for its rank then a player gets it outside the page',
      () async {
        for (var i = 0; i < 3; i++) {
          await player('top$i', 1500 + i);
        }
        final (dave, me) = await player('dave', 1000);

        final rank = await endpoints.leaderboard.getMyRank(dave);

        expect(rank.id, me.id);
        expect(rank.rank, 4);
        expect(rank.elo, 1000);
      },
    );

    test('when an Elo changes then the cached page is refreshed', () async {
      final (alice, aliceUser) = await player('alice', 1000);
      await player('bob', 1200);
      await endpoints.leaderboard.getLeaderboard(alice, limit: 10, offset: 0);

      final session = sessionBuilder.build();
      await User.db.updateRow(session, aliceUser.copyWith(elo: 1400));
      await notifyLeaderboardChanged(session);

      final page = await endpoints.leaderboard.getLeaderboard(
        alice,
        limit: 10,
        offset: 0,
      );
      expect(page.first.username, 'alice');
      expect(page.first.elo, 1400);
    });
  });
}
