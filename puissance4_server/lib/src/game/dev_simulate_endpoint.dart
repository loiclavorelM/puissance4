import 'dart:math';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../generated/protocol.dart';

/// Outil de dev temporaire — insère une partie Classé/Multi terminée
/// (issue et couleur aléatoires) pour l'utilisateur authentifié, pour
/// tester `nbParties`/`nbVictoires` (`ProfileEndpoint.getMyProfile`) sans
/// vrai moteur de jeu (E4). Fait aussi varier `User.elo` (±5 à 25, pas la
/// vraie formule Elo — hors scope, futur moteur/E7) avec une `EloHistory`
/// correspondante, pour pouvoir tester le Classement (E8) en dev. À retirer
/// une fois E4 fait.
class DevSimulateEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<void> simulatePartie(Session session) async {
    final authUserId = session.authenticated!.authUserId;
    final user = await User.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (user == null) {
      throw StateError('No User row for authenticated AuthUser $authUserId');
    }

    final bot = await Bot.db.findFirstRow(session);
    if (bot == null) {
      throw StateError('No Bot seeded — run the bot seed first.');
    }

    final random = Random();
    final userIsRouge = random.nextBool();
    final userWins = random.nextBool();
    final typePartie = random.nextBool() ? EnumType.classe : EnumType.multi;

    final userPlayer = await Player.db.insertRow(
      session,
      Player(userId: user.id),
    );
    final botPlayer = await Player.db.insertRow(
      session,
      Player(botId: bot.id),
    );

    final winner = userWins
        ? (userIsRouge ? EnumOutcome.rouge : EnumOutcome.jaune)
        : (userIsRouge ? EnumOutcome.jaune : EnumOutcome.rouge);

    final partie = await Partie.db.insertRow(
      session,
      Partie(
        typePartie: typePartie,
        playerRougeId: userIsRouge ? userPlayer.id! : botPlayer.id!,
        playerJauneId: userIsRouge ? botPlayer.id! : userPlayer.id!,
        winner: winner,
        status: EnumStatut.finished,
        moves: const [],
      ),
    );

    final eloVariation = (5 + random.nextInt(21)) * (userWins ? 1 : -1);
    final newElo = user.elo + eloVariation;
    user.elo = newElo;
    await User.db.updateRow(session, user);

    await EloHistory.db.insertRow(
      session,
      EloHistory(
        userId: user.id!,
        partieId: partie.id!,
        eloVariation: eloVariation,
        newElo: newElo,
      ),
    );
  }
}
