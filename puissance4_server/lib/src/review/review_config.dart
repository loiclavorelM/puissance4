import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../assistant/orchestrator/chat_model.dart';
import '../assistant/orchestrator/ollama_chat_model.dart';

/// Réglages de la revue de partie par LLM (E14), en un seul endroit.
///
/// La clé API vient de `config/passwords.yaml` (`ollamaApiKey`) — en
/// production, un secret Serverpod Cloud
/// (`scloud password set ollamaApiKey <clé>`). Jamais côté client, jamais
/// commitée.
abstract final class ReviewConfig {
  static const apiKeyPassword = 'ollamaApiKey';

  /// Mot de passe optionnel pour changer de modèle sans redéployer le code.
  static const modelPassword = 'ollamaModel';
  static const defaultModel = 'gpt-oss:120b';

  /// Explications générées (hors cache) par joueur et par heure.
  static int maxGenerationsPerHour = 30;

  static Duration timeout = const Duration(seconds: 30);

  /// Remplacé dans les tests (pas d'appel réseau).
  static LlmClient llm = OllamaCloudClient();

  /// Clé API Ollama ; `null` si le serveur n'en a pas (fonction désactivée).
  static String? Function(Session session) apiKey = (session) =>
      session.passwords[apiKeyPassword];

  static String model(Session session) =>
      session.passwords[modelPassword] ?? defaultModel;
}

/// Un appel de chat à un LLM : un prompt système + un message → la réponse.
abstract interface class LlmClient {
  Future<String> chat({
    required String apiKey,
    required String model,
    required String system,
    required String user,
    required Duration timeout,
  });
}

/// API chat d'Ollama cloud, par le même client que l'assistant (E16) :
/// un seul code d'appel à Ollama dans le serveur.
class OllamaCloudClient implements LlmClient {
  OllamaCloudClient({this.endpoint});

  /// `null` : Ollama Cloud.
  final Uri? endpoint;

  @override
  Future<String> chat({
    required String apiKey,
    required String model,
    required String system,
    required String user,
    required Duration timeout,
  }) async {
    final response =
        await OllamaChatModel(
          apiKey: apiKey,
          timeout: timeout,
          endpoint: endpoint,
        ).getResponse([
          ChatMessage.system(system),
          ChatMessage.user(user),
        ], ChatOptions(model: model));
    final content = response.message.content;
    if (content.isEmpty) throw const FormatException('Empty Ollama answer');
    return content;
  }
}
