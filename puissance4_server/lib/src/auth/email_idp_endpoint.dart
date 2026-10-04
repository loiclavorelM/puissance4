import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'guest_upgrade.dart';

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
class EmailIdpEndpoint extends EmailIdpBaseEndpoint {
  /// Completes a new account registration, like the module's — except for a
  /// guest signed in anonymously: the email account is then attached to the
  /// guest's own auth user, so the player keeps their Elo, games and history
  /// (US0.2, server side in `guest_upgrade.dart`).
  ///
  /// Throws an [EmailAccountRequestException] in case of errors (expired,
  /// policyViolation, invalid), as the module does.
  @override
  Future<AuthSuccess> finishRegistration(
    Session session, {
    required String registrationToken,
    required String password,
  }) async {
    final callerId = session.authenticated?.authUserId;
    if (callerId == null || !await isAnonymousAuthUser(session, callerId)) {
      return super.finishRegistration(
        session,
        registrationToken: registrationToken,
        password: password,
      );
    }
    return upgradeGuestToEmail(
      session,
      guestId: callerId,
      registrationToken: registrationToken,
      password: password,
    );
  }
}
