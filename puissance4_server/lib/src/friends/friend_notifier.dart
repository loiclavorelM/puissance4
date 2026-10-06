import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../live/live_notifier.dart';
import 'friends_config.dart';

/// Prévient les amis de [userIds] (`User.id`) que leur onglet Amis a changé
/// — présence, partie commencée ou finie.
Future<void> notifyFriendsOf(
  Session session,
  Iterable<UuidValue> userIds,
) async {
  final ids = userIds.toSet();
  if (ids.isEmpty) return;
  final rows = await Friendship.db.find(
    session,
    where: (t) =>
        (t.requesterId.inSet(ids) | t.addresseeId.inSet(ids)) &
        t.status.equals(EnumFriendshipStatus.accepted),
  );
  final friendIds = <UuidValue>{
    for (final row in rows) ...[row.requesterId, row.addresseeId],
  }..removeAll(ids);
  if (friendIds.isEmpty) return;
  final friends = await User.db.find(
    session,
    where: (t) => t.id.inSet(friendIds),
  );
  for (final friend in friends) {
    if (friend.authUserId != null) {
      await notifyUser(session, friend.authUserId!, friends: true);
    }
  }
}

/// Le stream temps réel de [authUserId] s'ouvre : s'il passe en ligne, ses
/// amis le voient.
Future<void> markOnline(Session session, UuidValue authUserId) async {
  if (!await FriendsConfig.presence.connect(authUserId)) return;
  final user = await _userOf(session, authUserId);
  if (user != null) await notifyFriendsOf(session, [user.id!]);
}

/// Le stream temps réel de [authUserId] se ferme : s'il passe hors ligne,
/// on retient l'heure (« vu il y a… ») et ses amis le voient.
Future<void> markOffline(Session session, UuidValue authUserId) async {
  if (!await FriendsConfig.presence.disconnect(authUserId)) return;
  final user = await _userOf(session, authUserId);
  if (user == null) return;
  await User.db.updateRow(
    session,
    user.copyWith(lastSeenAt: DateTime.now().toUtc()),
    columns: (t) => [t.lastSeenAt],
  );
  await notifyFriendsOf(session, [user.id!]);
}

Future<User?> _userOf(Session session, UuidValue authUserId) => User.db
    .findFirstRow(session, where: (t) => t.authUserId.equals(authUserId));
