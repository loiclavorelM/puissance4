import 'dart:math';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../generated/protocol.dart';

/// Outil de dev temporaire — insère une partie Classé/Multi terminée
/// (issue et couleur aléatoires) pour l'utilisateur authentifié, pour
/// tester `nbParties`/`nbVictoires` (`ProfileEndpoint.getMyProfile`) sans
/// vrai moteur de jeu (E4). À retirer une fois E4 fait.
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
        ? (userIsRouge ? EnumPlayer.rouge : EnumPlayer.jaune)
        : (userIsRouge ? EnumPlayer.jaune : EnumPlayer.rouge);

    await Partie.db.insertRow(
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
  }
}
