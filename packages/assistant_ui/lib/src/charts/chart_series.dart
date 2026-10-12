import 'package:assistant_contracts/assistant_contracts.dart';

/// Clé de la série qui regroupe ce qui dépasse le top N.
const othersKey = '__others__';

/// Une série d'un graphique : une valeur par catégorie de l'axe X
/// (`null` = pas de ligne pour cette catégorie).
final class ChartSeries {
  const ChartSeries(this.key, this.values);

  /// Valeur du champ `color` (ou `null` s'il n'y a qu'une série, ou
  /// [othersKey]).
  final Object? key;
  final List<double?> values;

  double get total => values.fold(0, (sum, v) => sum + (v ?? 0));
}

/// Lignes typées réparties en séries selon une spec : commun à tous les
/// moteurs de rendu (barres, courbes, donut). Pur Dart, sans Flutter.
final class PreparedChart {
  const PreparedChart(this.categories, this.series);

  /// Valeurs de l'axe X, dans l'ordre d'affichage.
  final List<Object?> categories;
  final List<ChartSeries> series;

  bool get isEmpty => categories.isEmpty;

  double get maxStacked {
    var max = 0.0;
    for (var i = 0; i < categories.length; i++) {
      final sum = series.fold(0.0, (s, serie) => s + (serie.values[i] ?? 0));
      if (sum > max) max = sum;
    }
    return max;
  }

  double get maxValue => series
      .expand((s) => s.values)
      .fold(0.0, (max, v) => (v ?? 0) > max ? v! : max);

  static PreparedChart prepare(DataSet data, ChartSpec spec) {
    final xField = spec.x?.field;
    final yEncoding = spec.y ?? spec.value;
    if (xField == null || yEncoding == null) {
      return const PreparedChart([], []);
    }
    final xIndex = data.indexOf(xField);
    final yIndex = data.indexOf(yEncoding.field);
    final colorIndex = spec.color == null
        ? -1
        : data.indexOf(spec.color!.field);
    if (xIndex < 0 || yIndex < 0) return const PreparedChart([], []);
    final aggregate = yEncoding.aggregate ?? Aggregate.sum;

    final categories = <Object?>[];
    final keys = <Object?>[];
    final cells = <(Object?, Object?), List<double>>{};
    for (final row in data.rows) {
      final x = row[xIndex];
      final key = colorIndex < 0 ? null : row[colorIndex];
      if (!categories.contains(x)) categories.add(x);
      if (!keys.contains(key)) keys.add(key);
      final y = (row[yIndex] as num?)?.toDouble();
      if (y != null) cells.putIfAbsent((x, key), () => []).add(y);
    }

    if (data.field(xField)?.type == FieldType.temporal) {
      categories.sort((a, b) => '$a'.compareTo('$b'));
    }

    var series = [
      for (final key in keys)
        ChartSeries(key, [
          for (final x in categories) _aggregate(cells[(x, key)], aggregate),
        ]),
    ];

    // Top N des séries, le reste dans « Autres ».
    final limit = spec.color?.limit;
    if (limit != null && series.length > limit) {
      final ranked = [...series]..sort((a, b) => b.total.compareTo(a.total));
      final kept = ranked.take(limit).toSet();
      final rest = ranked.skip(limit).toList();
      series = [
        for (final serie in series)
          if (kept.contains(serie)) serie,
        if (spec.color!.others)
          ChartSeries(othersKey, [
            for (var i = 0; i < categories.length; i++)
              rest.fold<double?>(null, (sum, s) {
                final v = s.values[i];
                return v == null ? sum : (sum ?? 0) + v;
              }),
          ]),
      ];
    }

    // Comparaison de catégories : barres horizontales triées par total.
    if (spec.horizontal) {
      final order = List.generate(categories.length, (i) => i)
        ..sort((a, b) {
          double total(int i) =>
              series.fold(0, (s, serie) => s + (serie.values[i] ?? 0));
          return total(b).compareTo(total(a));
        });
      return PreparedChart(
        [for (final i in order) categories[i]],
        [
          for (final serie in series)
            ChartSeries(serie.key, [for (final i in order) serie.values[i]]),
        ],
      );
    }
    return PreparedChart(categories, series);
  }

  static double? _aggregate(List<double>? values, Aggregate aggregate) {
    if (values == null || values.isEmpty) return null;
    return switch (aggregate) {
      Aggregate.sum => values.fold<double>(0, (a, b) => a + b),
      Aggregate.avg => values.fold<double>(0, (a, b) => a + b) / values.length,
      Aggregate.min => values.reduce((a, b) => a < b ? a : b),
      Aggregate.max => values.reduce((a, b) => a > b ? a : b),
      Aggregate.count => values.length.toDouble(),
    };
  }
}

/// Grille d'une carte de chaleur : `values[y][x]`.
final class PreparedHeatmap {
  const PreparedHeatmap(this.xs, this.ys, this.values);

  final List<Object?> xs;

  /// Du bas vers le haut (rangée 1 en bas, comme le plateau).
  final List<Object?> ys;
  final List<List<double>> values;

  double get max => values.expand((r) => r).fold(0.0, (m, v) => v > m ? v : m);

  static PreparedHeatmap prepare(DataSet data, ChartSpec spec) {
    final xIndex = data.indexOf(spec.x?.field ?? '');
    final yIndex = data.indexOf(spec.y?.field ?? '');
    final vIndex = data.indexOf(spec.value?.field ?? '');
    if (xIndex < 0 || yIndex < 0 || vIndex < 0) {
      return const PreparedHeatmap([], [], []);
    }
    int compare(Object? a, Object? b) {
      final na = num.tryParse('$a'), nb = num.tryParse('$b');
      return na != null && nb != null ? na.compareTo(nb) : '$a'.compareTo('$b');
    }

    final xs = {for (final row in data.rows) row[xIndex]}.toList()
      ..sort(compare);
    final ys = {for (final row in data.rows) row[yIndex]}.toList()
      ..sort(compare);
    final values = List.generate(ys.length, (_) => List.filled(xs.length, 0.0));
    for (final row in data.rows) {
      values[ys.indexOf(row[yIndex])][xs.indexOf(row[xIndex])] +=
          (row[vIndex] as num?)?.toDouble() ?? 0;
    }
    return PreparedHeatmap(xs, ys, values);
  }
}
