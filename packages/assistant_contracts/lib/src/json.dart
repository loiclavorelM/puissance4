/// Petits utilitaires de lecture JSON, pour garder les `fromJson` lisibles.
library;

typedef Json = Map<String, Object?>;

extension JsonRead on Json {
  String string(String key) => this[key] as String;
  String? stringOrNull(String key) => this[key] as String?;
  int? intOrNull(String key) => (this[key] as num?)?.toInt();
  bool? boolOrNull(String key) => this[key] as bool?;
  Json? objectOrNull(String key) =>
      (this[key] as Map?)?.cast<String, Object?>();
  List<Object?> list(String key) => (this[key] as List?) ?? const [];
}

/// Retire les entrées nulles (JSON compact, sans `"x": null`).
Json compact(Json json) => {
  for (final MapEntry(:key, :value) in json.entries) key: ?value,
};
