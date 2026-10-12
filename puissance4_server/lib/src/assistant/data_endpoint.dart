import 'dart:convert';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:serverpod/serverpod.dart';

import '../game/server_game.dart';
import '../generated/protocol.dart';
import 'sources/data_sources.dart';
import 'sources/game_record_repository.dart';

/// Données des widgets du tableau de bord (E16) : l'app les charge elle-même,
/// avec les vraies valeurs — elles ne passent jamais par le LLM.
///
/// Entrées et sorties en JSON des contrats (`data.schema.json`) plutôt qu'en
/// classes Serverpod, pour rester transposables.
class DataEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Interroge [source] avec [paramsJson] (objet JSON, `$dashboard.xxx` déjà
  /// résolus par l'app). Renvoie un `SourceData` en JSON.
  ///
  /// Lève [AssistantException] (`invalidQuery`) si la source ou les
  /// paramètres sont invalides.
  Future<String> query(
    Session session,
    String source,
    String paramsJson,
  ) async {
    final user = await ServerGame.requireUser(session);
    final Map<String, Object?> params;
    try {
      params = (jsonDecode(paramsJson) as Map).cast();
    } on Object {
      throw AssistantException(
        reason: EnumAssistantError.invalidQuery,
        message: 'paramsJson must be a JSON object.',
      );
    }
    try {
      final data = await DataSources.query(session, user, source, params);
      return jsonEncode(data.toJson());
    } on SourceQueryException catch (e) {
      throw AssistantException(
        reason: EnumAssistantError.invalidQuery,
        message: e.message,
      );
    }
  }

  /// Autocomplétion des mentions du chat : les adversaires du joueur dont le
  /// nom contient [text] (8 au plus). Renvoie une liste de `Mention` en JSON
  /// (`ref`, `label`) avec `kind` (`bot` ou `human`).
  Future<String> searchMentions(Session session, String text) async {
    final user = await ServerGame.requireUser(session);
    final needle = text.trim().toLowerCase();
    final games = await GameRecordRepository.load(session, user);
    final seen = <String>{};
    final mentions = <Json>[];
    for (final game in games) {
      if (mentions.length >= 8) break;
      if (!seen.add(game.opponentRef)) continue;
      if (!game.opponentName.toLowerCase().contains(needle)) continue;
      mentions.add({
        ...Mention(ref: game.opponentRef, label: game.opponentName).toJson(),
        'kind': game.opponentKind.name,
      });
    }
    return jsonEncode(mentions);
  }
}
