import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

/// Un adversaire désigné de façon stable : `user:<uuid>` ou `bot:<uuid>`.
typedef OpponentRef = String;

/// Résolution des adversaires entre ce qu'écrivent les clients et une
/// référence stable.
abstract final class Opponents {
  static final _ref = RegExp(r'^(user|bot):([0-9a-f-]{36})$');

  /// Référence de [value] : une référence déjà formée, un nom de bot ou un
  /// pseudo (insensible à la casse). `null` si personne ne correspond.
  static Future<OpponentRef?> resolve(Session session, String value) async {
    final trimmed = value.trim();
    if (_ref.hasMatch(trimmed)) return trimmed;
    final lower = trimmed.toLowerCase();
    // Les niveaux actuels d'abord : d'anciens bots (heuristiques, avant E5)
    // portent encore le même nom, comme « Expert ».
    for (final level in BotLevel.values) {
      if (level.name.toLowerCase() == lower) return 'bot:${level.id}';
    }
    final bots = await Bot.db.find(session);
    for (final bot in bots) {
      if (bot.botName.toLowerCase() == lower) return 'bot:${bot.id}';
    }
    final users = await User.db.find(
      session,
      // Égalité insensible à la casse : on neutralise les jokers de ILIKE.
      where: (t) => t.username.ilike(
        trimmed.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}'),
      ),
      limit: 1,
    );
    return users.isEmpty ? null : 'user:${users.single.id}';
  }

  /// Nom affiché de [ref], ou `null` s'il n'existe plus.
  static Future<String?> label(Session session, OpponentRef ref) async {
    final match = _ref.firstMatch(ref);
    if (match == null) return null;
    final id = UuidValue.withValidation(match.group(2)!);
    return match.group(1) == 'bot'
        ? (await Bot.db.findById(session, id))?.botName
        : (await User.db.findById(session, id))?.username;
  }
}
