import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:serverpod/serverpod.dart';

import '../game/server_game.dart';
import '../generated/protocol.dart';

/// Classé : partie contre un bot joué **par le serveur**, qui valide chaque
/// coup — l'Elo gagné ne peut donc pas être truqué côté client. Le bot est
/// choisi d'après l'Elo du joueur (cahier des charges : < 1000 Débutant,
/// < 1400 Medium, sinon Expert). La partie se suit ensuite comme toute
/// partie serveur, par `GameEndpoint.watchPartie` ; l'Elo est mis à jour à
/// sa fin (`ServerGame`).
class RankedEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Crée la partie Classé et renvoie son id. Pas de salle ni de stream ici :
  /// si le client ne vient jamais la suivre, la fin du tour la termine comme
  /// n'importe quelle partie serveur abandonnée.
  Future<UuidValue> startRanked(Session session) async {
    final me = await ServerGame.requireUser(session);
    await ServerGame.ensureNotInGame(session, me);

    final bots = await Bot.db.find(session, orderBy: (t) => t.elo);
    if (bots.isEmpty) {
      throw GameException(reason: EnumGameError.noBotAvailable);
    }
    final strength = BotStrength.fromElo(me.elo);
    final bot = bots.firstWhere(
      (b) => BotStrength.fromElo(b.elo) == strength,
      orElse: () => bots.reduce(
        (a, b) => (a.elo - me.elo).abs() <= (b.elo - me.elo).abs() ? a : b,
      ),
    );

    try {
      final partie = await ServerGame.start(
        session,
        typePartie: EnumType.classe,
        first: GameSeat.human(me),
        second: GameSeat.bot(bot),
      );
      return partie.id!;
    } on SeatBusyException catch (error) {
      // Une autre partie a démarré entre `ensureNotInGame` et ici.
      throw GameException(
        reason: EnumGameError.alreadyInGame,
        partieId: error.partieId,
      );
    }
  }
}
