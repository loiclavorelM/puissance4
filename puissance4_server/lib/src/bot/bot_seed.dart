import 'package:serverpod/serverpod.dart';

import '../generated/bot/bot.dart';

/// Source de vérité pour les 3 niveaux de bot (E5). Ré-appliquée (upsert) à
/// chaque démarrage du serveur — modifier cette liste suffit, pas besoin de
/// migration ni d'accès direct à la base. Dans le code plutôt que dans un
/// fichier lu au démarrage : le serveur déployé n'est qu'un exécutable
/// compilé, sans les sources de `lib/` à côté.
const botSeeds = [
  (
    name: 'Débutant',
    elo: 800,
    pathModel: 'assets/models/beginner.tflite',
    description: 'Un bot qui débute au Puissance 4.',
  ),
  (
    name: 'Medium',
    elo: 1200,
    pathModel: 'assets/models/medium.tflite',
    description: 'Un bot de niveau intermédiaire.',
  ),
  (
    name: 'Expert',
    elo: 1600,
    pathModel: 'assets/models/expert.tflite',
    description:
        'Le bot le plus fort, entraîné par apprentissage par renforcement.',
  ),
];

/// Upserts the bot levels described in [botSeeds] — called on every server
/// start so that list stays the single source of truth (cf. E5).
Future<void> seedBots(Session session) async {
  for (final seed in botSeeds) {
    final existing = await Bot.db.findFirstRow(
      session,
      where: (t) => t.botName.equals(seed.name),
    );

    if (existing == null) {
      await Bot.db.insertRow(
        session,
        Bot(
          botName: seed.name,
          elo: seed.elo,
          pathModel: seed.pathModel,
          description: seed.description,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      existing
        ..elo = seed.elo
        ..pathModel = seed.pathModel
        ..description = seed.description
        ..updatedAt = DateTime.now();
      await Bot.db.updateRow(session, existing);
    }
  }
}
