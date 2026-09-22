import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../game/enum_color_extensions.dart';
import '../generated/protocol.dart';

/// Historique des parties de l'appelant (E9) — ne couvre que Multi/Classé
/// (`Partie`). Normal (`OfflineMatchResult`) est une table `database: sync`
/// sans FK vers `User` : elle est lue côté client depuis la session de
/// synchro locale déjà ouverte, pas via cet endpoint. Voir le plan Historique
/// pour le détail de cette séparation volontaire.
class HistoryEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<HistoryDto>> getListHistories(
    Session session, {
    EnumType? typePartie,
    int limit = 200,
    int offset = 0,
  }) async {
    if (typePartie == EnumType.normal) return [];

    final authUserId = session.authenticated!.authUserId;
    final user = await User.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (user == null) return [];

    final myPlayers = await Player.db.find(
      session,
      where: (t) => t.userId.equals(user.id),
    );
    final myPlayerIds = myPlayers.map((p) => p.id!).toSet();
    if (myPlayerIds.isEmpty) return [];

    final parties = await Partie.db.find(
      session,
      where: (t) {
        final mine =
            t.playerRougeId.inSet(myPlayerIds) |
            t.playerJauneId.inSet(myPlayerIds);
        final finished = t.status.equals(EnumStatut.finished);
        return typePartie == null
            ? mine & finished
            : mine & finished & t.typePartie.equals(typePartie);
      },
      orderBy: (t) => t.createdAt.desc(),
      limit: limit,
      offset: offset,
    );

    return _toDtos(session, user, myPlayerIds, parties);
  }

  Future<HistoryDto> getHistory(
    Session session, {
    required UuidValue idPartie,
  }) async {
    final authUserId = session.authenticated!.authUserId;
    final user = await User.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (user == null) {
      throw StateError('No User row for authenticated AuthUser $authUserId');
    }

    final myPlayers = await Player.db.find(
      session,
      where: (t) => t.userId.equals(user.id),
    );
    final myPlayerIds = myPlayers.map((p) => p.id!).toSet();

    final partie = await Partie.db.findFirstRow(
      session,
      where: (t) =>
          t.id.equals(idPartie) &
          (t.playerRougeId.inSet(myPlayerIds) |
              t.playerJauneId.inSet(myPlayerIds)),
    );
    if (partie == null) {
      throw StateError('Partie $idPartie introuvable pour cet utilisateur.');
    }

    final dtos = await _toDtos(session, user, myPlayerIds, [partie]);
    return dtos.single;
  }

  /// Résout les adversaires (Bot ou User) et les variations d'Elo par lot
  /// (pas de requête par ligne) puis construit un [HistoryDto] par [Partie].
  Future<List<HistoryDto>> _toDtos(
    Session session,
    User user,
    Set<UuidValue> myPlayerIds,
    List<Partie> parties,
  ) async {
    if (parties.isEmpty) return [];

    final opponentPlayerIds = parties
        .map(
          (p) => myPlayerIds.contains(p.playerRougeId)
              ? p.playerJauneId
              : p.playerRougeId,
        )
        .toSet();
    final opponentPlayers = await Player.db.find(
      session,
      where: (t) => t.id.inSet(opponentPlayerIds),
    );
    final opponentPlayerById = {for (final p in opponentPlayers) p.id!: p};

    final botIds = opponentPlayers
        .where((p) => p.botId != null)
        .map((p) => p.botId!)
        .toSet();
    final userIds = opponentPlayers
        .where((p) => p.userId != null)
        .map((p) => p.userId!)
        .toSet();
    final bots = botIds.isEmpty
        ? <Bot>[]
        : await Bot.db.find(session, where: (t) => t.id.inSet(botIds));
    final users = userIds.isEmpty
        ? <User>[]
        : await User.db.find(session, where: (t) => t.id.inSet(userIds));
    final botNameById = {for (final b in bots) b.id!: b.botName};
    final usernameById = {for (final u in users) u.id!: u.username};

    final partieIds = parties.map((p) => p.id!).toSet();
    final eloRows = await EloHistory.db.find(
      session,
      where: (t) => t.userId.equals(user.id) & t.partieId.inSet(partieIds),
    );
    final eloVariationByPartieId = {
      for (final e in eloRows) e.partieId: e.eloVariation,
    };

    return parties.map((partie) {
      final playedAs = myPlayerIds.contains(partie.playerRougeId)
          ? EnumColor.rouge
          : EnumColor.jaune;
      final opponentId = playedAs == EnumColor.rouge
          ? partie.playerJauneId
          : partie.playerRougeId;
      final opponent = opponentPlayerById[opponentId];
      final adversaire =
          (opponent?.botId != null ? botNameById[opponent!.botId] : null) ??
          (opponent?.userId != null ? usernameById[opponent!.userId] : null) ??
          'Adversaire';

      // `winner` ne devrait jamais être null ici (partie déjà filtrée sur
      // `status == finished`), mais reste nullable dans le schéma — traité
      // comme un match nul par sécurité, au même titre que EnumOutcome.draw.
      final resultat = switch (partie.winner) {
        null || EnumOutcome.draw => EnumMatchResult.draw,
        final winner when winner == playedAs.asOutcome => EnumMatchResult.win,
        _ => EnumMatchResult.loss,
      };

      return HistoryDto(
        id: partie.id!,
        date: partie.createdAt,
        typePartie: partie.typePartie,
        adversaire: adversaire,
        resultat: resultat,
        playedAs: playedAs,
        eloVariation: eloVariationByPartieId[partie.id!],
      );
    }).toList();
  }
}
