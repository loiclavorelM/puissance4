import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../auth/guest_upgrade.dart';
import '../game/server_game.dart';
import '../generated/protocol.dart';
import '../live/live_notifier.dart';
import '../multiplayer/multiplayer_config.dart';
import '../multiplayer/multiplayer_endpoint.dart';
import '../profile/profile_photo.dart';
import 'friend_code.dart';
import 'friend_stats.dart';
import 'friends_config.dart';

/// Amis (E15) : demandes d'ami, liste d'amis, recherche de joueurs. Réservé
/// aux comptes email — un invité (compte anonyme) reçoit
/// `FriendsException(guestNotAllowed)` et n'apparaît jamais dans les
/// recherches. Chaque changement prévient les deux joueurs
/// (`LiveEvent.friendsChanged`).
class FriendsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static const maxFriends = 200;
  static const minSearchLength = 3;
  static const searchLimit = 20;
  static const recentOpponentsLimit = 10;
  static const activityLimit = 20;
  static const activityPeriod = Duration(days: 7);

  /// Tout l'onglet Amis : code ami (attribué au premier appel), amis — en
  /// ligne d'abord, puis en partie, puis par Elo —, demandes reçues et
  /// envoyées (plus récentes d'abord).
  Future<FriendsOverviewDto> getOverview(Session session) async {
    final me = await _requireMember(session);
    final rows = await Friendship.db.find(
      session,
      where: (t) => t.requesterId.equals(me.id) | t.addresseeId.equals(me.id),
      orderBy: (t) => t.createdAt.desc(),
    );
    final (dtos, others) = await _toDtos(session, me, rows);

    final accepted = [
      for (final f in dtos)
        if (f.status == EnumFriendshipStatus.accepted) f,
    ];
    final friends = await _withPresence(session, accepted, others)
      ..sort((a, b) {
        final byPresence = _presenceOrder(
          a.presence,
        ).compareTo(_presenceOrder(b.presence));
        return byPresence != 0
            ? byPresence
            : b.other.elo.compareTo(a.other.elo);
      });
    final pending = dtos.where((f) => f.status == EnumFriendshipStatus.pending);
    return FriendsOverviewDto(
      friendCode: await _ensureFriendCode(session, me),
      friends: friends,
      incoming: pending.where((f) => f.incoming).toList(),
      outgoing: pending.where((f) => !f.incoming).toList(),
    );
  }

  /// Joueurs dont le pseudo commence par [query] (à partir de
  /// [minSearchLength] caractères), précédés de celui dont c'est le code ami
  /// le cas échéant. Ni soi-même, ni les invités.
  Future<List<PlayerSearchResultDto>> searchPlayers(
    Session session,
    String query,
  ) async {
    final me = await _requireMember(session);
    final trimmed = query.trim();

    final candidates = <User>[];
    final code = FriendCode.parse(trimmed);
    if (code != null) {
      final byCode = await User.db.findFirstRow(
        session,
        where: (t) => t.friendCode.equals(code),
      );
      if (byCode != null) candidates.add(byCode);
    }
    if (trimmed.length >= minSearchLength) {
      // `_` et `%` sont des jokers ILIKE : les échapper.
      final escaped = trimmed
          .replaceAll(r'\', r'\\')
          .replaceAll('_', r'\_')
          .replaceAll('%', r'\%');
      candidates.addAll(
        await User.db.find(
          session,
          where: (t) => t.username.ilike('$escaped%') & t.id.notEquals(me.id),
          orderBy: (t) => t.username,
          // De la marge pour les invités retirés ci-dessous.
          limit: searchLimit * 2,
        ),
      );
    }

    return _searchResults(session, me, candidates, searchLimit);
  }

  /// Derniers adversaires humains du joueur en Multi (US15.5), du plus
  /// récent au plus ancien, avec leur relation — pour les ajouter en un tap.
  Future<List<PlayerSearchResultDto>> recentOpponents(Session session) async {
    final me = await _requireMember(session);
    final myPlayers = await Player.db.find(
      session,
      where: (t) => t.userId.equals(me.id),
    );
    if (myPlayers.isEmpty) return [];
    final myPlayerIds = {for (final p in myPlayers) p.id!};
    final parties = await Partie.db.find(
      session,
      where: (t) =>
          t.typePartie.equals(EnumType.multi) &
          t.status.equals(EnumStatut.finished) &
          (t.playerRougeId.inSet(myPlayerIds) |
              t.playerJauneId.inSet(myPlayerIds)),
      orderBy: (t) => t.createdAt.desc(),
      limit: recentOpponentsLimit * 3,
    );
    final opponentPlayerIds = [
      for (final partie in parties)
        myPlayerIds.contains(partie.playerRougeId)
            ? partie.playerJauneId
            : partie.playerRougeId,
    ];
    if (opponentPlayerIds.isEmpty) return [];
    final players = await Player.db.find(
      session,
      where: (t) => t.id.inSet(opponentPlayerIds.toSet()),
    );
    final userIdByPlayer = {for (final p in players) p.id!: p.userId};
    final users = await User.db.find(
      session,
      where: (t) => t.id.inSet(<UuidValue>{for (final p in players) ?p.userId}),
    );
    final userById = {for (final u in users) u.id!: u};
    final candidates = [
      for (final playerId in opponentPlayerIds)
        ?userById[userIdByPlayer[playerId]],
    ];
    return _searchResults(session, me, candidates, recentOpponentsLimit);
  }

  /// Bilan tête-à-tête avec chaque ami (US15.7) — parties Multi terminées
  /// entre les deux —, ceux avec qui on a le plus joué d'abord.
  Future<List<RivalryDto>> getRivalries(Session session) async {
    final me = await _requireMember(session);
    final friends = await _friendsOf(session, me);
    if (friends.isEmpty) return [];

    final games = await finishedGamesOf(
      session,
      {me.id!},
      types: {EnumType.multi},
    );
    final opponentOf = await _userIdsOfPlayers(session, {
      for (final game in games) game.opponentPlayerId,
    });
    final gamesByFriend = <UuidValue, List<PlayedGame>>{};
    for (final game in games) {
      final opponent = opponentOf[game.opponentPlayerId];
      if (opponent != null && friends.containsKey(opponent)) {
        (gamesByFriend[opponent] ??= []).add(game);
      }
    }

    final photoUrls = await ProfilePhoto.urls(
      session,
      friends.values.map((u) => u.thumbnailPath),
    );
    final rivalries = [
      for (final friend in friends.values)
        _rivalry(friend, gamesByFriend[friend.id] ?? const [], photoUrls),
    ];
    return rivalries..sort((a, b) {
      final byCount = b.partieIds.length.compareTo(a.partieIds.length);
      if (byCount != 0) return byCount;
      final byDate = (b.lastPlayedAt ?? DateTime(0)).compareTo(
        a.lastPlayedAt ?? DateTime(0),
      );
      return byDate != 0
          ? byDate
          : a.friend.username.compareTo(b.friend.username);
    });
  }

  /// Fil d'activité (US15.7) : parties Multi et Classé terminées par mes
  /// amis ces [activityPeriod] derniers jours, plus récentes d'abord.
  Future<List<FriendActivityDto>> getFriendsActivity(Session session) async {
    final me = await _requireMember(session);
    final friends = await _friendsOf(session, me);
    if (friends.isEmpty) return [];

    final seen = <UuidValue>{};
    final games = [
      for (final game in await finishedGamesOf(
        session,
        friends.keys.toSet(),
        types: {EnumType.multi, EnumType.classe},
        since: DateTime.now().toUtc().subtract(activityPeriod),
        limit: activityLimit * 2,
      ))
        // Deux amis qui jouent ensemble : une seule ligne.
        if (seen.add(game.partie.id!)) game,
    ].take(activityLimit).toList();
    if (games.isEmpty) return [];

    final opponentPlayers = await Player.db.find(
      session,
      where: (t) =>
          t.id.inSet(<UuidValue>{for (final g in games) g.opponentPlayerId}),
    );
    final opponentPlayerById = {for (final p in opponentPlayers) p.id!: p};
    final users = await User.db.find(
      session,
      where: (t) =>
          t.id.inSet(<UuidValue>{for (final p in opponentPlayers) ?p.userId}),
    );
    final bots = await Bot.db.find(
      session,
      where: (t) =>
          t.id.inSet(<UuidValue>{for (final p in opponentPlayers) ?p.botId}),
    );
    final nameOfUser = {for (final u in users) u.id!: u.username};
    final nameOfBot = {for (final b in bots) b.id!: b.botName};
    final elo = await EloHistory.db.find(
      session,
      where: (t) =>
          t.partieId.inSet(<UuidValue>{for (final g in games) g.partie.id!}) &
          t.userId.inSet(friends.keys.toSet()),
    );
    final eloOf = {for (final e in elo) (e.partieId, e.userId): e.eloVariation};
    final photoUrls = await ProfilePhoto.urls(
      session,
      friends.values.map((u) => u.thumbnailPath),
    );

    return [
      for (final game in games)
        FriendActivityDto(
          partieId: game.partie.id!,
          friend: _userDto(friends[game.userId]!, photoUrls),
          typePartie: game.partie.typePartie,
          result: resultOf(game),
          opponent: switch (opponentPlayerById[game.opponentPlayerId]) {
            Player(:final userId?) => nameOfUser[userId] ?? '',
            Player(:final botId?) => nameOfBot[botId] ?? '',
            _ => '',
          },
          eloVariation: eloOf[(game.partie.id!, game.userId)],
          at: game.partie.createdAt,
        ),
    ];
  }

  /// « Secouer pour s'ajouter » (US15.6) : le joueur courant vient de
  /// secouer son téléphone. Attend au plus `FriendsConfig.shakeWindow` une
  /// autre secousse et renvoie ce joueur avec sa relation, ou `null`.
  /// Rien n'est envoyé : chacun choisit ensuite d'ajouter l'autre
  /// (`sendRequest`, accepté d'office si l'autre l'a fait aussi).
  Future<PlayerSearchResultDto?> shakeToAdd(Session session) async {
    final me = await _requireMember(session);
    final otherAuthUserId = await FriendsConfig.shakes.match(
      me.authUserId!,
      FriendsConfig.shakeWindow,
    );
    if (otherAuthUserId == null) return null;
    final other = await User.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(otherAuthUserId),
    );
    if (other == null) return null;
    final results = await _searchResults(session, me, [other], 1);
    return results.isEmpty ? null : results.single;
  }

  /// Défis reçus encore ouverts (E15) : des salles privées réservées au
  /// joueur courant, à rejoindre par `MultiplayerEndpoint.joinRoom`.
  Future<List<FriendChallengeDto>> getChallenges(Session session) async {
    final me = await _requireMember(session);
    final rooms = await MultiplayerConfig.rooms.listInvitations(
      me.authUserId!,
    );
    if (rooms.isEmpty) return [];
    final hosts = await User.db.find(
      session,
      where: (t) =>
          t.id.inSet(<UuidValue>{for (final room in rooms) room.hostUserId}),
    );
    final hostById = {for (final host in hosts) host.id!: host};
    final photoUrls = await ProfilePhoto.urls(
      session,
      hosts.map((u) => u.thumbnailPath),
    );
    return [
      for (final room in rooms)
        if (hostById[room.hostUserId] case final host?)
          FriendChallengeDto(
            code: room.code,
            from: _userDto(host, photoUrls),
            expiresAt: room.expiresAt,
          ),
    ]..sort((a, b) => b.expiresAt.compareTo(a.expiresAt));
  }

  /// Refuse le défi [code] : la salle se ferme et son hôte reçoit
  /// `challengeDeclined`.
  Future<void> declineChallenge(Session session, String code) async {
    final me = await _requireMember(session);
    final room = await MultiplayerConfig.rooms.decline(code, me.authUserId!);
    if (room == null) {
      throw FriendsException(reason: EnumFriendsError.challengeNotFound);
    }
    await session.messages.postMessage(
      MultiplayerEndpoint.roomChannel(room.code),
      GameEvent(type: EnumGameEventType.challengeDeclined, code: room.code),
    );
  }

  /// Les amis de [me], par `User.id`.
  Future<Map<UuidValue, User>> _friendsOf(Session session, User me) async {
    final rows = await Friendship.db.find(
      session,
      where: (t) =>
          (t.requesterId.equals(me.id) | t.addresseeId.equals(me.id)) &
          t.status.equals(EnumFriendshipStatus.accepted),
    );
    if (rows.isEmpty) return {};
    final users = await User.db.find(
      session,
      where: (t) => t.id.inSet(<UuidValue>{
        for (final row in rows)
          row.requesterId == me.id ? row.addresseeId : row.requesterId,
      }),
    );
    return {for (final user in users) user.id!: user};
  }

  /// `User.id` des joueurs humains parmi [playerIds].
  Future<Map<UuidValue, UuidValue>> _userIdsOfPlayers(
    Session session,
    Set<UuidValue> playerIds,
  ) async {
    if (playerIds.isEmpty) return {};
    final players = await Player.db.find(
      session,
      where: (t) => t.id.inSet(playerIds),
    );
    return {for (final p in players) ?p.id: ?p.userId};
  }

  RivalryDto _rivalry(
    User friend,
    List<PlayedGame> games,
    Map<String, String> photoUrls,
  ) {
    final results = games.map(resultOf).toList();
    int count(EnumMatchResult r) => results.where((x) => x == r).length;
    return RivalryDto(
      friend: _userDto(friend, photoUrls),
      wins: count(EnumMatchResult.win),
      losses: count(EnumMatchResult.loss),
      draws: count(EnumMatchResult.draw),
      streak: currentStreak(results),
      lastPlayedAt: games.firstOrNull?.partie.createdAt,
      partieIds: [for (final g in games) g.partie.id!],
    );
  }

  /// [candidates] sans soi-même, les invités ni les doublons (au plus
  /// [limit]), avec leur relation au joueur courant.
  Future<List<PlayerSearchResultDto>> _searchResults(
    Session session,
    User me,
    List<User> candidates,
    int limit,
  ) async {
    final guests = await _guestAuthUserIds(session, candidates);
    final seen = <UuidValue>{me.id!};
    final players = [
      for (final user in candidates)
        if (!guests.contains(user.authUserId) && seen.add(user.id!)) user,
    ].take(limit).toList();
    if (players.isEmpty) return [];

    final rows = await Friendship.db.find(
      session,
      where: (t) => t.pairKey.inSet(<String>{
        for (final user in players) friendPairKey(me.id!, user.id!),
      }),
    );
    final byOther = {
      for (final row in rows)
        row.requesterId == me.id ? row.addresseeId : row.requesterId: row,
    };
    final photoUrls = await ProfilePhoto.urls(
      session,
      players.map((u) => u.thumbnailPath),
    );
    return [
      for (final user in players)
        PlayerSearchResultDto(
          player: _userDto(user, photoUrls),
          relation: _relation(me, byOther[user.id]),
          friendshipId: byOther[user.id]?.id,
        ),
    ];
  }

  /// Envoie une demande d'ami à [userId] — ou accepte directement la sienne
  /// s'il en avait déjà envoyé une.
  Future<FriendshipDto> sendRequest(Session session, UuidValue userId) async {
    final me = await _requireMember(session);
    if (userId == me.id) {
      throw FriendsException(reason: EnumFriendsError.cannotAddSelf);
    }
    final other = await User.db.findById(session, userId);
    if (other == null ||
        other.authUserId == null ||
        await isAnonymousAuthUser(session, other.authUserId!)) {
      throw FriendsException(reason: EnumFriendsError.userNotFound);
    }

    final Friendship row;
    try {
      row = await session.db.transaction((transaction) async {
        final existing = await Friendship.db.findFirstRow(
          session,
          where: (t) => t.pairKey.equals(friendPairKey(me.id!, other.id!)),
          transaction: transaction,
          lockMode: LockMode.forUpdate,
        );
        if (existing == null) {
          await _checkFriendLimit(session, me, transaction);
          return Friendship.db.insertRow(
            session,
            Friendship(
              requesterId: me.id!,
              addresseeId: other.id!,
              pairKey: friendPairKey(me.id!, other.id!),
              status: EnumFriendshipStatus.pending,
            ),
            transaction: transaction,
          );
        }
        if (existing.status == EnumFriendshipStatus.accepted) {
          throw FriendsException(reason: EnumFriendsError.alreadyFriends);
        }
        if (existing.requesterId == me.id) {
          throw FriendsException(reason: EnumFriendsError.requestAlreadySent);
        }
        return _accept(session, existing, transaction);
      });
    } on DatabaseUniqueViolationException {
      // L'autre joueur a envoyé sa demande au même instant : la sienne est
      // passée, on la traite comme une demande déjà là.
      return sendRequest(session, userId);
    }

    await _notifyBoth(session, me, other);
    return _toDto(session, me, row, other);
  }

  /// Accepte la demande [friendshipId] reçue par le joueur courant.
  Future<FriendshipDto> acceptRequest(
    Session session,
    UuidValue friendshipId,
  ) async {
    final me = await _requireMember(session);
    final row = await session.db.transaction((transaction) async {
      final pending = await _lockPending(session, friendshipId, transaction);
      if (pending.addresseeId != me.id) {
        throw FriendsException(reason: EnumFriendsError.requestNotFound);
      }
      return _accept(session, pending, transaction);
    });
    final other = (await User.db.findById(session, row.requesterId))!;
    await _notifyBoth(session, me, other);
    return _toDto(session, me, row, other);
  }

  /// Refuse la demande [friendshipId] reçue par le joueur courant.
  Future<void> declineRequest(Session session, UuidValue friendshipId) =>
      _deletePending(session, friendshipId, incoming: true);

  /// Annule la demande [friendshipId] envoyée par le joueur courant.
  Future<void> cancelRequest(Session session, UuidValue friendshipId) =>
      _deletePending(session, friendshipId, incoming: false);

  /// Retire [userId] des amis du joueur courant (et inversement).
  Future<void> removeFriend(Session session, UuidValue userId) async {
    final me = await _requireMember(session);
    final deleted = await Friendship.db.deleteWhere(
      session,
      where: (t) =>
          t.pairKey.equals(friendPairKey(me.id!, userId)) &
          t.status.equals(EnumFriendshipStatus.accepted),
    );
    if (deleted.isEmpty) {
      throw FriendsException(reason: EnumFriendsError.notFriends);
    }
    final other = await User.db.findById(session, userId);
    await _notifyBoth(session, me, other);
  }

  Future<void> _deletePending(
    Session session,
    UuidValue friendshipId, {
    required bool incoming,
  }) async {
    final me = await _requireMember(session);
    final deleted = await Friendship.db.deleteWhere(
      session,
      where: (t) =>
          t.id.equals(friendshipId) &
          t.status.equals(EnumFriendshipStatus.pending) &
          (incoming
              ? t.addresseeId.equals(me.id)
              : t.requesterId.equals(me.id)),
    );
    if (deleted.isEmpty) {
      throw FriendsException(reason: EnumFriendsError.requestNotFound);
    }
    final row = deleted.single;
    final other = await User.db.findById(
      session,
      incoming ? row.requesterId : row.addresseeId,
    );
    await _notifyBoth(session, me, other);
  }

  Future<Friendship> _lockPending(
    Session session,
    UuidValue friendshipId,
    Transaction transaction,
  ) async {
    final row = await Friendship.db.findById(
      session,
      friendshipId,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (row == null || row.status != EnumFriendshipStatus.pending) {
      throw FriendsException(reason: EnumFriendsError.requestNotFound);
    }
    return row;
  }

  /// Passe [pending] en ami, si aucun des deux n'a atteint [maxFriends].
  Future<Friendship> _accept(
    Session session,
    Friendship pending,
    Transaction transaction,
  ) async {
    for (final userId in [pending.requesterId, pending.addresseeId]) {
      final count = await Friendship.db.count(
        session,
        where: (t) =>
            (t.requesterId.equals(userId) | t.addresseeId.equals(userId)) &
            t.status.equals(EnumFriendshipStatus.accepted),
        transaction: transaction,
      );
      if (count >= maxFriends) {
        throw FriendsException(reason: EnumFriendsError.tooManyFriends);
      }
    }
    return Friendship.db.updateRow(
      session,
      pending.copyWith(
        status: EnumFriendshipStatus.accepted,
        respondedAt: DateTime.now(),
      ),
      transaction: transaction,
    );
  }

  /// Une demande de plus n'aurait aucune chance d'être acceptée.
  Future<void> _checkFriendLimit(
    Session session,
    User me,
    Transaction transaction,
  ) async {
    final count = await Friendship.db.count(
      session,
      where: (t) =>
          (t.requesterId.equals(me.id) | t.addresseeId.equals(me.id)) &
          t.status.equals(EnumFriendshipStatus.accepted),
      transaction: transaction,
    );
    if (count >= maxFriends) {
      throw FriendsException(reason: EnumFriendsError.tooManyFriends);
    }
  }

  Future<User> _requireMember(Session session) async {
    final authUserId = session.authenticated!.authUserId;
    if (await isAnonymousAuthUser(session, authUserId)) {
      throw FriendsException(reason: EnumFriendsError.guestNotAllowed);
    }
    final user = await User.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (user == null) {
      throw StateError('Aucun User pour l\'AuthUser $authUserId');
    }
    return user;
  }

  /// Code ami de [me], tiré au hasard au premier appel.
  Future<String> _ensureFriendCode(Session session, User me) async {
    if (me.friendCode != null) return me.friendCode!;
    while (true) {
      final code = FriendCode.generate();
      try {
        await User.db.updateRow(
          session,
          me.copyWith(friendCode: code),
          columns: (t) => [t.friendCode],
        );
        return code;
      } on DatabaseUniqueViolationException {
        // Code déjà pris : on en tire un autre.
      }
    }
  }

  Future<Set<UuidValue>> _guestAuthUserIds(
    Session session,
    List<User> users,
  ) async {
    final authUserIds = {
      for (final user in users)
        if (user.authUserId != null) user.authUserId!,
    };
    if (authUserIds.isEmpty) return {};
    final accounts = await AnonymousAccount.db.find(
      session,
      where: (t) => t.authUserId.inSet(authUserIds),
    );
    return {for (final account in accounts) account.authUserId};
  }

  Future<void> _notifyBoth(Session session, User me, User? other) async {
    for (final authUserId in [me.authUserId, other?.authUserId]) {
      if (authUserId != null) {
        await notifyUser(session, authUserId, friends: true);
      }
    }
  }

  EnumFriendRelation _relation(User me, Friendship? row) {
    if (row == null) return EnumFriendRelation.none;
    if (row.status == EnumFriendshipStatus.accepted) {
      return EnumFriendRelation.friend;
    }
    return row.requesterId == me.id
        ? EnumFriendRelation.requestSent
        : EnumFriendRelation.requestReceived;
  }

  Future<FriendshipDto> _toDto(
    Session session,
    User me,
    Friendship row,
    User other,
  ) async {
    final photoUrls = await ProfilePhoto.urls(session, [other.thumbnailPath]);
    return _friendshipDto(me, row, other, photoUrls);
  }

  /// Les DTO de [rows], et les autres joueurs par `User.id`.
  Future<(List<FriendshipDto>, Map<UuidValue, User>)> _toDtos(
    Session session,
    User me,
    List<Friendship> rows,
  ) async {
    if (rows.isEmpty) return (<FriendshipDto>[], <UuidValue, User>{});
    final others = await User.db.find(
      session,
      where: (t) => t.id.inSet(<UuidValue>{
        for (final row in rows)
          row.requesterId == me.id ? row.addresseeId : row.requesterId,
      }),
    );
    final byId = {for (final user in others) user.id!: user};
    final photoUrls = await ProfilePhoto.urls(
      session,
      others.map((u) => u.thumbnailPath),
    );
    return (
      [
        for (final row in rows)
          _friendshipDto(
            me,
            row,
            byId[row.requesterId == me.id ? row.addresseeId : row.requesterId]!,
            photoUrls,
          ),
      ],
      byId,
    );
  }

  /// [friends] avec leur présence : en partie (serveur) l'emporte sur en
  /// ligne ; sinon l'heure de leur dernière déconnexion.
  Future<List<FriendshipDto>> _withPresence(
    Session session,
    List<FriendshipDto> friends,
    Map<UuidValue, User> users,
  ) async {
    if (friends.isEmpty) return friends;
    final online = await FriendsConfig.presence.onlineAmong([
      for (final f in friends) ?users[f.other.userId]?.authUserId,
    ]);
    final playing = await _playing(session, {
      for (final f in friends) f.other.userId,
    });
    return [
      for (final f in friends)
        f.copyWith(
          presence: playing.containsKey(f.other.userId)
              ? EnumFriendPresence.playing
              : online.contains(users[f.other.userId]?.authUserId)
              ? EnumFriendPresence.online
              : EnumFriendPresence.offline,
          playing: playing[f.other.userId],
          lastSeenAt: users[f.other.userId]?.lastSeenAt,
        ),
    ];
  }

  /// Type de la partie serveur en cours de chacun de [userIds] qui joue.
  Future<Map<UuidValue, EnumType>> _playing(
    Session session,
    Set<UuidValue> userIds,
  ) async {
    final players = await Player.db.find(
      session,
      where: (t) => t.userId.inSet(userIds),
    );
    if (players.isEmpty) return {};
    final userByPlayer = {for (final p in players) p.id!: p.userId!};
    final playerIds = userByPlayer.keys.toSet();
    final parties = await Partie.db.find(
      session,
      where: (t) =>
          t.typePartie.inSet(ServerGame.liveTypes) &
          t.status.equals(EnumStatut.inProgress) &
          (t.playerRougeId.inSet(playerIds) | t.playerJauneId.inSet(playerIds)),
    );
    return {
      for (final partie in parties)
        for (final playerId in [partie.playerRougeId, partie.playerJauneId])
          ?userByPlayer[playerId]: partie.typePartie,
    };
  }

  static int _presenceOrder(EnumFriendPresence? presence) => switch (presence) {
    EnumFriendPresence.online => 0,
    EnumFriendPresence.playing => 1,
    _ => 2,
  };

  FriendshipDto _friendshipDto(
    User me,
    Friendship row,
    User other,
    Map<String, String> photoUrls,
  ) => FriendshipDto(
    id: row.id!,
    other: _userDto(other, photoUrls),
    status: row.status,
    incoming: row.addresseeId == me.id,
    createdAt: row.createdAt,
    respondedAt: row.respondedAt,
  );

  FriendUserDto _userDto(User user, Map<String, String> photoUrls) =>
      FriendUserDto(
        userId: user.id!,
        username: user.username,
        thumbnailUrl: photoUrls[user.thumbnailPath],
        elo: user.elo,
      );
}
