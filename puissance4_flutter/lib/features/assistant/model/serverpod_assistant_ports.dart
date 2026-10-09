import 'dart:convert';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:assistant_ui/assistant_ui.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../client.dart';

/// Les ports de `assistant_ui` branchés sur le client Serverpod (E16). Les
/// endpoints échangent le JSON des contrats ; seule cette couche connaît
/// Serverpod (dans le projet pro : clients REST et SignalR).
class ServerpodDashboardRepository implements DashboardRepository {
  ServerpodDashboardRepository(this._changes);

  /// Nouvelles versions annoncées par `LiveEvent(dashboardChanged)`.
  final Stream<void> _changes;

  @override
  Future<Dashboard> load() async => _decode(await client.dashboard.get());

  @override
  Stream<void> changes() => _changes;

  @override
  Future<Dashboard> saveWidget(WidgetDefinition definition) async => _decode(
    await client.dashboard.saveWidget(jsonEncode(definition.toJson())),
  );

  @override
  Future<Dashboard> removeWidget(String id) async =>
      _decode(await client.dashboard.removeWidget(id));

  @override
  Future<Dashboard?> undo() async {
    try {
      return _decode(await client.dashboard.undo());
    } on AssistantException catch (e) {
      if (e.reason == EnumAssistantError.nothingToUndo) return null;
      rethrow;
    }
  }

  @override
  Future<Dashboard> setFilters(DashboardFilters filters) async => _decode(
    await client.dashboard.setFilters(
      jsonEncode(filters.toJson(withLabel: false)),
    ),
  );

  static Dashboard _decode(String json) =>
      Dashboard.fromJson((jsonDecode(json) as Map).cast());
}

class ServerpodDataSourceClient implements DataSourceClient {
  ServerpodDataSourceClient(this._changes);

  /// Fin de partie (serveur ou Normal synchronisée).
  final Stream<void> _changes;

  @override
  Future<SourceData> query(String source, Map<String, Object?> params) async =>
      SourceData.fromJson(
        (jsonDecode(await client.data.query(source, jsonEncode(params))) as Map)
            .cast(),
      );

  @override
  Stream<void> dataChanged() => _changes;

  @override
  Future<List<MentionSuggestion>> searchMentions(String text) async => [
    for (final raw
        in jsonDecode(await client.data.searchMentions(text)) as List)
      MentionSuggestion(
        Mention.fromJson((raw as Map).cast()),
        isBot: raw['kind'] == 'bot',
      ),
  ];
}
