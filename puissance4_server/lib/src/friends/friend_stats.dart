import 'package:serverpod/serverpod.dart';

import '../game/enum_color_extensions.dart';
import '../generated/protocol.dart';

/// Une partie serveur terminée vue d'un de ses joueurs humains.
typedef PlayedGame = ({
  Partie partie,
  UuidValue userId,
  EnumColor color,
  UuidValue opponentPlayerId,
});

/// Parties serveur terminées ([types]) des joueurs [userIds] (`User.id`),
/// plus récentes d'abord — une entrée par joueur concerné.
Future<List<PlayedGame>> finishedGamesOf(
  Session session,
  Set<UuidValue> userIds, {
  required Set<EnumType> types,
  DateTime? since,
  int? limit,
}) async {
  if (userIds.isEmpty) return [];
  final players = await Player.db.find(
    session,
    where: (t) => t.userId.inSet(userIds),
  );
  if (players.isEmpty) return [];
  final userByPlayer = {for (final p in players) p.id!: p.userId!};
  final playerIds = userByPlayer.keys.toSet();
  final parties = await Partie.db.find(
    session,
    where: (t) {
      final mine =
          (t.playerRougeId.inSet(playerIds) |
              t.playerJauneId.inSet(playerIds)) &
          t.status.equals(EnumStatut.finished) &
          t.typePartie.inSet(types);
      return since == null ? mine : mine & (t.createdAt > since);
    },
    orderBy: (t) => t.createdAt.desc(),
    limit: limit,
  );
  return [
    for (final partie in parties)
      for (final color in EnumColor.values)
        if (userByPlayer[color == EnumColor.rouge
                ? partie.playerRougeId
                : partie.playerJauneId]
            case final userId?)
          (
            partie: partie,
            userId: userId,
            color: color,
            opponentPlayerId: color == EnumColor.rouge
                ? partie.playerJauneId
                : partie.playerRougeId,
          ),
  ];
}

/// Résultat de [game] pour celui qui l'a joué.
EnumMatchResult resultOf(PlayedGame game) => switch (game.partie.winner) {
  null || EnumOutcome.draw => EnumMatchResult.draw,
  final winner when winner == game.color.asOutcome => EnumMatchResult.win,
  _ => EnumMatchResult.loss,
};

/// Série en cours d'après [results] (plus récent d'abord) : nombre de
/// victoires (> 0) ou de défaites (< 0) d'affilée.
int currentStreak(List<EnumMatchResult> results) {
  if (results.isEmpty || results.first == EnumMatchResult.draw) return 0;
  final first = results.first;
  final length = results.takeWhile((r) => r == first).length;
  return first == EnumMatchResult.win ? length : -length;
}
