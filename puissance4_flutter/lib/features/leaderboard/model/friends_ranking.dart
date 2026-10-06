import 'package:puissance4_client/puissance4_client.dart';

/// Classement entre amis (E15) : [me] et mes [friends] triés par Elo puis
/// pseudo, numérotés de 1 à N. Le rang de [me] est celui dans ce petit
/// classement, pas le rang global.
({List<LeaderboardEntryDto> entries, LeaderboardEntryDto me}) rankWithFriends(
  LeaderboardEntryDto me,
  Iterable<FriendUserDto> friends,
) {
  final players =
      [
        me,
        for (final friend in friends)
          if (friend.userId != me.id)
            LeaderboardEntryDto(
              id: friend.userId,
              rank: 0,
              username: friend.username,
              thumbnailUrl: friend.thumbnailUrl,
              elo: friend.elo,
            ),
      ]..sort((a, b) {
        final byElo = b.elo.compareTo(a.elo);
        return byElo != 0 ? byElo : a.username.compareTo(b.username);
      });
  final entries = [
    for (final (index, player) in players.indexed)
      player.copyWith(rank: index + 1),
  ];
  return (entries: entries, me: entries.firstWhere((e) => e.id == me.id));
}
