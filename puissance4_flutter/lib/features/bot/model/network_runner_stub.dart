import 'dart:typed_data';

import 'package:puissance4_rules/puissance4_rules.dart';

/// Web : pas de TFLite ni d'isolate, le réseau en Dart tourne sur le thread
/// de l'interface — d'où une réflexion bornée (l'Expert y fait moins que ses
/// 800 simulations).
Future<int> runNetworkBot(BotLevel level, Uint8List model, List<int> moves) {
  final net = _nets[level] ??= ConnectFourNet.fromTflite(model);
  return Future.value(
    NetworkBot(
      level,
      net.evaluate,
      maxThinkingTime: const Duration(seconds: 2),
    ).chooseColumn(moves),
  );
}

final _nets = <BotLevel, ConnectFourNet>{};
