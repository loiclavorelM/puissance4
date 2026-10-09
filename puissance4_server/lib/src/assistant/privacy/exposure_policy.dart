import 'package:assistant_contracts/assistant_contracts.dart';

enum Exposure { visible, pseudonymized, hidden }

/// Règle d'un champ de `ai-exposure.json`.
final class FieldRule {
  const FieldRule(
    this.exposure, {
    this.kind,
    this.unlessField,
    this.unlessEquals,
  });

  final Exposure exposure;

  /// Type de jeton (`Player`) d'un champ pseudonymisé.
  final String? kind;

  /// Exception : le champ reste visible quand [unlessField] vaut
  /// [unlessEquals] sur la même ligne (un bot n'est pas une personne).
  final String? unlessField;
  final Object? unlessEquals;
}

/// `contracts/ai-exposure.json` lu une fois : le niveau d'exposition de
/// chaque champ, le dictionnaire et les formats. Les outils n'en savent
/// rien : seul le filtre de l'orchestrateur l'applique.
final class ExposurePolicy {
  ExposurePolicy._({
    required this.fields,
    required this.minLength,
    required this.commonWords,
    required this.formats,
    required this.selfToken,
  });

  factory ExposurePolicy.fromJson(Json json) {
    final dictionary = json.objectOrNull('dictionary')!;
    return ExposurePolicy._(
      fields: {
        for (final MapEntry(:key, :value)
            in json.objectOrNull('fields')!.entries)
          key: _rule((value! as Map).cast()),
      },
      minLength: dictionary.intOrNull('minLength') ?? 3,
      commonWords: dictionary.list('commonWords').cast<String>().toSet(),
      formats: {
        for (final MapEntry(:key, :value)
            in json.objectOrNull('formats')!.entries)
          key: RegExp(value! as String),
      },
      selfToken: json.string('self'),
    );
  }

  static final standard = ExposurePolicy.fromJson(
    AssistantContracts.aiExposure,
  );

  static FieldRule _rule(Json json) {
    final unless = json.objectOrNull('unless');
    return FieldRule(
      Exposure.values.byName(json.string('exposure')),
      kind: json.stringOrNull('kind'),
      unlessField: unless?.stringOrNull('field'),
      unlessEquals: unless?['equals'],
    );
  }

  final Map<String, FieldRule> fields;
  final int minLength;
  final Set<String> commonWords;

  /// Identifiants hors dictionnaire repérés par leur format (codes ami,
  /// codes de salle).
  final Map<String, RegExp> formats;

  /// Jeton du joueur lui-même.
  final String selfToken;
}
