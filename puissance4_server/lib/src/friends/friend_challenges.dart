import 'package:serverpod/serverpod.dart';

import '../game/server_game.dart';
import '../generated/protocol.dart';
import 'friend_code.dart';

/// L'ami [userId] que [me] veut défier (E15) : il faut être amis, et qu'il
/// ne soit pas déjà en partie. Lève `GameException(friendUnavailable)`
/// sinon — l'erreur arrive sur le stream de `hostRoom`, comme ses autres
/// refus.
Future<User> requireChallengeable(
  Session session,
  User me,
  UuidValue userId,
) async {
  final friendship = await Friendship.db.findFirstRow(
    session,
    where: (t) =>
        t.pairKey.equals(friendPairKey(me.id!, userId)) &
        t.status.equals(EnumFriendshipStatus.accepted),
  );
  final friend = friendship == null
      ? null
      : await User.db.findById(session, userId);
  if (friend?.authUserId == null ||
      await ServerGame.findActivePartie(session, userId) != null) {
    throw GameException(reason: EnumGameError.friendUnavailable);
  }
  return friend!;
}
