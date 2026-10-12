import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:puissance4_rules/puissance4_rules.dart';

/// Joue les bots du Classé avec leurs réseaux RL, recalculés en Dart pur
/// (`ConnectFourNet`) : pas de bibliothèque native à déployer. Les modèles
/// sont ceux de l'app, dans `assets/models/` — dossier que Serverpod Cloud
/// déploie avec le serveur (et que le `Dockerfile` copie), lu par rapport au
/// répertoire de travail.
abstract final class BotNetworks {
  static final _models = <BotLevel, Uint8List>{};

  /// Colonne jouée par [level] après [moves]. Dans un isolate à part : la
  /// recherche de l'Expert (800 inférences) bloquerait sinon tout le serveur
  /// (requêtes et streams).
  static Future<int> chooseColumn(BotLevel level, List<int> moves) async {
    final model = _models[level] ??= await File(
      'assets/models/${level.model}',
    ).readAsBytes();
    return Isolate.run(
      () => NetworkBot(
        level,
        ConnectFourNet.fromTflite(model).evaluate,
      ).chooseColumn(moves),
    );
  }
}
