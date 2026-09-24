import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:puissance4_server/src/profile/user_provisioning.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Profile endpoint', (sessionBuilder, endpoints) {
    /// Crée un AuthUser + son User (comme le hook `onAfterAuthUserCreated`)
    /// et renvoie une session authentifiée en son nom.
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

    test('when updating username then the returned profile has it', () async {
      final alice = await signedInAs('alice');

      final profile = await endpoints.profile.updateUsername(
        alice,
        ' Alice_2 ',
      );

      expect(profile.username, 'Alice_2');
      final reloaded = await endpoints.profile.getMyProfile(alice);
      expect(reloaded.username, 'Alice_2');
    });

    test('when username has an invalid format then it is refused', () async {
      final alice = await signedInAs('alice');

      for (final invalid in ['ab', 'a' * 21, 'avec espace', 'émile']) {
        await expectLater(
          endpoints.profile.updateUsername(alice, invalid),
          throwsA(
            isA<ProfileUpdateException>().having(
              (e) => e.reason,
              'reason',
              EnumProfileUpdateError.invalidUsername,
            ),
          ),
        );
      }
    });

    test(
      'when username is taken by another user with different case then it is refused',
      () async {
        await signedInAs('Bob_x');
        final alice = await signedInAs('alice');

        await expectLater(
          endpoints.profile.updateUsername(alice, 'bob_X'),
          throwsA(
            isA<ProfileUpdateException>().having(
              (e) => e.reason,
              'reason',
              EnumProfileUpdateError.usernameTaken,
            ),
          ),
        );
      },
    );

    test('when `_` is used then it is not treated as a wildcard', () async {
      await signedInAs('bob1');
      final alice = await signedInAs('alice');

      final profile = await endpoints.profile.updateUsername(alice, 'bob_');

      expect(profile.username, 'bob_');
    });

    test('when keeping or re-casing own username then it succeeds', () async {
      final alice = await signedInAs('alice');

      expect(
        (await endpoints.profile.updateUsername(alice, 'alice')).username,
        'alice',
      );
      expect(
        (await endpoints.profile.updateUsername(alice, 'Alice')).username,
        'Alice',
      );
    });

    test('when unauthenticated then updating is refused', () async {
      await expectLater(
        endpoints.profile.updateUsername(sessionBuilder, 'alice'),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });

  test(
    'Given two UUID v7 created back to back, '
    'when deriving default usernames then they differ',
    () {
      final first = const Uuid().v7obj();
      final second = const Uuid().v7obj();

      expect(defaultUsernameFor(first), isNot(defaultUsernameFor(second)));
    },
  );
}
