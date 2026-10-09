/// Période relative (`last:7d`, `this:month`, `all`…) : jamais de date
/// absolue dans une définition, pour que la fenêtre glisse toute seule à
/// chaque rafraîchissement.
final class RelativeRange {
  const RelativeRange._(this.value);

  /// `null` si [value] n'est pas une période connue.
  static RelativeRange? tryParse(String value) =>
      values.contains(value) ? RelativeRange._(value) : null;

  static const values = [
    'last:24h',
    'last:7d',
    'last:30d',
    'last:90d',
    'this:week',
    'this:month',
    'this:year',
    'all',
  ];

  static const all = RelativeRange._('all');

  final String value;

  /// Début (inclus) de la période à l'instant [now] (heure locale du
  /// serveur ou de l'app), ou `null` pour `all`.
  DateTime? start(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (value) {
      'last:24h' => now.subtract(const Duration(hours: 24)),
      'last:7d' => today.subtract(const Duration(days: 6)),
      'last:30d' => today.subtract(const Duration(days: 29)),
      'last:90d' => today.subtract(const Duration(days: 89)),
      'this:week' => today.subtract(Duration(days: today.weekday - 1)),
      'this:month' => DateTime(now.year, now.month),
      'this:year' => DateTime(now.year),
      _ => null,
    };
  }

  /// La période précédente de même durée, pour un delta : `[start - d, start)`.
  (DateTime, DateTime)? previous(DateTime now) {
    final start = this.start(now);
    if (start == null) return null;
    return (start.subtract(now.difference(start)), start);
  }

  @override
  bool operator ==(Object other) =>
      other is RelativeRange && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
