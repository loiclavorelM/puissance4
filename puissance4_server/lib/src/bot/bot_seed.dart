import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/bot/bot.dart';

/// Sème les niveaux de bot ([BotLevel], source de vérité partagée avec
/// l'app) dans la table `Bot`, sous leur identifiant fixe : le Classé les
/// joue côté serveur, et les parties (Classé comme Normal) y renvoient.
/// Ré-appliqué (upsert) à chaque démarrage du serveur — modifier
/// `BotLevel` suffit, pas besoin de migration.
///
/// Les anciennes lignes (les bots heuristiques d'avant E5) restent pour
/// l'historique des parties qui y renvoient, mais ne sont plus jouées.
Future<void> seedBots(Session session) async {
  for (final level in BotLevel.values) {
    final id = UuidValue.withValidation(level.id);
    final existing = await Bot.db.findById(session, id);
    if (existing == null) {
      await Bot.db.insertRow(
        session,
        Bot(
          id: id,
          botName: level.name,
          elo: level.elo,
          pathModel: level.model,
          description: _descriptions[level]!,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      existing
        ..botName = level.name
        ..elo = level.elo
        ..pathModel = level.model
        ..description = _descriptions[level]!
        ..updatedAt = DateTime.now();
      await Bot.db.updateRow(session, existing);
    }
  }
}

/// Descriptions en français, comme les noms (traduites dans l'app).
const _descriptions = {
  BotLevel.tresFacile: "Un réseau qui n'a encore rien appris.",
  BotLevel.facile: "Un réseau en tout début d'entraînement.",
  BotLevel.moyen: 'Ne rate ni une victoire ni un blocage.',
  BotLevel.difficile: 'Réfléchit avant chaque coup (100 simulations).',
  BotLevel.expert: 'Le plus fort : 800 simulations par coup.',
};
