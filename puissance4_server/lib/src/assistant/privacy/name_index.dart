/// Repérage des valeurs sensibles connues dans un texte libre, sans IA : un
/// dictionnaire suffit, puisqu'elles sont en base.
///
/// - Aho-Corasick : le temps de recherche dépend de la longueur du texte,
///   pas du nombre de noms.
/// - Normalisation : minuscules, sans accents, apostrophes et tirets
///   unifiés, et l'espace entre une lettre et un chiffre qui la suit ignoré
///   (« kevin 42 » trouve « Kevin42 »).
/// - Mot entier seulement, la correspondance la plus longue gagne.
library;

/// Une valeur trouvée : sa place dans le texte d'origine et ce qu'elle
/// désigne.
final class NameMatch {
  const NameMatch(this.start, this.end, this.ref);

  /// `[start, end)` dans le texte d'origine.
  final int start;
  final int end;
  final String ref;
}

/// Texte normalisé, avec pour chaque caractère sa position d'origine.
final class _Normalized {
  _Normalized(this.text, this.origins);

  final String text;
  final List<int> origins;
}

const _accents = {
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'á': 'a',
  'ã': 'a',
  'å': 'a',
  'ç': 'c',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'î': 'i',
  'ï': 'i',
  'í': 'i',
  'ì': 'i',
  'ô': 'o',
  'ö': 'o',
  'ó': 'o',
  'ò': 'o',
  'õ': 'o',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ú': 'u',
  'ÿ': 'y',
  'ñ': 'n',
  'œ': 'o',
  'æ': 'a',
  '’': "'",
  '‘': "'",
  'ʼ': "'",
  '–': '-',
  '—': '-',
  '‐': '-',
  '‑': '-',
};

bool _isWordChar(String c) => RegExp(r'[a-z0-9_\-]').hasMatch(c);
bool _isLetter(String c) => RegExp('[a-z]').hasMatch(c);
bool _isDigit(String c) => RegExp('[0-9]').hasMatch(c);

_Normalized _normalize(String input) {
  final chars = <String>[];
  final origins = <int>[];
  for (var i = 0; i < input.length; i++) {
    final lower = input[i].toLowerCase();
    // Une position par caractère d'origine : une minuscule sur plusieurs
    // caractères (rare) garde le caractère tel quel.
    chars.add(_accents[lower] ?? (lower.length == 1 ? lower : input[i]));
    origins.add(i);
  }
  // Retire l'espace entre une lettre et un chiffre : « kevin 42 » devient
  // « kevin42 ». Pas dans l'autre sens, qui collerait le mot suivant
  // (« 42 b » → « 42b »).
  final text = <String>[];
  final kept = <int>[];
  for (var i = 0; i < chars.length; i++) {
    if (chars[i] == ' ' && i > 0 && i + 1 < chars.length) {
      final before = chars[i - 1], after = chars[i + 1];
      if (_isLetter(before) && _isDigit(after)) continue;
    }
    text.add(chars[i]);
    kept.add(origins[i]);
  }
  return _Normalized(text.join(), kept);
}

/// Forme normalisée d'un nom (pour l'indexer).
String normalizeName(String name) => _normalize(name).text;

class _Node {
  final next = <String, _Node>{};
  _Node? fail;

  /// Longueur et référence du plus long nom qui se termine ici (via les
  /// liens d'échec compris).
  final outputs = <(int, String)>[];
}

/// Index de noms → références (`user:<uuid>`), immuable une fois construit.
final class NameIndex {
  NameIndex(
    Map<String, String> names, {
    int minLength = 3,
    Set<String> commonWords = const {},
  }) {
    for (final MapEntry(key: name, value: ref) in names.entries) {
      final normalized = normalizeName(name);
      // Un nom court ou courant (« Max ») remplacerait des mots ordinaires :
      // pour ceux-là, on compte sur les mentions.
      if (normalized.length < minLength || commonWords.contains(normalized)) {
        continue;
      }
      var node = _root;
      for (var i = 0; i < normalized.length; i++) {
        node = node.next.putIfAbsent(normalized[i], _Node.new);
      }
      node.outputs.add((normalized.length, ref));
      _size++;
    }
    _link();
  }

  static final empty = NameIndex(const {});

  final _root = _Node();
  int _size = 0;

  int get size => _size;

  void _link() {
    final queue = <_Node>[];
    for (final child in _root.next.values) {
      child.fail = _root;
      queue.add(child);
    }
    while (queue.isNotEmpty) {
      final node = queue.removeAt(0);
      for (final MapEntry(key: c, value: child) in node.next.entries) {
        var fail = node.fail;
        while (fail != null && !fail.next.containsKey(c)) {
          fail = fail.fail;
        }
        child.fail = fail?.next[c] ?? _root;
        child.outputs.addAll(child.fail!.outputs);
        queue.add(child);
      }
    }
  }

  /// Les noms de [text], mots entiers, sans chevauchement (le plus long
  /// l'emporte), dans l'ordre.
  List<NameMatch> find(String text) {
    if (_size == 0 || text.isEmpty) return const [];
    final normalized = _normalize(text);
    final t = normalized.text;
    final candidates = <(int, int, String)>[];
    var node = _root;
    for (var i = 0; i < t.length; i++) {
      final c = t[i];
      while (node != _root && !node.next.containsKey(c)) {
        node = node.fail!;
      }
      node = node.next[c] ?? _root;
      for (final (length, ref) in node.outputs) {
        final start = i - length + 1;
        final end = i + 1;
        final wordStart = start == 0 || !_isWordChar(t[start - 1]);
        final wordEnd = end == t.length || !_isWordChar(t[end]);
        if (wordStart && wordEnd) candidates.add((start, end, ref));
      }
    }
    candidates.sort((a, b) {
      final byLength = (b.$2 - b.$1).compareTo(a.$2 - a.$1);
      return byLength != 0 ? byLength : a.$1.compareTo(b.$1);
    });
    final taken = <(int, int, String)>[];
    for (final candidate in candidates) {
      final overlaps = taken.any(
        (m) => candidate.$1 < m.$2 && m.$1 < candidate.$2,
      );
      if (!overlaps) taken.add(candidate);
    }
    taken.sort((a, b) => a.$1.compareTo(b.$1));
    return [
      for (final (start, end, ref) in taken)
        NameMatch(
          normalized.origins[start],
          normalized.origins[end - 1] + 1,
          ref,
        ),
    ];
  }
}
