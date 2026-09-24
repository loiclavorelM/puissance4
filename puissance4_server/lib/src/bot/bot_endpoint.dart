import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Liste des bots jouables en mode Normal (E5) — alimentée par
/// `bots_seed.yaml`. Pas de connexion requise : ce n'est pas une donnée
/// personnelle, et un invité local doit pouvoir voir les niveaux proposés.
class BotEndpoint extends Endpoint {
  Future<List<Bot>> getBots(Session session) =>
      Bot.db.find(session, orderBy: (t) => t.elo);
}
