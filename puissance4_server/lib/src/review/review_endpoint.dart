import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../generated/protocol.dart';
import 'move_prompt.dart';
import 'review_config.dart';

/// Revue de partie post-match (E14, US14.3) : explication en langage naturel
/// du coup recommandé par l'Expert, générée par un LLM (Ollama cloud) depuis
/// le serveur — la clé API ne quitte jamais le serveur.
class ReviewEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static const languages = {'fr', 'en'};

  /// Explique le coup d'indice [moveIndex] de [moves] en [language] ("fr"
  /// ou "en"). Le serveur recalcule lui-même le coup recommandé (mêmes
  /// règles et même Expert que l'app) : seuls les coups viennent du client.
  /// Les explications sont gardées par position (`MoveExplanation`) : une
  /// position déjà expliquée ne rappelle pas Ollama.
  ///
  /// Lève [ReviewException] : `invalidMove`, `notConfigured`, `unavailable`,
  /// `rateLimited`.
  Future<String> explainMove(
    Session session, {
    required List<int> moves,
    required int moveIndex,
    required String language,
  }) async {
    if (!languages.contains(language) || !_isPlayable(moves, moveIndex)) {
      throw ReviewException(reason: EnumReviewError.invalidMove);
    }
    final positionKey = moves.sublist(0, moveIndex + 1).join(',');

    final cached = await _find(session, positionKey, language);
    if (cached != null) return cached.explanation;

    final apiKey = ReviewConfig.apiKey(session);
    if (apiKey == null || apiKey.isEmpty) {
      throw ReviewException(reason: EnumReviewError.notConfigured);
    }

    final authUserId = session.authenticated!.authUserId;
    final recent = await MoveExplanation.db.count(
      session,
      where: (t) =>
          t.requestedBy.equals(authUserId) &
          (t.createdAt >
              DateTime.now().toUtc().subtract(const Duration(hours: 1))),
    );
    if (recent >= ReviewConfig.maxGenerationsPerHour) {
      throw ReviewException(reason: EnumReviewError.rateLimited);
    }

    final model = ReviewConfig.model(session);
    final analysis = MoveAnalysis.of(moves, moveIndex);
    final String explanation;
    try {
      explanation = await ReviewConfig.llm.chat(
        apiKey: apiKey,
        model: model,
        system: MovePrompt.system(language),
        user: MovePrompt.user(moves, moveIndex, analysis),
        timeout: ReviewConfig.timeout,
      );
    } on Object catch (e) {
      session.log('Ollama call failed: $e', level: LogLevel.warning);
      throw ReviewException(reason: EnumReviewError.unavailable);
    }

    try {
      await MoveExplanation.db.insertRow(
        session,
        MoveExplanation(
          positionKey: positionKey,
          language: language,
          explanation: explanation,
          model: model,
          requestedBy: authUserId,
        ),
      );
    } on DatabaseException {
      // Même position expliquée entre-temps par une autre requête : on
      // garde la première, pour que tout le monde lise la même.
      final winner = await _find(session, positionKey, language);
      if (winner != null) return winner.explanation;
      rethrow;
    }
    return explanation;
  }

  static Future<MoveExplanation?> _find(
    Session session,
    String positionKey,
    String language,
  ) => MoveExplanation.db.findFirstRow(
    session,
    where: (t) =>
        t.positionKey.equals(positionKey) & t.language.equals(language),
  );

  /// Coups tous valides, et [index] désigne un coup joué avant la fin de la
  /// partie.
  static bool _isPlayable(List<int> moves, int index) {
    if (index < 0 || index >= moves.length) return false;
    final played = <int>[];
    for (final column in moves.take(index + 1)) {
      if (Connect4Rules.outcome(played) != null ||
          !Connect4Rules.isValidMove(played, column)) {
        return false;
      }
      played.add(column);
    }
    return true;
  }
}
