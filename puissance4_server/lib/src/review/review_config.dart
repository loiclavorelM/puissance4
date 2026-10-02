import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

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

/// API chat d'Ollama cloud (`POST https://ollama.com/api/chat`).
class OllamaCloudClient implements LlmClient {
  OllamaCloudClient({Uri? endpoint})
    : _endpoint = endpoint ?? Uri.parse('https://ollama.com/api/chat');

  final Uri _endpoint;

  @override
  Future<String> chat({
    required String apiKey,
    required String model,
    required String system,
    required String user,
    required Duration timeout,
  }) async {
    final http = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await http.postUrl(_endpoint);
      request.headers
        ..contentType = ContentType.json
        ..set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
      request.write(
        jsonEncode({
          'model': model,
          'stream': false,
          'messages': [
            {'role': 'system', 'content': system},
            {'role': 'user', 'content': user},
          ],
        }),
      );
      final response = await request.close().timeout(timeout);
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout);
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Ollama ${response.statusCode}: $body');
      }
      final content =
          ((jsonDecode(body) as Map<String, dynamic>)['message']
                  as Map<String, dynamic>?)?['content']
              as String?;
      if (content == null || content.trim().isEmpty) {
        throw const FormatException('Empty Ollama answer');
      }
      return content.trim();
    } finally {
      http.close(force: true);
    }
  }
}
