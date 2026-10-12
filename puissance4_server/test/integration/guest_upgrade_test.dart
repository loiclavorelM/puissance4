import 'package:puissance4_server/src/auth/guest_upgrade.dart';
import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:puissance4_server/src/profile/user_provisioning.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/anonymous.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  const verificationCode = 'code-1234';
  const password = 'Motdepasse-123';

  withServerpod(
    'Given a guest creating an email account (US0.2)',
    // Le rate limiter du module d'auth ouvre ses propres transactions en
    // parallèle, ce que le rollback automatique ne supporte pas.
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      setUp(() {
        // Même câblage que `server.dart`, avec un code de vérification connu.
        AuthServices.set(
          tokenManagerBuilders: [
            ServerSideSessionsConfig(sessionKeyHashPepper: 'test-pepper'),
          ],
          identityProviderBuilders: [
            EmailIdpConfig(
              secretHashPepper: 'test-pepper',
              registrationVerificationCodeGenerator: () => verificationCode,
            ),
            const AnonymousIdpConfig(),
          ],
          authUsersConfig: const AuthUsersConfig(
            onAfterAuthUserCreated: createUserForAuthUser,
          ),
          accountMergeConfig: const AccountMergeConfig(
            applicationMergeHandler: mergeGameUsers,
          ),
        );
      });

      tearDown(() async {
        final session = sessionBuilder.build();
        await Player.db.deleteWhere(
          session,
          where: (t) => t.id.notEquals(null),
        );
        // Supprime en cascade User, comptes anonymes/email et profils.
        await AuthUser.db.deleteWhere(
          session,
          where: (t) => t.id.notEquals(null),
        );
        await EmailAccountRequest.db.deleteWhere(
          session,
          where: (t) => t.id.notEquals(null),
        );
      });

      TestSessionBuilder signedInAs(UuidValue authUserId) =>
          sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              authUserId.uuid,
              {},
            ),
          );

      /// Déroule le formulaire d'inscription du module pour [email].
      Future<AuthSuccess> register(
        TestSessionBuilder caller,
        String email,
      ) async {
        final requestId = await endpoints.emailIdp.startRegistration(
          caller,
          email: email,
        );
        final token = await endpoints.emailIdp.verifyRegistrationCode(
          caller,
          accountRequestId: requestId,
          verificationCode: verificationCode,
        );
        return endpoints.emailIdp.finishRegistration(
          caller,
          registrationToken: token,
          password: password,
        );
      }

      test('when signed in anonymously then the profile is a guest', () async {
        final guest = await endpoints.anonymousIdp.login(sessionBuilder);

        final profile = await endpoints.profile.getMyProfile(
          signedInAs(guest.authUserId),
        );

        expect(profile.isGuest, isTrue);
      });

      test(
        'when the guest registers then the account keeps the same auth user and progress',
        () async {
          final session = sessionBuilder.build();
          final guest = await endpoints.anonymousIdp.login(sessionBuilder);
          final guestSession = signedInAs(guest.authUserId);
          final guestUser = (await User.db.findFirstRow(
            session,
            where: (t) => t.authUserId.equals(guest.authUserId),
          ))!;
          await User.db.updateRow(session, guestUser.copyWith(elo: 1087));

          final success = await register(guestSession, 'guest@example.com');

          expect(success.authUserId, guest.authUserId);
          final users = await User.db.find(session);
          expect(users, hasLength(1));
          expect(users.single.id, guestUser.id);
          expect(users.single.elo, 1087);
          expect(
            await AnonymousAccount.db.count(
              session,
              where: (t) => t.authUserId.equals(guest.authUserId),
            ),
            0,
          );
          final profile = await endpoints.profile.getMyProfile(guestSession);
          expect(profile.isGuest, isFalse);
          expect(profile.elo, 1087);

          // L'invité se reconnecte désormais par email, sur le même compte.
          final login = await endpoints.emailIdp.login(
            sessionBuilder,
            email: 'guest@example.com',
            password: password,
          );
          expect(login.authUserId, guest.authUserId);
        },
      );

      test(
        'when nobody is signed in then registering creates a new account',
        () async {
          final success = await register(sessionBuilder, 'new@example.com');

          final profile = await endpoints.profile.getMyProfile(
            signedInAs(success.authUserId),
          );
          expect(profile.isGuest, isFalse);
          expect(await User.db.count(sessionBuilder.build()), 1);
        },
      );

      test(
        'when merging into a player whose removed user has games then it is refused',
        () async {
          final session = sessionBuilder.build();
          // Crée aussi leur User via `onAfterAuthUserCreated`.
          final authUsers = AuthServices.instance.authUsers;
          final keep = await authUsers.create(session);
          final remove = await authUsers.create(session);
          final removedUser = (await User.db.findFirstRow(
            session,
            where: (t) => t.authUserId.equals(remove.id),
          ))!;
          await Player.db.insertRow(session, Player(userId: removedUser.id));

          await expectLater(
            AuthServices.instance.accountMerger.merge(
              session,
              userToKeepId: keep.id,
              userToRemoveId: remove.id,
            ),
            throwsStateError,
          );
        },
      );
    },
  );
}
