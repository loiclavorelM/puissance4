import '../../../client.dart';

/// Explication d'un coup par le LLM du serveur (E14, US14.3) — la clé API
/// Ollama reste sur le serveur.
class ReviewRepository {
  /// Lève `ReviewException` (refus du serveur) ou une erreur réseau.
  Future<String> explainMove(
    List<int> moves,
    int moveIndex, {
    required String language,
  }) => client.review.explainMove(
    moves: moves,
    moveIndex: moveIndex,
    language: language,
  );
}
