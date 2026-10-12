import 'dart:convert';

import 'chart_rules.dart';
import 'generated/contracts.g.dart' as generated;
import 'json.dart';
import 'source_catalog.dart';

/// Un outil MCP tel que décrit dans `contracts/tools/<nom>.json`.
final class ToolContract {
  const ToolContract({
    required this.name,
    required this.title,
    required this.description,
    required this.annotations,
    required this.inputSchema,
  });

  factory ToolContract.fromJson(Json json) => ToolContract(
    name: json.string('name'),
    title: json.string('title'),
    description: json.string('description'),
    annotations: json.objectOrNull('annotations')!.cast<String, bool>(),
    inputSchema: json.objectOrNull('inputSchema')!,
  );

  final String name;
  final String title;
  final String description;

  /// `readOnlyHint`, `destructiveHint`, `idempotentHint`, `openWorldHint`.
  final Map<String, bool> annotations;
  final Json inputSchema;
}

/// Accès aux contrats embarqués (générés depuis `contracts/`).
abstract final class AssistantContracts {
  static final SourceCatalog catalog = SourceCatalog.fromJson(
    _decode(generated.sourcesJson),
  );

  static final ChartRules chartRules = ChartRules.fromJson(
    _decode(generated.chartRulesJson),
  );

  static final List<ToolContract> tools = [
    for (final json in generated.toolsJson.values)
      ToolContract.fromJson(_decode(json)),
  ];

  static ToolContract tool(String name) =>
      tools.firstWhere((tool) => tool.name == name);

  static Json get aiExposure => _decode(generated.aiExposureJson);

  static String get systemPrompt => generated.systemPrompt;

  static String get evalsYaml => generated.evalsYaml;

  static Json schema(String name) => _decode(generated.schemasJson[name]!);

  /// Fixture `contracts/fixtures/<name>.json`, décodée.
  static Json fixture(String name) => _decode(generated.fixturesJson[name]!);

  static Iterable<String> get fixtureNames => generated.fixturesJson.keys;

  static Json _decode(String json) => (jsonDecode(json) as Map).cast();
}
