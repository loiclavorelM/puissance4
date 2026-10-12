import 'dart:async';
import 'dart:math';

import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../bot/bot_networks.dart';
import '../friends/friend_notifier.dart';
import '../generated/protocol.dart';
import '../live/live_notifier.dart';
import '../ranked/elo.dart';
import 'enum_color_extensions.dart';
import 'server_game_config.dart';

/// Un camp d'une partie serveur : un joueur humain ([user]) ou un bot serveur
/// ([bot]) — exactement un des deux, comme `Player`.
class GameSeat {
  const GameSeat.human(User this.user) : bot = null;
  const GameSeat.bot(Bot this.bot) : user = null;

  final User? user;
  final Bot? bot;

  bool get isBot => bot != null;

  GamePlayerInfo get info => isBot
      ? GamePlayerInfo(username: bot!.botName, elo: bot!.elo, isBot: true)
      : GamePlayerInfo(username: user!.username, elo: user!.elo);

  Player get asPlayer =>
      isBot ? Player(botId: bot!.id) : Player(userId: user!.id);
}

/// Levée par [ServerGame.start] : [user] a déjà la partie [partieId] en
/// cours. Chaque appelant la traduit en `GameException` selon qui est
/// concerné (lui-même, ou l'hôte d'une salle Multi).
class SeatBusyException implements Exception {
  const SeatBusyException(this.user, this.partieId);

  final User user;
  final UuidValue partieId;
}

/// Les deux camps d'une partie serveur.
class GameSeats {
  const GameSeats({required this.rouge, required this.jaune});

  final GameSeat rouge;
  final GameSeat jaune;

  GameSeat of(EnumColor color) => color == EnumColor.rouge ? rouge : jaune;

  /// Couleur jouée par l'utilisateur [userId], ou `null` s'il ne joue pas
  /// cette partie.
  EnumColor? colorOf(UuidValue userId) => rouge.user?.id == userId
      ? EnumColor.rouge
      : jaune.user?.id == userId
      ? EnumColor.jaune
      : null;
}

/// Logique d'une partie jouée sur le serveur (Multi : deux humains ; Classé :
/// un humain contre un bot serveur). La base est la seule source de vérité
/// (coups, trait, présence) et chaque changement est fait sous verrou de
/// ligne (`SELECT … FOR UPDATE`) : deux appels concurrents — y compris depuis
/// deux serveurs d'un cluster — ne peuvent pas jouer deux coups à la fois.
/// Les événements partent sur `session.messages` après le commit.
///
/// Garantie anti-fantôme : toute partie `inProgress` a toujours un rappel
/// `checkTurnTimeout` programmé, qui la termine si plus personne ne joue.
abstract final class ServerGame {
  static const liveTypes = {EnumType.multi, EnumType.classe};

  static String partieChannel(UuidValue partieId) =>
      'game.partie.${partieId.uuid}';

  static Future<User> requireUser(Session session) async {
    final authUserId = session.authenticated!.authUserId;
    final user = await User.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (user == null) throw GameException(reason: EnumGameError.userNotFound);
    return user;
  }

  /// Partie serveur (Multi ou Classé) en cours de [userId], ou `null`.
  static Future<Partie?> findActivePartie(
    Session session,
    UuidValue userId, {
    Transaction? transaction,
  }) async {
    final players = await Player.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      transaction: transaction,
    );
    if (players.isEmpty) return null;
    final playerIds = players.map((p) => p.id!).toSet();
    return Partie.db.findFirstRow(
      session,
      where: (t) =>
          t.typePartie.inSet(liveTypes) &
          t.status.equals(EnumStatut.inProgress) &
          (t.playerRougeId.inSet(playerIds) | t.playerJauneId.inSet(playerIds)),
      orderBy: (t) => t.createdAt.desc(),
      transaction: transaction,
    );
  }

  /// Une seule partie serveur en cours par joueur, tous modes confondus.
  /// Refus rapide avant d'ouvrir une salle ou de chercher un bot ; la
  /// garantie elle-même est tenue par [start], sous verrou.
  static Future<void> ensureNotInGame(Session session, User user) async {
    final active = await findActivePartie(session, user.id!);
    if (active != null) {
      throw GameException(
        reason: EnumGameError.alreadyInGame,
        partieId: active.id,
      );
    }
  }

  static Future<GameSeats> seats(Session session, Partie partie) async {
    final players = await Player.db.find(
      session,
      where: (t) =>
          t.id.inSet(<UuidValue>{partie.playerRougeId, partie.playerJauneId}),
    );
    final userIds = {for (final p in players) ?p.userId};
    final botIds = {for (final p in players) ?p.botId};
    final users = userIds.isEmpty
        ? const <User>[]
        : await User.db.find(session, where: (t) => t.id.inSet(userIds));
    final bots = botIds.isEmpty
        ? const <Bot>[]
        : await Bot.db.find(session, where: (t) => t.id.inSet(botIds));

    GameSeat seatOf(UuidValue playerId) {
      final player = players.firstWhere((p) => p.id == playerId);
      return player.botId != null
          ? GameSeat.bot(bots.firstWhere((b) => b.id == player.botId))
          : GameSeat.human(users.firstWhere((u) => u.id == player.userId));
    }

    return GameSeats(
      rouge: seatOf(partie.playerRougeId),
      jaune: seatOf(partie.playerJauneId),
    );
  }

  /// Crée une partie serveur, directement `inProgress` avec ses deux camps —
  /// seul endroit où une `Partie` Multi ou Classé naît. Couleurs tirées au
  /// sort ; Rouge commence (si c'est un bot, il joue aussitôt). Lève
  /// [SeatBusyException] si un des humains a déjà une partie en cours.
  static Future<Partie> start(
    Session session, {
    required EnumType typePartie,
    required GameSeat first,
    required GameSeat second,
    String? code,
  }) async {
    final firstIsRouge = Random().nextBool();
    final rouge = firstIsRouge ? first : second;
    final jaune = firstIsRouge ? second : first;
    final partie = await session.db.transaction((transaction) async {
      await _claimSeats(session, [first, second], transaction);
      final rougePlayer = await Player.db.insertRow(
        session,
        rouge.asPlayer,
        transaction: transaction,
      );
      final jaunePlayer = await Player.db.insertRow(
        session,
        jaune.asPlayer,
        transaction: transaction,
      );
      return Partie.db.insertRow(
        session,
        Partie(
          code: code,
          typePartie: typePartie,
          playerRougeId: rougePlayer.id!,
          playerJauneId: jaunePlayer.id!,
          status: EnumStatut.inProgress,
          moves: const [],
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: transaction,
      );
    });
    _scheduleTurn(
      partie,
      botToPlay: _isBotTurn(partie, GameSeats(rouge: rouge, jaune: jaune)),
    );
    // Leurs amis les voient « en partie » (E15).
    await notifyFriendsOf(session, [
      for (final seat in [first, second]) ?seat.user?.id,
    ]);
    return partie;
  }

  /// Photo complète de [partie], telle qu'envoyée aux clients.
  static GameEvent snapshot(
    Partie partie,
    GameSeats seats,
    EnumGameEventType type,
  ) {
    final inProgress = partie.status == EnumStatut.inProgress;
    return GameEvent(
      type: type,
      code: partie.code,
      partieId: partie.id,
      typePartie: partie.typePartie,
      rouge: seats.rouge.info,
      jaune: seats.jaune.info,
      moves: partie.moves,
      turnDeadline: inProgress ? turnDeadline(partie) : null,
      winner: partie.winner,
      endReason: partie.endReason,
    );
  }

  /// Le tour court depuis le dernier coup : `updatedAt` n'est touché que par
  /// les coups (et la création/fin, ou un redémarrage du serveur — cf.
  /// [resumePending]), jamais par la présence.
  static DateTime turnDeadline(Partie partie) =>
      (partie.updatedAt ?? partie.createdAt).add(ServerGameConfig.turnTimeout);

  /// Un stream de [color] s'ouvre sur la partie : il devient la connexion de
  /// référence de ce joueur. Renvoie l'id de cette connexion (à rendre à
  /// [detach]) et l'état de la partie lu sous verrou.
  static Future<({UuidValue connectionId, Partie partie})> attach(
    Session session,
    UuidValue partieId,
    EnumColor color,
  ) async {
    await _resuming?.future.timeout(_maxResumeWait, onTimeout: () {});
    final connectionId = const Uuid().v4obj();
    var wasDisconnected = false;
    final partie = await session.db.transaction((transaction) async {
      final partie = await _lock(session, partieId, transaction);
      if (partie.status != EnumStatut.inProgress) return partie;
      wasDisconnected = _disconnectedAt(partie, color) != null;
      _setPresence(partie, color, connectionId, null);
      await _savePresence(session, partie, transaction);
      return partie;
    });
    if (wasDisconnected) {
      await session.messages.postMessage(
        partieChannel(partieId),
        GameEvent(
          type: EnumGameEventType.opponentReconnected,
          partieId: partieId,
          aboutColor: color,
        ),
      );
    }
    return (connectionId: connectionId, partie: partie);
  }

  /// Le stream [connectionId] de [color] s'est fermé. Ignoré si ce n'est
  /// plus sa connexion de référence (il s'est déjà reconnecté ailleurs) :
  /// sinon le joueur a [ServerGameConfig.disconnectGrace] pour revenir.
  static Future<void> detach(
    Session session,
    UuidValue partieId,
    EnumColor color,
    UuidValue connectionId,
  ) async {
    final disconnected = await session.db.transaction((transaction) async {
      final partie = await _lock(session, partieId, transaction);
      if (partie.status != EnumStatut.inProgress ||
          _connectionId(partie, color) != connectionId) {
        return false;
      }
      _setPresence(partie, color, null, DateTime.now().toUtc());
      await _savePresence(session, partie, transaction);
      return true;
    });
    if (!disconnected) return;

    await session.messages.postMessage(
      partieChannel(partieId),
      GameEvent(
        type: EnumGameEventType.opponentDisconnected,
        partieId: partieId,
        aboutColor: color,
      ),
    );
    ServerGameConfig.scheduler.scheduleDisconnectCheck(
      partieId,
      ServerGameConfig.disconnectGrace,
    );
  }

  /// Coup d'un joueur humain.
  static Future<void> playMove(
    Session session,
    UuidValue partieId,
    User user,
    int column,
  ) async {
    final (partie, seats, color) = await loadAsPlayer(session, partieId, user);
    if (partie.status != EnumStatut.inProgress) {
      throw GameException(reason: EnumGameError.gameOver);
    }

    final updated = await session.db.transaction((transaction) async {
      final partie = await _lock(session, partieId, transaction);
      if (partie.status != EnumStatut.inProgress) {
        throw GameException(reason: EnumGameError.gameOver);
      }
      if (Connect4Rules.discToPlay(partie.moves) != color.disc) {
        throw GameException(reason: EnumGameError.notYourTurn);
      }
      if (!Connect4Rules.isValidMove(partie.moves, column)) {
        throw GameException(reason: EnumGameError.invalidMove);
      }
      return _applyMove(session, partie, seats, column, transaction);
    });
    await _afterMove(session, updated, seats);
  }

  /// Rappel [GameScheduler.scheduleBotMove] : fait jouer le bot serveur si
  /// c'est toujours son tour, à [moveCount] coups.
  static Future<void> playBotMove(
    Session session,
    UuidValue partieId,
    int moveCount,
  ) async {
    final partie = await Partie.db.findById(session, partieId);
    if (partie == null ||
        partie.status != EnumStatut.inProgress ||
        partie.moves.length != moveCount) {
      return;
    }
    final seats = await ServerGame.seats(session, partie);
    final seat = seats.of(Connect4Rules.discToPlay(partie.moves).color);
    if (!seat.isBot) return;

    // Colonne choisie avant la transaction : la position ne peut plus
    // changer qu'en ajoutant un coup, ce que [moveCount] revérifie sous
    // verrou.
    final bot = seat.bot!;
    final column = await BotNetworks.chooseColumn(
      // Partie commencée contre un ancien bot (heuristique, avant E5) : le
      // niveau d'Elo le plus proche prend la suite.
      BotLevel.byId(bot.id!.uuid) ?? BotLevel.forElo(bot.elo),
      partie.moves,
    );

    final updated = await session.db.transaction((transaction) async {
      final partie = await _lock(session, partieId, transaction);
      if (partie.status != EnumStatut.inProgress ||
          partie.moves.length != moveCount) {
        return null;
      }
      return _applyMove(session, partie, seats, column, transaction);
    });
    if (updated != null) await _afterMove(session, updated, seats);
  }

  /// Abandon explicite : l'adversaire gagne, sauf si l'appelant n'a encore
  /// joué aucun coup (partie annulée) — même si l'adversaire a déjà joué.
  /// Même règle au temps et à la déconnexion : quitter ne rapporte jamais
  /// plus d'une façon que d'une autre. Sans effet si la partie est finie.
  static Future<void> abandon(
    Session session,
    UuidValue partieId,
    User user,
  ) async {
    final (_, seats, color) = await loadAsPlayer(session, partieId, user);
    await _resolve(session, partieId, seats, (partie, _) {
      _end(
        partie,
        winner: _moveCountOf(color, partie.moves) == 0
            ? null
            : color.other.asOutcome,
        reason: EnumGameEndReason.forfeit,
      );
      return true;
    });
  }

  /// Rappel [GameScheduler.scheduleTurnTimeout] : si la partie en est
  /// toujours à [moveCount] coups, le joueur au trait perd au temps — ou la
  /// partie est annulée s'il n'a encore joué aucun coup (même règle que
  /// [abandon] et [checkDisconnect]), ou en Multi si les deux joueurs sont
  /// partis.
  static Future<void> checkTurnTimeout(
    Session session,
    UuidValue partieId,
    int moveCount,
  ) async {
    await _resolve(session, partieId, null, (partie, _) {
      if (partie.moves.length != moveCount) return false;
      // Pas en Classé : le seul humain y est toujours celui au trait (le
      // bot répond aussitôt). Parti ou non, il perd au temps — sinon fermer
      // l'app dans une partie perdue éviterait la perte d'Elo.
      final humansGone =
          partie.typePartie == EnumType.multi &&
          EnumColor.values.every((c) => _isGone(partie, c, Duration.zero));
      final late = Connect4Rules.discToPlay(partie.moves).color;
      _end(
        partie,
        winner: _moveCountOf(late, partie.moves) == 0 || humansGone
            ? null
            : late.other.asOutcome,
        reason: EnumGameEndReason.timeout,
      );
      return true;
    });
  }

  /// Rappel [GameScheduler.scheduleDisconnectCheck] : un joueur toujours
  /// absent après le délai de grâce perd par abandon — ou la partie est
  /// annulée si les deux sont partis ou que le partant n'a joué aucun coup.
  static Future<void> checkDisconnect(
    Session session,
    UuidValue partieId,
  ) async {
    await _resolve(session, partieId, null, (partie, _) {
      final grace = ServerGameConfig.disconnectGrace;
      final rougeGone = _isGone(partie, EnumColor.rouge, grace);
      final jauneGone = _isGone(partie, EnumColor.jaune, grace);
      if (!rougeGone && !jauneGone) return false;
      final loser = rougeGone ? EnumColor.rouge : EnumColor.jaune;
      _end(
        partie,
        winner:
            (rougeGone && jauneGone) || _moveCountOf(loser, partie.moves) == 0
            ? null
            : loser.other.asOutcome,
        reason: EnumGameEndReason.disconnect,
      );
      return true;
    });
  }

  /// Posé par [holdStreamsUntilResumed] : les streams attendent sa fin avant
  /// de s'attacher à une partie ([attach]).
  static Completer<void>? _resuming;

  /// Attente maximale d'un stream bloqué par [holdStreamsUntilResumed] : si
  /// [resumePending] ne venait jamais, les parties restent jouables.
  static const _maxResumeWait = Duration(seconds: 30);

  /// À appeler avant `pod.start()` quand [resumePending] suit : sans ça, un
  /// client qui se reconnecte dès l'ouverture du serveur enregistrerait une
  /// connexion que la remise à zéro de [resumePending] effacerait aussitôt.
  static void holdStreamsUntilResumed() => _resuming ??= Completer<void>();

  /// Libère les streams retenus — fait par [resumePending] ; exposé pour les
  /// tests qui s'arrêteraient avant.
  static void releaseStreams() {
    _resuming?.complete();
    _resuming = null;
  }

  /// Au démarrage du serveur : les rappels en mémoire d'avant l'arrêt sont
  /// perdus, on les reprogramme pour chaque partie serveur encore en cours.
  /// N'annule rien directement.
  ///
  /// Si [ServerGameConfig.singleServer] : tous les streams d'avant l'arrêt
  /// sont morts avec le serveur. Chaque humain déjà passé par la partie
  /// (connecté, ou déjà en délai de grâce) repart « parti maintenant », avec
  /// un délai de grâce complet pour revenir, et le joueur au trait retrouve
  /// un tour complet : la panne n'est pas de leur fait. En cluster, ces
  /// streams peuvent vivre sur un autre serveur, donc rien n'est touché.
  static Future<void> resumePending(Session session) async {
    try {
      if (ServerGameConfig.singleServer) await _resetAfterReboot(session);
      final parties = await Partie.db.find(
        session,
        where: (t) =>
            t.typePartie.inSet(liveTypes) &
            t.status.equals(EnumStatut.inProgress),
      );
      if (parties.isEmpty) return;
      final botPlayerIds = {
        for (final player in await Player.db.find(
          session,
          where: (t) =>
              t.id.inSet(<UuidValue>{
                for (final p in parties) ...[p.playerRougeId, p.playerJauneId],
              }) &
              t.botId.notEquals(null),
        ))
          player.id!,
      };

      final now = DateTime.now().toUtc();
      Duration until(DateTime at) =>
          at.isAfter(now) ? at.difference(now) : Duration.zero;
      for (final partie in parties) {
        final toPlay = Connect4Rules.discToPlay(partie.moves).color;
        _scheduleTurn(
          partie,
          botToPlay: botPlayerIds.contains(
            toPlay == EnumColor.rouge
                ? partie.playerRougeId
                : partie.playerJauneId,
          ),
          turnDelay: until(turnDeadline(partie)),
          botDelay: Duration.zero,
        );
        for (final color in EnumColor.values) {
          final disconnectedAt = _disconnectedAt(partie, color);
          if (_connectionId(partie, color) == null && disconnectedAt != null) {
            ServerGameConfig.scheduler.scheduleDisconnectCheck(
              partie.id!,
              until(disconnectedAt.add(ServerGameConfig.disconnectGrace)),
            );
          }
        }
      }
    } finally {
      releaseStreams();
    }
  }

  /// Voir [resumePending] : un `UPDATE` par couleur puis un pour le tour,
  /// sans parcourir les parties une à une. Un bot, comme un humain jamais
  /// arrivé, n'a ni connexion ni départ : il n'est pas touché.
  static Future<void> _resetAfterReboot(Session session) async {
    final now = DateTime.now().toUtc();
    Expression liveInProgress(PartieTable t) =>
        t.typePartie.inSet(liveTypes) & t.status.equals(EnumStatut.inProgress);
    await session.db.transaction((transaction) async {
      for (final rouge in [true, false]) {
        await Partie.db.updateWhere(
          session,
          columnValues: (t) => rouge
              ? [t.rougeConnectionId(null), t.rougeDisconnectedAt(now)]
              : [t.jauneConnectionId(null), t.jauneDisconnectedAt(now)],
          where: (t) {
            final connection = rouge
                ? t.rougeConnectionId
                : t.jauneConnectionId;
            final left = rouge ? t.rougeDisconnectedAt : t.jauneDisconnectedAt;
            return liveInProgress(t) &
                (connection.notEquals(null) | left.notEquals(null));
          },
          transaction: transaction,
          noReturn: true,
        );
      }
      await Partie.db.updateWhere(
        session,
        columnValues: (t) => [t.updatedAt(now)],
        where: liveInProgress,
        transaction: transaction,
        noReturn: true,
      );
    });
  }

  /// Une seule partie serveur en cours par humain de [seats], même face à
  /// deux créations simultanées : verrou consultatif par joueur
  /// (`pg_advisory_xact_lock`, tenu jusqu'à la fin de [transaction]), puis
  /// vérification. Verrous pris dans un ordre fixe, pour que deux créations
  /// croisées (A+B et B+A) ne s'interbloquent pas.
  static Future<void> _claimSeats(
    Session session,
    List<GameSeat> seats,
    Transaction transaction,
  ) async {
    final users = [for (final seat in seats) ?seat.user]
      ..sort((a, b) => a.id!.uuid.compareTo(b.id!.uuid));
    for (final user in users) {
      await session.db.unsafeExecute(
        'SELECT pg_advisory_xact_lock(hashtextextended(@key, 0))',
        parameters: QueryParameters.named({
          'key': 'partie.user.${user.id!.uuid}',
        }),
        transaction: transaction,
      );
    }
    for (final user in users) {
      final active = await findActivePartie(
        session,
        user.id!,
        transaction: transaction,
      );
      if (active != null) throw SeatBusyException(user, active.id!);
    }
  }

  /// Joueur toujours présent sur la partie (stream ouvert, jamais arrivé,
  /// ou bot) — pour la photo envoyée à un stream qui (re)vient.
  static bool isPresent(Partie partie, EnumColor color) =>
      !_isGone(partie, color, Duration.zero);

  /// Coups joués par [color] : Rouge joue les indices pairs.
  static int _moveCountOf(EnumColor color, List<int> moves) =>
      color == EnumColor.rouge ? (moves.length + 1) ~/ 2 : moves.length ~/ 2;

  static Future<(Partie, GameSeats, EnumColor)> loadAsPlayer(
    Session session,
    UuidValue partieId,
    User user,
  ) async {
    final partie = await Partie.db.findById(session, partieId);
    if (partie == null || !liveTypes.contains(partie.typePartie)) {
      throw GameException(reason: EnumGameError.gameNotFound);
    }
    final seats = await ServerGame.seats(session, partie);
    final color = seats.colorOf(user.id!);
    if (color == null) throw GameException(reason: EnumGameError.notAPlayer);
    return (partie, seats, color);
  }

  /// Ajoute [column] à [partie] (déjà validé et verrouillé), la termine si
  /// le coup est décisif et enregistre le tout — Elo compris.
  static Future<Partie> _applyMove(
    Session session,
    Partie partie,
    GameSeats seats,
    int column,
    Transaction transaction,
  ) async {
    partie.moves = [...partie.moves, column];
    partie.updatedAt = DateTime.now().toUtc();
    final outcome = Connect4Rules.outcome(partie.moves);
    if (outcome != null) {
      _end(
        partie,
        winner: outcome.asOutcome,
        reason: outcome == Connect4Outcome.draw
            ? EnumGameEndReason.boardFull
            : EnumGameEndReason.connectFour,
      );
    }
    final saved = await Partie.db.updateRow(
      session,
      partie,
      columns: (t) => [t.moves, t.updatedAt, t.status, t.winner, t.endReason],
      transaction: transaction,
    );
    if (outcome != null) {
      await _applyElo(session, saved, seats, transaction);
    }
    return saved;
  }

  /// Après un coup enregistré : annonce, puis programme la suite (fin du
  /// tour, coup du bot).
  static Future<void> _afterMove(
    Session session,
    Partie partie,
    GameSeats seats,
  ) async {
    if (partie.status != EnumStatut.inProgress) {
      await _announceEnd(session, partie, seats);
      return;
    }
    await session.messages.postMessage(
      partieChannel(partie.id!),
      snapshot(partie, seats, EnumGameEventType.moveApplied),
    );
    _scheduleTurn(partie, botToPlay: _isBotTurn(partie, seats));
  }

  /// Seul endroit qui programme la suite d'un tour : sa fin après
  /// [turnDelay] (un tour complet par défaut) et, si [botToPlay], le coup du
  /// bot après [botDelay].
  static void _scheduleTurn(
    Partie partie, {
    required bool botToPlay,
    Duration? turnDelay,
    Duration? botDelay,
  }) {
    final scheduler = ServerGameConfig.scheduler;
    scheduler.scheduleTurnTimeout(
      partie.id!,
      partie.moves.length,
      turnDelay ?? ServerGameConfig.turnTimeout,
    );
    if (botToPlay) {
      scheduler.scheduleBotMove(
        partie.id!,
        partie.moves.length,
        botDelay ?? ServerGameConfig.botMoveDelay,
      );
    }
  }

  static bool _isBotTurn(Partie partie, GameSeats seats) =>
      seats.of(Connect4Rules.discToPlay(partie.moves).color).isBot;

  /// Applique [decide] sous verrou à une partie encore en cours ; s'il
  /// renvoie `true` (il a appelé [_end]), enregistre et annonce la fin.
  static Future<void> _resolve(
    Session session,
    UuidValue partieId,
    GameSeats? seats,
    bool Function(Partie partie, GameSeats seats) decide,
  ) async {
    final current = await Partie.db.findById(session, partieId);
    if (current == null || current.status != EnumStatut.inProgress) return;
    final resolvedSeats = seats ?? await ServerGame.seats(session, current);

    final ended = await session.db.transaction((transaction) async {
      final partie = await _lock(session, partieId, transaction);
      if (partie.status != EnumStatut.inProgress ||
          !decide(partie, resolvedSeats)) {
        return null;
      }
      final saved = await Partie.db.updateRow(
        session,
        partie,
        columns: (t) => [t.updatedAt, t.status, t.winner, t.endReason],
        transaction: transaction,
      );
      await _applyElo(session, saved, resolvedSeats, transaction);
      return saved;
    });
    if (ended != null) await _announceEnd(session, ended, resolvedSeats);
  }

  /// Termine [partie] (sans l'enregistrer) : `finished` avec [winner], ou
  /// `abandoned` sans vainqueur si [winner] est `null`.
  static void _end(
    Partie partie, {
    required EnumOutcome? winner,
    required EnumGameEndReason reason,
  }) {
    partie
      ..status = winner == null ? EnumStatut.abandoned : EnumStatut.finished
      ..winner = winner
      ..endReason = winner == null ? EnumGameEndReason.cancelled : reason
      ..updatedAt = DateTime.now().toUtc();
  }

  /// Classé terminé : Elo du joueur humain recalculé contre l'Elo virtuel du
  /// bot, avec une ligne `EloHistory`. Dans la transaction de fin de partie,
  /// donc appliqué exactement une fois. Le Multi ne change pas l'Elo.
  static Future<void> _applyElo(
    Session session,
    Partie partie,
    GameSeats seats,
    Transaction transaction,
  ) async {
    if (partie.typePartie != EnumType.classe ||
        partie.status != EnumStatut.finished) {
      return;
    }
    for (final color in EnumColor.values) {
      final seat = seats.of(color);
      if (seat.isBot) continue;
      final user = await User.db.findById(
        session,
        seat.user!.id!,
        transaction: transaction,
      );
      if (user == null) continue;
      final opponentElo = seats.of(color.other).info.elo;
      final score = partie.winner == EnumOutcome.draw
          ? 0.5
          : partie.winner == color.asOutcome
          ? 1.0
          : 0.0;
      final variation = Elo.delta(user.elo, opponentElo, score);
      user
        ..elo = user.elo + variation
        ..updatedAt = DateTime.now().toUtc();
      await User.db.updateRow(
        session,
        user,
        columns: (t) => [t.elo, t.updatedAt],
        transaction: transaction,
      );
      await EloHistory.db.insertRow(
        session,
        EloHistory(
          userId: user.id!,
          partieId: partie.id!,
          eloVariation: variation,
          newElo: user.elo,
        ),
        transaction: transaction,
      );
    }
  }

  static Future<void> _announceEnd(
    Session session,
    Partie partie,
    GameSeats seats,
  ) async {
    await session.messages.postMessage(
      partieChannel(partie.id!),
      snapshot(partie, seats, EnumGameEventType.gameOver),
    );
    // Leurs amis ne les voient plus « en partie » (E15).
    await notifyFriendsOf(session, [
      for (final color in EnumColor.values) ?seats.of(color).user?.id,
    ]);
    // Une partie annulée n'entre ni dans l'historique ni dans les stats.
    if (partie.status != EnumStatut.finished) return;
    for (final color in EnumColor.values) {
      final authUserId = seats.of(color).user?.authUserId;
      if (authUserId == null) continue;
      if (partie.typePartie == EnumType.classe) {
        // L'Elo a changé : Classement compris.
        await notifyPartieFinished(session, authUserId);
      } else {
        await notifyUser(session, authUserId, profile: true, history: true);
      }
    }
  }

  static Future<Partie> _lock(
    Session session,
    UuidValue partieId,
    Transaction transaction,
  ) async {
    final partie = await Partie.db.findById(
      session,
      partieId,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (partie == null) {
      throw GameException(reason: EnumGameError.gameNotFound);
    }
    return partie;
  }

  static Future<void> _savePresence(
    Session session,
    Partie partie,
    Transaction transaction,
  ) => Partie.db.updateRow(
    session,
    partie,
    columns: (t) => [
      t.rougeConnectionId,
      t.rougeDisconnectedAt,
      t.jauneConnectionId,
      t.jauneDisconnectedAt,
    ],
    transaction: transaction,
  );

  /// Parti depuis au moins [grace] : plus aucun stream ouvert et un départ
  /// enregistré (un joueur jamais arrivé — ou un bot — n'est pas "parti").
  static bool _isGone(Partie partie, EnumColor color, Duration grace) {
    final disconnectedAt = _disconnectedAt(partie, color);
    return _connectionId(partie, color) == null &&
        disconnectedAt != null &&
        DateTime.now().toUtc().difference(disconnectedAt) >= grace;
  }

  static UuidValue? _connectionId(Partie partie, EnumColor color) =>
      color == EnumColor.rouge
      ? partie.rougeConnectionId
      : partie.jauneConnectionId;

  static DateTime? _disconnectedAt(Partie partie, EnumColor color) =>
      color == EnumColor.rouge
      ? partie.rougeDisconnectedAt
      : partie.jauneDisconnectedAt;

  static void _setPresence(
    Partie partie,
    EnumColor color,
    UuidValue? connectionId,
    DateTime? disconnectedAt,
  ) {
    if (color == EnumColor.rouge) {
      partie
        ..rougeConnectionId = connectionId
        ..rougeDisconnectedAt = disconnectedAt;
    } else {
      partie
        ..jauneConnectionId = connectionId
        ..jauneDisconnectedAt = disconnectedAt;
    }
  }
}
