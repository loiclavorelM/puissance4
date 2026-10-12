import 'dart:convert';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:serverpod/serverpod.dart';

import '../game/server_game.dart';
import 'orchestrator/orchestrator.dart';

/// L'assistant (E16) : une méthode en stream qui renvoie les événements de
/// `contracts/assistant-events.schema.json`, un objet JSON par message. La
/// clé du LLM ne quitte jamais le serveur.
class AssistantEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Envoie [inputJson] (`ChatInput` : texte, langue, mentions) dans
  /// [conversationId], ou dans une nouvelle conversation si `null` — son id
  /// arrive dans le premier événement (`started`).
  Stream<String> chat(
    Session session,
    String? conversationId,
    String inputJson,
  ) async* {
    final user = await ServerGame.requireUser(session);
    final ChatInput input;
    try {
      input = ChatInput.fromJson((jsonDecode(inputJson) as Map).cast());
    } on Object {
      yield jsonEncode(
        const ErrorEvent(AssistantErrorCode.invalidInput).toJson(),
      );
      return;
    }
    await for (final event in AssistantOrchestrator(
      session,
      user,
    ).chat(conversationId, input)) {
      yield jsonEncode(event.toJson());
    }
  }
}
