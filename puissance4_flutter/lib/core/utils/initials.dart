/// Initiales (1-2 lettres) tirées d'un pseudo — utilisé partout où un avatar
/// n'a pas d'image (Jouer, Classement).
String initialsOf(String username) {
  final letters = username
      .trim()
      .split(RegExp(r'[\s-]+'))
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase())
      .take(2);
  final result = letters.join();
  return result.isEmpty ? '?' : result;
}
