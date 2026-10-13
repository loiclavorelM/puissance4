import 'package:flutter/services.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

import 'network_runner.dart';

/// IA d'un bot du mode Normal : une position → une colonne.
abstract interface class BotBrain {
  Future<int> chooseColumn(List<int> moves);
}

/// Niveau du mode Normal joué par son réseau RL embarqué
/// (`assets/models/`), sans réseau ni serveur : TFLite sur Android et iOS,
/// le même réseau recalculé en Dart (`ConnectFourNet`) sur ordinateur. Sur
/// le web, c'est `ServerBotBrain` qui joue.
class NetworkBotBrain implements BotBrain {
  NetworkBotBrain(this.level, {AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final BotLevel level;
  final AssetBundle _bundle;
  Future<Uint8List>? _model;

  @override
  Future<int> chooseColumn(List<int> moves) async {
    final model = await (_model ??= _load());
    return runNetworkBot(level, model, List<int>.of(moves));
  }

  Future<Uint8List> _load() async {
    final data = await _bundle.load('assets/models/${level.model}');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
