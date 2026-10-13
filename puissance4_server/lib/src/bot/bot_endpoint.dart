import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'bot_networks.dart';

/// Coup d'un bot du mode Normal calculé par le serveur, pour l'app web : le
/// navigateur n'a ni TFLite ni isolate, et y recalculer le réseau figerait
/// l'interface. Sur Android et iOS, le bot reste joué sur le téléphone.
/// Rien n'est enregistré ici : la partie Normal reste celle de l'app.
class BotEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Colonne jouée par le niveau [botId] (`BotLevel.id`) après [moves].
  Future<int> chooseColumn(
    Session session,
    String botId,
    List<int> moves,
  ) async {
    final level = BotLevel.values.where((l) => l.id == botId).firstOrNull;
    if (level == null) {
      throw GameException(reason: EnumGameError.noBotAvailable);
    }
    // Rejouée coup par coup : `outcome` ne regarde que le dernier coup.
    final played = <int>[];
    for (final column in moves) {
      if (Connect4Rules.outcome(played) != null) {
        throw GameException(reason: EnumGameError.gameOver);
      }
      if (!Connect4Rules.isValidMove(played, column)) {
        throw GameException(reason: EnumGameError.invalidMove);
      }
      played.add(column);
    }
    if (Connect4Rules.outcome(played) != null) {
      throw GameException(reason: EnumGameError.gameOver);
    }
    return BotNetworks.chooseColumn(level, played);
  }
}
