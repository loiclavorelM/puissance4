import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_flutter/features/leaderboard/model/friends_ranking.dart';

void main() {
  UuidValue id(int n) =>
      UuidValue.fromString('00000000-0000-4000-8000-00000000000$n');
  FriendUserDto friend(int n, String username, int elo) =>
      FriendUserDto(userId: id(n), username: username, elo: elo);

  final me = LeaderboardEntryDto(
    id: id(0),
    rank: 42,
    username: 'me',
    elo: 1100,
  );

  test('ranks me among my friends by Elo, then username', () {
    final ranking = rankWithFriends(me, [
      friend(1, 'bob', 1000),
      friend(2, 'zed', 1200),
      friend(3, 'amy', 1200),
    ]);

    expect(ranking.entries.map((e) => (e.rank, e.username)), [
      (1, 'amy'),
      (2, 'zed'),
      (3, 'me'),
      (4, 'bob'),
    ]);
    expect(ranking.me.rank, 3);
  });

  test('alone, I am first', () {
    final ranking = rankWithFriends(me, []);

    expect(ranking.entries.single.rank, 1);
    expect(ranking.me.username, 'me');
  });
}
