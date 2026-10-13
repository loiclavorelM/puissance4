import 'package:puissance4_rules/puissance4_rules.dart';

import '../../../client.dart';
import 'bot_brain.dart';

/// Niveau du mode Normal joué par le serveur (`BotEndpoint`) : utilisé sur
/// le web, où le navigateur n'a ni TFLite ni isolate pour faire tourner le
/// réseau sans figer l'interface. Demande donc une connexion au serveur.
class ServerBotBrain implements BotBrain {
  ServerBotBrain(this.level);

  final BotLevel level;

  @override
  Future<int> chooseColumn(List<int> moves) =>
      client.bot.chooseColumn(level.id, List<int>.of(moves));
}
