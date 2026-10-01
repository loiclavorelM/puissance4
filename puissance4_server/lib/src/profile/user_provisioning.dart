import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../generated/protocol.dart';
import '../live/live_notifier.dart';

/// Wired as `AuthUsersConfig.onAfterAuthUserCreated` in `server.dart`.
///
/// Creates the game-profile [User] row for a newly created [AuthUser],
/// linked via [User.authUserId]. Runs for every identity provider (email,
/// anonymous) since it hooks the shared `AuthUser` creation, not a
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
      username: defaultUsernameFor(authUser.id),
    ),
    transaction: transaction,
  );
  // Le nouveau joueur apparaît dans le Classement : pas de diffusion (chaque
  // connexion anonyme ferait recharger tous les clients), juste le cache.
  await session.caches.local.invalidateGroup(leaderboardCacheGroup);
}

/// Pseudo attribué à la création d'un [User] — `username` est unique en base.
///
/// Prend la **fin** de l'UUID : [authUserId] est un UUID v7 dont les premiers
/// caractères encodent l'horodatage, donc deux comptes créés à moins d'une
/// minute d'intervalle partageraient le même préfixe.
String defaultUsernameFor(UuidValue authUserId) {
  final hex = authUserId.uuid.replaceAll('-', '');
  return 'Joueur-${hex.substring(hex.length - 8)}';
}
