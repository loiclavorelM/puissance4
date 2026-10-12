/// Code ami (E15) lu dans un QR code : `P4-XXXXXX` — mêmes caractères que
/// `FriendCode` côté serveur (sans 0/O, 1/I/L). Renvoie le code normalisé
/// à chercher, ou `null` si [raw] n'en contient pas.
String? friendCodeFromScan(String raw) {
  final match = RegExp(
    r'P4[\s-]?([2-9A-HJKMNP-Z]{6})\b',
    caseSensitive: false,
  ).firstMatch(raw.trim());
  return match == null ? null : 'P4-${match[1]!.toUpperCase()}';
}
