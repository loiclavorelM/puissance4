import 'package:puissance4_client/puissance4_client.dart';

import '../../../client.dart';

class LeaderboardRepository {
  Future<List<LeaderboardEntryDto>> fetchTop({int limit = 100}) =>
      client.leaderboard.getLeaderboard(limit: limit, offset: 0);

  Future<LeaderboardEntryDto> fetchMyRank() => client.leaderboard.getMyRank();
}
