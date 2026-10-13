import 'dart:typed_data';

import 'package:puissance4_rules/puissance4_rules.dart';

/// Web : pas de TFLite ni d'isolate, le bot du mode Normal y est joué par le
/// serveur (`ServerBotBrain`) — `NetworkBotBrain` n'y sert pas.
Future<int> runNetworkBot(BotLevel level, Uint8List model, List<int> moves) =>
    throw UnsupportedError('Web bots are played by the server');
