import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import '../generated/protocol.dart';
import '../live/live_notifier.dart';

/// Whether [authUserId] signs in with the anonymous provider — a guest (E0)
/// who can still upgrade to an email account without losing progress.
Future<bool> isAnonymousAuthUser(
  Session session,
  UuidValue authUserId, {
  Transaction? transaction,
}) async =>
    await AnonymousAccount.db.count(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: transaction,
    ) >
    0;

/// Turns the anonymous guest [guestId] into an email account (US0.2).
///
/// The module's `finishRegistration` always creates a **new** `AuthUser`,
/// and refuses to sign anybody in while the caller is already authenticated.
/// Here the email account is created as usual, then merged **into the
/// guest**: the guest's `authUserId` is the one kept, so its `User`, Elo,
/// games and `serverpod_offline_sync` space (bound to that exact id, see
/// `offline_match_result.spy.yaml`) stay attached without any migration.
/// The guest stops being anonymous: its `AnonymousAccount` is removed.
Future<AuthSuccess> upgradeGuestToEmail(
  Session session, {
  required UuidValue guestId,
  required String registrationToken,
  required String password,
}) async {
  final auth = AuthServices.instance;
  final emailIdp = auth.emailIdp;
  final success = await session.db.transaction(
    (transaction) => EmailIdpUtils.withReplacedServerEmailException(() async {
      final created = await emailIdp.utils.accountCreation
          .completeAccountCreation(
            session,
            completeAccountCreationToken: registrationToken,
            password: password,
            transaction: transaction,
          );
      // Même profil que le `finishRegistration` du module : la fusion
      // ci-dessous en reporte l'email sur le profil de l'invité.
      await auth.userProfiles.createUserProfile(
        session,
        created.authUserId,
        UserProfileData(email: created.email),
        transaction: transaction,
      );
      await auth.accountMerger.merge(
        session,
        userToKeepId: guestId,
        userToRemoveId: created.authUserId,
        transaction: transaction,
      );
      await AnonymousAccount.db.deleteWhere(
        session,
        where: (t) => t.authUserId.equals(guestId),
        transaction: transaction,
      );

      final guest = await auth.authUsers.get(
        session,
        authUserId: guestId,
        transaction: transaction,
      );
      return auth.tokenManager.issueToken(
        session,
        authUserId: guestId,
        method: emailIdp.method,
        scopes: guest.scopes,
        transaction: transaction,
      );
    }),
  );
  // Après le commit : les autres appareils de l'invité rechargent son profil
  // (`isGuest` vient de passer à false).
  await notifyUser(session, guestId, profile: true);
  return success;
}

/// `AccountMergeConfig.applicationMergeHandler`, run by [AccountMerger.merge]
/// before the merged-away `AuthUser` is deleted.
///
/// The only merge the app performs is [upgradeGuestToEmail], whose removed
/// user was created in the same transaction: its `User` row (made by
/// `createUserForAuthUser`) holds nothing yet and simply goes away. Merging
/// two players who both have games (T0.2.3) is not supported, so it is
/// refused rather than silently dropping one side's history.
Future<void> mergeGameUsers(
  Session session, {
  required UuidValue userToKeepId,
  required UuidValue userToRemoveId,
  required Transaction transaction,
}) async {
  final removed = await User.db.findFirstRow(
    session,
    where: (t) => t.authUserId.equals(userToRemoveId),
    transaction: transaction,
  );
  if (removed == null) return;

  final history = await Player.db.count(
    session,
    where: (t) => t.userId.equals(removed.id),
    transaction: transaction,
  );
  final elo = await EloHistory.db.count(
    session,
    where: (t) => t.userId.equals(removed.id),
    transaction: transaction,
  );
  if (history > 0 || elo > 0) {
    throw StateError(
      'Fusion refusée : le User ${removed.id} a déjà un historique de jeu.',
    );
  }
  await User.db.deleteRow(session, removed, transaction: transaction);
}
