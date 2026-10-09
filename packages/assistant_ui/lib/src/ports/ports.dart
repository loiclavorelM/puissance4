import 'package:assistant_contracts/assistant_contracts.dart';

/// Le tableau de bord du joueur, côté serveur. L'app fournit
/// l'implémentation (ici Serverpod ; REST + SignalR dans le projet pro).
abstract interface class DashboardRepository {
  Future<Dashboard> load();

  /// Une nouvelle version est disponible (écrite par l'assistant ou depuis
  /// un autre appareil).
  Stream<void> changes();

  /// Ajoute (sans id : « Épingler ») ou remplace (panneau « Modifier »).
  Future<Dashboard> saveWidget(WidgetDefinition definition);

  Future<Dashboard> removeWidget(String id);

  /// `null` s'il n'y a rien à annuler.
  Future<Dashboard?> undo();

  Future<Dashboard> setFilters(DashboardFilters filters);
}

/// Une suggestion de l'autocomplétion du chat.
final class MentionSuggestion {
  const MentionSuggestion(this.mention, {required this.isBot});

  final Mention mention;
  final bool isBot;
}

/// Les données des widgets, chargées sans passer par le LLM.
abstract interface class DataSourceClient {
  /// [params] déjà résolus (aucun `$dashboard.xxx`).
  Future<SourceData> query(String source, Map<String, Object?> params);

  /// Les données de jeu ont changé (fin de partie, synchronisation).
  Stream<void> dataChanged();

  Future<List<MentionSuggestion>> searchMentions(String text);
}

/// La conversation avec l'assistant.
abstract interface class AssistantClient {
  /// Envoie [input] dans [conversationId] (`null` = nouvelle conversation,
  /// dont l'id arrive dans `StartedEvent`).
  Stream<AssistantEvent> send(String? conversationId, ChatInput input);
}
