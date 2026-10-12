import 'dart:convert';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

/// Contexte d'un appel d'outil : qui appelle, et avec quelle session.
/// L'identité vient de la connexion MCP, **jamais d'un argument**.
final class ToolContext {
  const ToolContext(this.session, this.user);

  final Session session;
  final User user;
}

/// Résultat d'un outil : un texte JSON pour le LLM, et ce que
/// l'orchestrateur doit en faire (nouvelle version, bloc pour le chat).
final class ToolOutcome {
  const ToolOutcome(this.result, {this.dashboardVersion, this.block});

  /// Erreur actionnable : le message dit au LLM quoi corriger.
  ToolOutcome.error(String message)
    : result = {'error': message},
      dashboardVersion = null,
      block = null;

  final Json result;
  final int? dashboardVersion;

  /// Widget à montrer dans le chat (`propose_widget`).
  final WidgetDefinition? block;

  bool get isError => result.containsKey('error');

  String get text => jsonEncode(result);
}

/// Argument invalide détecté au fond d'un outil : devient un
/// [ToolOutcome.error].
final class ToolError implements Exception {
  const ToolError(this.message);
  final String message;

  @override
  String toString() => message;
}

typedef ToolHandler =
    Future<ToolOutcome> Function(ToolContext context, Json args);
