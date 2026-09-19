import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../generated/protocol.dart';

/// Wired as `AuthUsersConfig.onAfterAuthUserCreated` in `server.dart`.
///
/// Creates the game-profile [User] row for a newly created [AuthUser],
/// linked via [User.authUserId]. Runs for every identity provider (email,
/// Google, anonymous) since it hooks the shared `AuthUser` creation, not a
/// provider-specific endpoint (cf. US1.2 — no hand-rolled endpoint).
Future<void> createUserForAuthUser(
  Session session,
  AuthUserModel authUser, {
  required Transaction transaction,
}) async {
  await User.db.insertRow(
    session,
    User(
      authUserId: authUser.id,
      username: 'Joueur-${authUser.id.toString().substring(0, 8)}',
    ),
    transaction: transaction,
  );
}
