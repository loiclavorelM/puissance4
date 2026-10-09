import 'package:serverpod/serverpod.dart';
import 'package:serverpod_offline_sync_server/serverpod_offline_sync_server.dart'
    show OfflineSyncSpace;

import '../../game/enum_color_extensions.dart';
import '../../generated/protocol.dart';
import 'game_record.dart';

/// Filtre commun des sources de données.
final class GameFilter {
  const GameFilter({
    this.mode,
    this.opponentRef,
    this.since,
    this.until,
    this.lastGames,
  });

  final EnumType? mode;
  final String? opponentRef;

  /// Bornes de `playedAt` : `[since, until)`.
  final DateTime? since;
  final DateTime? until;

  /// Seulement les N plus récentes, après les autres filtres.
  final int? lastGames;
}

/// Les parties terminées d'un joueur, tous modes réunis — seule lecture des
/// parties pour l'assistant, isolée ici parce que `serverpod_offline_sync`
/// est encore en 0.0.x.
///
/// - Multi et Classé : `Partie` `finished` dont un des `Player` est le joueur.
/// - Normal : `OfflineMatchResult` `finished` de son espace de synchro
///   personnel, dont l'`uuidSpaceId` est son `authUserId` (vérifié au lot 0).
///   Une partie jouée hors ligne n'apparaît qu'après sa synchronisation.
///
/// Les parties `abandoned` sont exclues, comme dans l'Historique.
abstract final class GameRecordRepository {
  static Future<List<GameRecord>> load(
    Session session,
    User user, [
    GameFilter filter = const GameFilter(),
  ]) async {
    final records =
        [
              if (filter.mode != EnumType.normal)
                ...await _serverGames(session, user, filter),
              if (filter.mode == null || filter.mode == EnumType.normal)
                ...await _offlineGames(session, user, filter),
            ]
            .where(
              (r) =>
                  filter.opponentRef == null ||
                  r.opponentRef == filter.opponentRef,
            )
            .toList()
          ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return filter.lastGames == null
        ? records
        : records.take(filter.lastGames!).toList();
  }

  static Future<List<GameRecord>> _serverGames(
    Session session,
    User user,
    GameFilter filter,
  ) async {
    final myPlayerIds = {
      for (final player in await Player.db.find(
        session,
        where: (t) => t.userId.equals(user.id),
      ))
        player.id!,
    };
    if (myPlayerIds.isEmpty) return const [];

    final parties = await Partie.db.find(
      session,
      where: (t) {
        var where =
            (t.playerRougeId.inSet(myPlayerIds) |
                t.playerJauneId.inSet(myPlayerIds)) &
            t.status.equals(EnumStatut.finished);
        if (filter.mode case final mode?) {
          where = where & t.typePartie.equals(mode);
        }
        if (filter.since case final since?) {
          where = where & (t.createdAt >= since);
        }
        if (filter.until case final until?) {
          where = where & (t.createdAt < until);
        }
        return where;
      },
      orderBy: (t) => t.createdAt.desc(),
    );
    if (parties.isEmpty) return const [];

    final opponentIds = {
      for (final partie in parties)
        myPlayerIds.contains(partie.playerRougeId)
            ? partie.playerJauneId
            : partie.playerRougeId,
    };
    final opponents = {
      for (final player in await Player.db.find(
        session,
        where: (t) => t.id.inSet(opponentIds),
      ))
        player.id!: player,
    };
    final botIds = {for (final p in opponents.values) ?p.botId};
    final userIds = {for (final p in opponents.values) ?p.userId};
    final botNames = {
      if (botIds.isNotEmpty)
        for (final bot in await Bot.db.find(
          session,
          where: (t) => t.id.inSet(botIds),
        ))
          bot.id!: bot.botName,
    };
    final usernames = {
      if (userIds.isNotEmpty)
        for (final other in await User.db.find(
          session,
          where: (t) => t.id.inSet(userIds),
        ))
          other.id!: other.username,
    };
    final eloDeltas = {
      for (final elo in await EloHistory.db.find(
        session,
        where: (t) =>
            t.userId.equals(user.id) &
            t.partieId.inSet({for (final p in parties) p.id!}),
      ))
        elo.partieId: elo.eloVariation,
    };

    return [
      for (final partie in parties)
        ?_serverRecord(
          partie,
          myPlayerIds,
          opponents,
          botNames,
          usernames,
          eloDeltas,
        ),
    ];
  }

  static GameRecord? _serverRecord(
    Partie partie,
    Set<UuidValue> myPlayerIds,
    Map<UuidValue, Player> opponents,
    Map<UuidValue, String> botNames,
    Map<UuidValue, String> usernames,
    Map<UuidValue, int> eloDeltas,
  ) {
    final playedAs = myPlayerIds.contains(partie.playerRougeId)
        ? EnumColor.rouge
        : EnumColor.jaune;
    final opponent =
        opponents[playedAs == EnumColor.rouge
            ? partie.playerJauneId
            : partie.playerRougeId];
    if (opponent == null) return null;
    final isBot = opponent.botId != null;
    return GameRecord(
      id: partie.id!,
      mode: partie.typePartie,
      playedAt: partie.createdAt,
      result: switch (partie.winner) {
        null || EnumOutcome.draw => EnumMatchResult.draw,
        final winner when winner == playedAs.asOutcome => EnumMatchResult.win,
        _ => EnumMatchResult.loss,
      },
      playedAs: playedAs,
      moves: partie.moves,
      opponentKind: isBot ? OpponentKind.bot : OpponentKind.human,
      opponentRef: isBot ? 'bot:${opponent.botId}' : 'user:${opponent.userId}',
      opponentName: isBot
          ? botNames[opponent.botId] ?? '?'
          : usernames[opponent.userId] ?? '?',
      eloDelta: eloDeltas[partie.id],
    );
  }

  static Future<List<GameRecord>> _offlineGames(
    Session session,
    User user,
    GameFilter filter,
  ) async {
    final authUserId = user.authUserId;
    if (authUserId == null) return const [];
    final space = await OfflineSyncSpace.db.findFirstRow(
      session,
      where: (t) => t.uuidSpaceId.equals(authUserId),
    );
    if (space == null) return const [];

    final rows = await OfflineMatchResult.db.find(
      session,
      where: (t) {
        var where =
            t.spaceId.equals(space.id) & t.status.equals(EnumStatut.finished);
        if (filter.since case final since?) {
          where = where & (t.playedAt >= since);
        }
        if (filter.until case final until?) {
          where = where & (t.playedAt < until);
        }
        return where;
      },
    );
    return [
      for (final row in rows)
        if (row.result case final result?)
          GameRecord(
            id: row.id!,
            mode: EnumType.normal,
            playedAt: row.playedAt,
            result: result,
            playedAs: row.playedAs,
            moves: row.moves,
            opponentKind: OpponentKind.bot,
            opponentRef: 'bot:${row.botId}',
            opponentName: row.botName,
          ),
    ];
  }
}
