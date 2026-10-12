/// Les bots du jeu (E5) : des réseaux entraînés par self-play
/// (`rl_training/`), exportés en `.tflite`. Mêmes réglages que `LEVELS` dans
/// le notebook (section 7) : un niveau = un snapshot plus ou moins entraîné,
/// un nombre de simulations MCTS et une température.
///
/// - Normal : l'app embarque les modèles et joue hors ligne — pas de liste à
///   demander au serveur.
/// - Classé : le serveur joue le niveau le plus proche de l'Elo du joueur
///   ([forElo]) avec les mêmes modèles, et sème ces niveaux dans sa table
///   `Bot` (mêmes [id]).
enum BotLevel {
  tresFacile(
    id: '6953cd40-a9c1-443b-ae38-d4efc714fd49',
    name: 'Très facile',
    elo: 400,
    model: 'connect4_it000.tflite',
    simulations: 0,
    temperature: 1,
    guarded: false,
  ),
  facile(
    id: '320abf33-683c-45bd-921f-3c2eded844cb',
    name: 'Facile',
    elo: 700,
    model: 'connect4_it005.tflite',
    simulations: 0,
    temperature: 1,
    guarded: false,
  ),
  moyen(
    id: '69537d8b-de74-41d5-bb44-eb35f61a80c2',
    name: 'Moyen',
    elo: 1100,
    model: 'connect4_it025.tflite',
    simulations: 0,
    temperature: 0,
    guarded: true,
  ),
  difficile(
    id: '5c251efc-516c-4e27-8118-ab907d3af728',
    name: 'Difficile',
    elo: 1500,
    model: 'connect4_it050.tflite',
    simulations: 100,
    temperature: 0,
    guarded: true,
  ),
  expert(
    id: '552baea5-958d-4752-9571-fd31fa61a4a9',
    name: 'Expert',
    elo: 1900,
    model: 'connect4_it100.tflite',
    simulations: 800,
    temperature: 0,
    guarded: true,
  );

  const BotLevel({
    required this.id,
    required this.name,
    required this.elo,
    required this.model,
    required this.simulations,
    required this.temperature,
    required this.guarded,
  });

  /// Identifiant stable : celui de la ligne `Bot` du serveur, et celui gardé
  /// dans `OfflineMatchResult.botId` pour une partie Normal.
  final String id;

  /// Nom en français, comme ceux des bots du serveur (traduit dans l'app).
  final String name;

  /// Elo virtuel, affiché et pris en compte dans le calcul de l'Elo du
  /// Classé : une estimation d'après les matchs du notebook, pas une mesure.
  final int elo;

  /// Fichier du modèle, dans `assets/models/` de l'app et du serveur.
  final String model;

  /// Simulations MCTS par coup — 0 : le réseau seul, une inférence par coup.
  final int simulations;

  /// 0 : toujours le meilleur coup ; 1 : tiré selon les probabilités du
  /// réseau, donc des erreurs.
  final double temperature;

  /// Gagne, bloque et n'offre pas la victoire avant de suivre le réseau
  /// (`TacticalGuard`) — pas pour les niveaux faciles, censés en rater.
  final bool guarded;

  /// Adversaire du Classé : le niveau dont l'Elo est le plus proche de
  /// [elo] (le moins fort à égalité).
  static BotLevel forElo(int elo) => values.reduce(
    (best, bot) => (bot.elo - elo).abs() < (best.elo - elo).abs() ? bot : best,
  );

  static BotLevel? byId(String id) {
    for (final bot in values) {
      if (bot.id == id) return bot;
    }
    return null;
  }
}
