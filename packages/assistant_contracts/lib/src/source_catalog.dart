import 'json.dart';
import 'source_data.dart';

/// Texte en français et en anglais (libellés des contrats).
final class LocalizedText {
  const LocalizedText(this.fr, this.en);

  factory LocalizedText.fromJson(Json json) =>
      LocalizedText(json.string('fr'), json.string('en'));

  final String fr;
  final String en;

  String of(String language) => language == 'en' ? en : fr;
}

enum ParamType { enumeration, integer, opponent }

/// Un paramètre de source (`sources.json` → `params`).
final class ParamSpec {
  const ParamSpec({
    required this.name,
    required this.type,
    required this.description,
    required this.label,
    this.values = const [],
    this.min,
    this.max,
    this.defaultValue,
  });

  factory ParamSpec.fromJson(String name, Json json) => ParamSpec(
    name: name,
    type: switch (json.string('type')) {
      'enum' => ParamType.enumeration,
      'integer' => ParamType.integer,
      _ => ParamType.opponent,
    },
    description: json.string('description'),
    label: LocalizedText.fromJson(json.objectOrNull('label')!),
    values: json.list('values').cast<String>(),
    min: json.intOrNull('min'),
    max: json.intOrNull('max'),
    defaultValue: json.stringOrNull('default'),
  );

  final String name;
  final ParamType type;
  final String description;
  final LocalizedText label;
  final List<String> values;
  final int? min;
  final int? max;

  /// Valeur prise quand le paramètre est absent (`null` : aucune).
  final String? defaultValue;

  /// Message d'erreur si [value] ne convient pas, sinon `null`.
  String? check(Object? value) => switch (type) {
    ParamType.enumeration when value is! String || !values.contains(value) =>
      '$name must be one of ${values.join(', ')}.',
    ParamType.integer
        when value is! int ||
            (min != null && value < min!) ||
            (max != null && value > max!) =>
      '$name must be an integer from $min to $max.',
    ParamType.opponent when value is! String || value.trim().isEmpty =>
      '$name must be a non-empty string.',
    _ => null,
  };
}

/// Un champ de données (`sources.json` → `fields`).
final class FieldSpec {
  const FieldSpec({
    required this.name,
    required this.type,
    required this.label,
    this.valueLabels = const {},
    this.valueColors = const {},
    this.internal = false,
  });

  factory FieldSpec.fromJson(String name, Json json) => FieldSpec(
    name: name,
    type: FieldType.values.byName(json.string('type')),
    label: LocalizedText.fromJson(json.objectOrNull('label')!),
    valueLabels: {
      for (final MapEntry(:key, :value)
          in (json.objectOrNull('values') ?? const {}).entries)
        key: LocalizedText.fromJson((value! as Map).cast()),
    },
    valueColors: (json.objectOrNull('colors') ?? const {}).cast(),
    internal: json.boolOrNull('internal') ?? false,
  );

  final String name;
  final FieldType type;
  final LocalizedText label;

  /// Libellés des valeurs d'une catégorie (`win` → Victoire).
  final Map<String, LocalizedText> valueLabels;

  /// Jeton de thème par valeur (`win` → `success`).
  final Map<String, String> valueColors;

  /// Champ technique (référence, id) : jamais un axe de graphique.
  final bool internal;

  String valueLabel(Object? value, String language) =>
      valueLabels[value]?.of(language) ?? '${value ?? ''}';
}

/// Graphique par défaut d'une source.
final class DefaultChart {
  const DefaultChart({
    required this.mark,
    this.x,
    this.y,
    this.value,
    this.color,
    this.stack = false,
    this.horizontal = false,
  });

  factory DefaultChart.fromJson(Json json) => DefaultChart(
    mark: json.string('mark'),
    x: json.stringOrNull('x'),
    y: json.stringOrNull('y'),
    value: json.stringOrNull('value'),
    color: json.stringOrNull('color'),
    stack: json.boolOrNull('stack') ?? false,
    horizontal: json.boolOrNull('horizontal') ?? false,
  );

  final String mark;
  final String? x;
  final String? y;
  final String? value;
  final String? color;
  final bool stack;
  final bool horizontal;

  /// Paramètres dont un axe reprend la valeur (`"x": "$groupBy"`).
  Set<String> get params => {
    for (final axis in [x, y, value, color])
      if (axis != null && axis.startsWith(r'$')) axis.substring(1),
  };
}

enum SourceKind { kpi, rows }

final class SourceSpec {
  const SourceSpec({
    required this.key,
    required this.kind,
    required this.label,
    required this.description,
    required this.params,
    this.fields = const [],
    this.fieldParams = const [],
    this.companions = const {},
    this.defaultChart,
    this.live = false,
  });

  final String key;
  final SourceKind kind;
  final LocalizedText label;
  final String description;
  final List<String> params;

  /// Tous les champs que la source peut renvoyer.
  final List<String> fields;

  /// Source à champs choisis (tableau croisé) : paramètres dont la valeur
  /// est un champ renvoyé, dans cet ordre (`SourceCatalog.outputFields`).
  final List<String> fieldParams;

  /// Champs ajoutés avec un champ choisi (`opponent` → `opponentKind`,
  /// `opponentRef`).
  final Map<String, List<String>> companions;
  final DefaultChart? defaultChart;

  /// Données qui changent à la fin d'une partie.
  final bool live;
}

/// Catalogue des sources (`contracts/sources.json`) : la seule liste des
/// sources, de leurs champs et de leurs paramètres, lue par le serveur
/// (outils, validation) et par l'app (libellés, panneau « Modifier »).
final class SourceCatalog {
  SourceCatalog._(this.params, this.fields, this.sources, this.dashboardParams);

  factory SourceCatalog.fromJson(Json json) {
    final params = {
      for (final MapEntry(:key, :value) in json.objectOrNull('params')!.entries)
        key: ParamSpec.fromJson(key, (value! as Map).cast()),
    };
    final fields = {
      for (final MapEntry(:key, :value) in json.objectOrNull('fields')!.entries)
        key: FieldSpec.fromJson(key, (value! as Map).cast()),
    };
    final sources = <String, SourceSpec>{};
    for (final raw in json.list('sources')) {
      final source = (raw! as Map).cast<String, Object?>();
      final chart = source.objectOrNull('defaultChart');
      final spec = SourceSpec(
        key: source.string('key'),
        kind: SourceKind.values.byName(source.string('kind')),
        label: LocalizedText.fromJson(source.objectOrNull('label')!),
        description: source.string('description'),
        params: source.list('params').cast<String>(),
        fields: source.list('fields').cast<String>(),
        fieldParams: source.list('fieldParams').cast<String>(),
        companions: {
          for (final MapEntry(:key, :value)
              in (source.objectOrNull('companions') ?? const {}).entries)
            key: (value! as List).cast<String>(),
        },
        defaultChart: chart == null ? null : DefaultChart.fromJson(chart),
        live: source.boolOrNull('live') ?? false,
      );
      sources[spec.key] = spec;
    }
    return SourceCatalog._(
      params,
      fields,
      sources,
      json.list('dashboardParams').cast<String>(),
    );
  }

  final Map<String, ParamSpec> params;
  final Map<String, FieldSpec> fields;
  final Map<String, SourceSpec> sources;

  /// Paramètres que les filtres du tableau de bord peuvent fournir.
  final List<String> dashboardParams;

  SourceSpec? operator [](String key) => sources[key];

  List<FieldSpec> fieldsOf(SourceSpec source) => [
    for (final name in source.fields) fields[name]!,
  ];

  /// Valeur de [name] dans [params], ou sa valeur par défaut.
  String? paramValue(String name, Map<String, Object?> params) =>
      switch (params[name]) {
        final String value when !value.startsWith(dashboardPrefix) => value,
        _ => this.params[name]?.defaultValue,
      };

  /// Champs que [source] renvoie pour [params] : ses champs fixes, ou pour
  /// un tableau croisé les champs choisis ([SourceSpec.fieldParams]) et
  /// leurs compagnons.
  List<String> outputFields(SourceSpec source, Map<String, Object?> params) {
    if (source.fieldParams.isEmpty) return source.fields;
    final output = <String>[];
    final internal = <String>[];
    for (final param in source.fieldParams) {
      final field = paramValue(param, params);
      if (field == null || output.contains(field)) continue;
      output.add(field);
      for (final companion in source.companions[field] ?? const <String>[]) {
        if (output.contains(companion) || internal.contains(companion)) {
          continue;
        }
        (fields[companion]!.internal ? internal : output).add(companion);
      }
    }
    return [...output, ...internal];
  }

  /// Erreurs sur [params] pour [source] (paramètres inconnus ou invalides).
  /// Les valeurs `$dashboard.xxx` sont acceptées telles quelles.
  List<String> checkParams(SourceSpec source, Map<String, Object?> params) {
    final errors = <String>[];
    for (final MapEntry(:key, :value) in params.entries) {
      if (!source.params.contains(key)) {
        errors.add(
          '${source.key} has no parameter $key '
          '(parameters: ${source.params.join(', ')}).',
        );
      } else if (value is String && value.startsWith(dashboardPrefix)) {
        if (value != '$dashboardPrefix$key' || !dashboardParams.contains(key)) {
          errors.add(
            '$key: only "$dashboardPrefix$key" can refer to the dashboard.',
          );
        }
      } else if (this.params[key]!.check(value) case final error?) {
        errors.add(error);
      }
    }
    // Tableau croisé : deux dimensions identiques ne croisent rien.
    final chosen = [
      for (final param in source.fieldParams)
        if (paramValue(param, params) case final value?) (param, value),
    ];
    for (var i = 0; i < chosen.length; i++) {
      for (var j = i + 1; j < chosen.length; j++) {
        if (chosen[i].$2 == chosen[j].$2) {
          errors.add('${chosen[j].$1} must differ from ${chosen[i].$1}.');
        }
      }
    }
    return errors;
  }

  /// Résumé compact pour `list_data_sources` (ce que voit le LLM).
  Json describe() => {
    'sources': [
      for (final source in sources.values)
        compact({
          'key': source.key,
          'kind': source.kind.name,
          'description': source.description,
          if (source.fields.isNotEmpty)
            'fields': {
              for (final field in fieldsOf(source))
                if (!field.internal) field.name: field.type.name,
            },
          'params': source.params,
          if (source.fieldParams.isNotEmpty) 'fieldsFrom': source.fieldParams,
          if (source.defaultChart case final chart?)
            'defaultChart': compact({
              'mark': chart.mark,
              'x': chart.x,
              'y': chart.y,
              'value': chart.value,
              'color': chart.color,
              if (chart.stack) 'stack': true,
              if (chart.horizontal) 'horizontal': true,
            }),
        }),
    ],
    'params': {
      for (final param in params.values)
        param.name: compact({
          'description': param.description,
          if (param.values.isNotEmpty) 'values': param.values,
          'default': param.defaultValue,
          'min': param.min,
          'max': param.max,
        }),
    },
  };
}

/// Préfixe d'une valeur de paramètre reprise des filtres du tableau de bord.
const dashboardPrefix = r'$dashboard.';
