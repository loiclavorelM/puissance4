/// Mêmes règles que `ProfileEndpoint._usernamePattern` côté serveur — le
/// serveur reste l'autorité (il vérifie aussi l'unicité), ceci ne sert qu'à
/// un retour immédiat dans le champ.
final _usernamePattern = RegExp(r'^[A-Za-z0-9_-]+$');

const usernameMinLength = 3;
const usernameMaxLength = 20;

/// Message d'erreur à afficher, ou `null` si [username] est valide.
String? validateUsername(String username) {
  final trimmed = username.trim();
  if (trimmed.length < usernameMinLength) {
    return 'Au moins $usernameMinLength caractères.';
  }
  if (trimmed.length > usernameMaxLength) {
    return '$usernameMaxLength caractères maximum.';
  }
  if (!_usernamePattern.hasMatch(trimmed)) {
    return 'Lettres, chiffres, « _ » et « - » uniquement.';
  }
  return null;
}
