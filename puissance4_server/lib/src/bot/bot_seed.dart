import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:yaml/yaml.dart';

import '../generated/bot/bot.dart';

/// Upserts the bot levels described in `bots_seed.yaml` — called on every
/// server start so that file stays the single source of truth (cf. E5).
Future<void> seedBots(Session session) async {
  final file = File(Uri(path: 'lib/src/bot/bots_seed.yaml').toFilePath());
  final entries = loadYaml(await file.readAsString()) as YamlList;

  for (final entry in entries) {
    final botName = entry['name'] as String;
    final elo = entry['elo'] as int;
    final pathModel = entry['pathModel'] as String;
    final description = entry['description'] as String;

    final existing = await Bot.db.findFirstRow(
      session,
      where: (t) => t.botName.equals(botName),
    );

    if (existing == null) {
      await Bot.db.insertRow(
        session,
        Bot(
          botName: botName,
          elo: elo,
          pathModel: pathModel,
          description: description,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      existing
        ..elo = elo
        ..pathModel = pathModel
        ..description = description
        ..updatedAt = DateTime.now();
      await Bot.db.updateRow(session, existing);
    }
  }
}
