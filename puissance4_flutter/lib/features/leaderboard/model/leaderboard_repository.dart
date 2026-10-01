import 'package:puissance4_client/puissance4_client.dart';

import '../../../client.dart';
import '../../offline/model/local_cache.dart';

typedef LeaderboardSnapshot = ({
  List<LeaderboardEntryDto> entries,
  LeaderboardEntryDto myRank,
});

class LeaderboardRepository {
  LeaderboardRepository(this._cache);

  final LocalCache _cache;

  Future<List<LeaderboardEntryDto>> fetchTop({int limit = 100}) =>
      client.leaderboard.getLeaderboard(limit: limit, offset: 0);

  Future<LeaderboardEntryDto> fetchMyRank() => client.leaderboard.getMyRank();

  /// Page top-N + rang du joueur, en cache d'abord puis depuis le serveur —
  /// mis en cache ensemble pour ne jamais afficher un top et un rang issus
  /// de deux instants différents.
  Stream<LeaderboardSnapshot> watchLeaderboard(UuidValue authUserId) =>
      _cache.cacheThenNetwork(
        authUserId: authUserId,
        name: 'leaderboard',
        fetch: () async {
          final (entries, myRank) = await (fetchTop(), fetchMyRank()).wait;
          return (entries: entries, myRank: myRank);
        },
        decode: (json) {
          final map = json as Map<String, dynamic>;
          return (
            entries: (map['entries'] as List)
                .map(
                  (e) =>
                      LeaderboardEntryDto.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
            myRank: LeaderboardEntryDto.fromJson(
              map['myRank'] as Map<String, dynamic>,
            ),
          );
        },
        encode: (snapshot) => {
          'entries': snapshot.entries.map((e) => e.toJson()).toList(),
          'myRank': snapshot.myRank.toJson(),
        },
      );
}
