import 'json.dart';

enum FieldType { temporal, category, number }

/// Réponse d'une source (`contracts/data.schema.json`).
sealed class SourceData {
  const SourceData();

  factory SourceData.fromJson(Json json) => switch (json.string('kind')) {
    'kpi' => KpiData.fromJson(json),
    _ => DataSet.fromJson(json),
  };

  Json toJson();
}

/// Un chiffre clé. [value] est `null` quand il n'y a rien à mesurer (aucune
/// partie) : l'app affiche alors un état vide plutôt qu'un 0 trompeur.
final class KpiData extends SourceData {
  const KpiData({required this.value, this.unit, this.delta, this.secondary});

  factory KpiData.fromJson(Json json) => KpiData(
    value: json['value'] as num?,
    unit: json.stringOrNull('unit'),
    delta: json['delta'] as num?,
    secondary: json['secondary'] as num?,
  );

  final num? value;
  final String? unit;

  /// Variation par rapport à la période précédente de même durée.
  final num? delta;

  /// Valeur secondaire (nombre de parties, meilleure série…).
  final num? secondary;

  @override
  Json toJson() => compact({
    'kind': 'kpi',
    'value': value,
    'unit': unit,
    'delta': delta,
    'secondary': secondary,
  })..putIfAbsent('value', () => null);
}

final class DataField {
  const DataField(this.name, this.type);

  factory DataField.fromJson(Json json) => DataField(
    json.string('name'),
    FieldType.values.byName(json.string('type')),
  );

  final String name;
  final FieldType type;

  Json toJson() => {'name': name, 'type': type.name};
}

/// Lignes typées : n'importe quelle source tabulaire peut donner n'importe
/// quel graphique, l'app la répartit en séries selon la spec.
final class DataSet extends SourceData {
  DataSet({required this.fields, required this.rows, this.truncated})
    : assert(rows.length <= maxRows);

  factory DataSet.fromJson(Json json) => DataSet(
    fields: [
      for (final field in json.list('fields'))
        DataField.fromJson((field! as Map).cast()),
    ],
    rows: [
      for (final row in json.list('rows')) List<Object?>.from(row! as List),
    ],
    truncated: json.intOrNull('truncated'),
  );

  /// Plafond par source : au-delà, la source doit agréger davantage.
  static const maxRows = 2000;

  final List<DataField> fields;
  final List<List<Object?>> rows;

  /// Nombre total de lignes quand [rows] a été tronqué.
  final int? truncated;

  int indexOf(String field) => fields.indexWhere((f) => f.name == field);

  DataField? field(String name) =>
      fields.where((f) => f.name == name).firstOrNull;

  Iterable<Object?> column(String field) {
    final index = indexOf(field);
    return index < 0 ? const [] : rows.map((row) => row[index]);
  }

  /// Les [limit] premières lignes, avec le total si c'est tronqué.
  DataSet truncate(int limit) => rows.length <= limit
      ? this
      : DataSet(
          fields: fields,
          rows: rows.take(limit).toList(),
          truncated: rows.length,
        );

  /// Sans les champs [names] (confidentialité, champs internes).
  DataSet without(Set<String> names) {
    final kept = [
      for (var i = 0; i < fields.length; i++)
        if (!names.contains(fields[i].name)) i,
    ];
    return DataSet(
      fields: [for (final i in kept) fields[i]],
      rows: [
        for (final row in rows) [for (final i in kept) row[i]],
      ],
      truncated: truncated,
    );
  }

  @override
  Json toJson() => compact({
    'kind': 'rows',
    'fields': [for (final field in fields) field.toJson()],
    'rows': rows,
    'truncated': truncated,
  });
}
