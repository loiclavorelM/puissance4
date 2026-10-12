import 'package:serverpod/serverpod.dart';

import '../review/review_config.dart';
import 'orchestrator/chat_model.dart';
import 'orchestrator/ollama_chat_model.dart';

/// Réglages de l'assistant (E16), en un seul endroit. La clé Ollama est
/// celle de la revue de partie (`ollamaApiKey`), jamais côté client.
abstract final class AssistantConfig {
  /// Mot de passe optionnel pour changer de modèle sans redéployer.
  static const modelPassword = 'assistantModel';

  /// Allers-retours avec le LLM au plus par demande.
  static int maxTurns = 6;

  /// Demandes par joueur et par heure.
  static int maxRequestsPerHour = 30;

  /// Messages d'historique renvoyés au LLM au plus.
  static int historyMessages = 40;

  static Duration timeout = const Duration(seconds: 60);

  /// Remplacé dans les tests (pas d'appel réseau).
  static ChatModel Function(String apiKey) chatModel = (apiKey) =>
      OllamaChatModel(apiKey: apiKey, timeout: timeout);

  static String? apiKey(Session session) => ReviewConfig.apiKey(session);

  /// Remplaçable (comparaison de modèles dans les évals).
  static String Function(Session session) model = (session) =>
      session.passwords[modelPassword] ?? ReviewConfig.model(session);

  /// Remplacé dans les tests (date du contexte).
  static DateTime Function() now = DateTime.now;
}
