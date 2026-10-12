import 'package:assistant_contracts/assistant_contracts.dart';

/// Tableau croisé d'un widget table de `games.pivot` à deux dimensions :
/// les valeurs de `groupBy` en lignes, celles de `splitBy` en colonnes (la
/// dimension de temps toujours en colonnes), la mesure dans les cases. La source renvoie une ligne par couple (format
/// long, que lit aussi le LLM) : on ne croise qu'à l'affichage et à
/// l'export, pour que l'écran, le PDF et le CSV montrent la même chose.
final class CrossTable {
  CrossTable._({
    required this.rowField,
    required this.columnField,
    required this.measureField,
    required this.rowKeys,
    required this.columnKeys,
    required this.cells,
    required this.rowRefs,
  });

  /// `null` si le widget n'est pas un tableau croisable : pas une table,
  /// pas `games.pivot`, une seule dimension, ou des colonnes choisies à la
  /// main (le joueur veut alors la liste telle quelle).
  static CrossTable? of(WidgetDefinition definition, DataSet data) {
    final params = definition.query.params;
    if (definition.type != WidgetType.table ||
        definition.query.source != 'games.pivot' ||
        definition.display.columns != null) {
      return null;
    }
    if ((params['groupBy'], params['splitBy'], params['measure']) case (
      final String groupBy,
      final String splitBy,
      final String measure,
    )) {
      // Le temps se lit de gauche à droite : une dimension de temps va en
      // colonnes, quel que soit l'ordre choisi par le LLM ou le joueur.
      final (row, column) = _isTime(groupBy) && !_isTime(splitBy)
          ? (splitBy, groupBy)
          : (groupBy, splitBy);
      final r = data.indexOf(row);
      final c = data.indexOf(column);
      final m = data.indexOf(measure);
      if (r < 0 || c < 0 || m < 0) return null;
      final ref = row == 'opponent' ? data.indexOf('opponentRef') : -1;
      final rowKeys = <Object?>[];
      final columnKeys = <Object?>[];
      final cells = <(Object?, Object?), Object?>{};
      final rowRefs = <Object?, Object?>{};
      for (final values in data.rows) {
        if (!rowKeys.contains(values[r])) rowKeys.add(values[r]);
        if (!columnKeys.contains(values[c])) columnKeys.add(values[c]);
        cells[(values[r], values[c])] = values[m];
        if (ref >= 0) rowRefs[values[r]] = values[ref];
      }
      if (_isTime(column)) columnKeys.sort((a, b) => '$a'.compareTo('$b'));
      return CrossTable._(
        rowField: row,
        columnField: column,
        measureField: measure,
        rowKeys: rowKeys,
        columnKeys: columnKeys,
        cells: cells,
        rowRefs: rowRefs,
      );
    }
    return null;
  }

  /// Jours et semaines sont des dates ; un mois est une catégorie `2026-10`.
  static bool _isTime(String field) =>
      field == 'month' ||
      AssistantContracts.catalog.fields[field]?.type == FieldType.temporal;

  final String rowField;
  final String columnField;
  final String measureField;
  final List<Object?> rowKeys;
  final List<Object?> columnKeys;

  /// La mesure de chaque couple (ligne, colonne) qui a des parties.
  final Map<(Object?, Object?), Object?> cells;

  /// Référence de l'adversaire de chaque ligne (drilldown), quand les
  /// lignes sont des adversaires.
  final Map<Object?, Object?> rowRefs;

  /// La mesure d'un couple, `null` s'il n'a aucune partie.
  Object? cell(Object? row, Object? column) => cells[(row, column)];
}
