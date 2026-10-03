import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../generated/protocol.dart';
import '../live/live_notifier.dart';
import '../profile/profile_photo.dart';

/// Classement par Elo (E8) — uniquement des `User`, jamais de `Bot` (son
/// `elo` ne sert qu'au matchmaking de difficulté, cf. plan Classement).
class LeaderboardEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<LeaderboardEntryDto>> getLeaderboard(
    Session session, {
    int limit = 100,
    int offset = 0,
  }) async {
    // Même page demandée par tous les clients à chaque événement
    // `leaderboardChanged` : mise en cache locale, vidée par
    // `notifyLeaderboardChanged` à chaque changement d'Elo/pseudo. La durée
    // de vie ne sert que de filet (ex. un nouveau compte, qui n'invalide
    // pas).
    final page = await session.caches.local.get<List<LeaderboardEntryDto>>(
      'leaderboard-$limit-$offset',
      CacheMissHandler(
        () => _loadPage(session, limit: limit, offset: offset),
        lifetime: const Duration(minutes: 1),
        group: leaderboardCacheGroup,
      ),
    );
    return page ?? [];
  }

  Future<List<LeaderboardEntryDto>> _loadPage(
    Session session, {
    required int limit,
    required int offset,
  }) async {
    final users = await User.db.find(
      session,
      orderBy: (t) => t.elo.desc(),
      limit: limit,
      offset: offset,
    );

    final photoUrls = await ProfilePhoto.urls(
      session,
      users.map((u) => u.thumbnailPath),
    );
    return users
        .asMap()
        .entries
        .map(
          (entry) => LeaderboardEntryDto(
            id: entry.value.id!,
            rank: offset + entry.key + 1,
            username: entry.value.username,
            thumbnailUrl: photoUrls[entry.value.thumbnailPath],
            elo: entry.value.elo,
          ),
        )
        .toList();
  }

  /// Rang calculé séparément de [getLeaderboard] (pas de vrai départage
  /// d'ex-aequo, comme la pagination) — permet à l'écran d'afficher la ligne
  /// du joueur courant même quand elle est hors de la page top-N chargée.
  Future<LeaderboardEntryDto> getMyRank(Session session) async {
    final authUserId = session.authenticated!.authUserId;
    final user = await User.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (user == null) {
      throw StateError('No User row for authenticated AuthUser $authUserId');
    }

    final higherRanked = await User.db.count(
      session,
      where: (t) => t.elo > user.elo,
    );

    return LeaderboardEntryDto(
      id: user.id!,
      rank: higherRanked + 1,
      username: user.username,
      thumbnailUrl: await ProfilePhoto.url(session, user.thumbnailPath),
      elo: user.elo,
    );
  }
}
