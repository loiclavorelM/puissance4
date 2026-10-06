import 'package:puissance4_server/src/friends/friend_code.dart';
import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Friends endpoint (E15)', (sessionBuilder, endpoints) {
    /// Crée un joueur (compte email, ou invité si [guest]) et renvoie sa
    /// session et son `User`.
    Future<(TestSessionBuilder, User)> player(
      String username, {
      int elo = 1000,
      bool guest = false,
    }) async {
      final session = sessionBuilder.build();
      final authUser = await const AuthUsers().create(session);
      if (guest) {
        await AnonymousAccount.db.insertRow(
          session,
          AnonymousAccount(authUserId: authUser.id),
        );
      }
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

    Matcher refusedWith(EnumFriendsError reason) => throwsA(
      isA<FriendsException>().having((e) => e.reason, 'reason', reason),
    );

    test(
      'when a request is accepted then both see each other as friends',
      () async {
        final (alice, aliceUser) = await player('alice');
        final (bob, bobUser) = await player('bob', elo: 1200);

        final request = await endpoints.friends.sendRequest(alice, bobUser.id!);
        expect(request.status, EnumFriendshipStatus.pending);
        expect(request.incoming, isFalse);

        final bobOverview = await endpoints.friends.getOverview(bob);
        expect(bobOverview.incoming.single.other.username, 'alice');
        expect(bobOverview.friends, isEmpty);

        await endpoints.friends.acceptRequest(bob, request.id);

        final aliceOverview = await endpoints.friends.getOverview(alice);
        expect(aliceOverview.friends.single.other.userId, bobUser.id);
        expect(aliceOverview.outgoing, isEmpty);
        final bobFriends = await endpoints.friends.getOverview(bob);
        expect(bobFriends.friends.single.other.userId, aliceUser.id);
      },
    );

    test(
      'when both send a request then the second one accepts the first',
      () async {
        final (alice, aliceUser) = await player('alice');
        final (bob, bobUser) = await player('bob');

        await endpoints.friends.sendRequest(alice, bobUser.id!);
        final result = await endpoints.friends.sendRequest(bob, aliceUser.id!);

        expect(result.status, EnumFriendshipStatus.accepted);
      },
    );

    test(
      'when sending twice or to oneself then the request is refused',
      () async {
        final (alice, aliceUser) = await player('alice');
        final (_, bobUser) = await player('bob');

        await endpoints.friends.sendRequest(alice, bobUser.id!);

        await expectLater(
          endpoints.friends.sendRequest(alice, bobUser.id!),
          refusedWith(EnumFriendsError.requestAlreadySent),
        );
        await expectLater(
          endpoints.friends.sendRequest(alice, aliceUser.id!),
          refusedWith(EnumFriendsError.cannotAddSelf),
        );
      },
    );

    test('when declined or cancelled then the request disappears', () async {
      final (alice, _) = await player('alice');
      final (bob, bobUser) = await player('bob');

      final first = await endpoints.friends.sendRequest(alice, bobUser.id!);
      await endpoints.friends.declineRequest(bob, first.id);
      expect((await endpoints.friends.getOverview(alice)).outgoing, isEmpty);

      final second = await endpoints.friends.sendRequest(alice, bobUser.id!);
      // Seul le destinataire peut accepter, seul l'expéditeur peut annuler.
      await expectLater(
        endpoints.friends.acceptRequest(alice, second.id),
        refusedWith(EnumFriendsError.requestNotFound),
      );
      await expectLater(
        endpoints.friends.cancelRequest(bob, second.id),
        refusedWith(EnumFriendsError.requestNotFound),
      );
      await endpoints.friends.cancelRequest(alice, second.id);
      expect((await endpoints.friends.getOverview(bob)).incoming, isEmpty);
    });

    test('when a friend is removed then both lists are emptied', () async {
      final (alice, aliceUser) = await player('alice');
      final (bob, bobUser) = await player('bob');
      final request = await endpoints.friends.sendRequest(alice, bobUser.id!);
      await endpoints.friends.acceptRequest(bob, request.id);

      await endpoints.friends.removeFriend(bob, aliceUser.id!);

      expect((await endpoints.friends.getOverview(alice)).friends, isEmpty);
      await expectLater(
        endpoints.friends.removeFriend(alice, bobUser.id!),
        refusedWith(EnumFriendsError.notFriends),
      );
    });

    test('when searching then guests and oneself are left out', () async {
      final (alice, _) = await player('alice');
      await player('alicia');
      await player('alix', guest: true);
      final (_, bobUser) = await player('bob');
      await endpoints.friends.sendRequest(alice, bobUser.id!);

      final byName = await endpoints.friends.searchPlayers(alice, 'ali');
      expect(byName.map((r) => r.player.username), ['alicia']);
      expect(await endpoints.friends.searchPlayers(alice, 'al'), isEmpty);

      final bob = await endpoints.friends.searchPlayers(alice, 'bob');
      expect(bob.single.relation, EnumFriendRelation.requestSent);
    });

    test('when searching a friend code then its owner comes first', () async {
      final (alice, _) = await player('alice');
      final (bob, _) = await player('bob');
      final code = (await endpoints.friends.getOverview(bob)).friendCode;

      // Le code reste le même d'un appel à l'autre.
      expect((await endpoints.friends.getOverview(bob)).friendCode, code);
      final results = await endpoints.friends.searchPlayers(
        alice,
        'p4-${code.toLowerCase()}',
      );
      expect(results.single.player.username, 'bob');
    });

    test('when a guest uses friends then it is refused', () async {
      final (guest, _) = await player('guest', guest: true);
      final (alice, aliceUser) = await player('alice');
      final (_, guestUser) = await player('ghost', guest: true);

      await expectLater(
        endpoints.friends.getOverview(guest),
        refusedWith(EnumFriendsError.guestNotAllowed),
      );
      await expectLater(
        endpoints.friends.sendRequest(guest, aliceUser.id!),
        refusedWith(EnumFriendsError.guestNotAllowed),
      );
      await expectLater(
        endpoints.friends.sendRequest(alice, guestUser.id!),
        refusedWith(EnumFriendsError.userNotFound),
      );
    });
  });

  group('FriendCode.parse', () {
    test('accepts the code with or without prefix, in any case', () {
      expect(FriendCode.parse('P4-7KQ2X9'), '7KQ2X9');
      expect(FriendCode.parse(' p4 7kq2x9 '), '7KQ2X9');
      expect(FriendCode.parse('7kq2x9'), '7KQ2X9');
    });

    test('rejects what cannot be a code', () {
      expect(FriendCode.parse('7KQ2X'), isNull);
      // `O` et `1` ne sont jamais tirés (ambigus avec `0` et `I`).
      expect(FriendCode.parse('7KQ2O1'), isNull);
    });

    test('generates parsable codes', () {
      final code = FriendCode.generate();
      expect(FriendCode.parse(code), code);
    });
  });
}
