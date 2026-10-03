/// Mêmes règles que `ProfileEndpoint._usernamePattern` côté serveur — le
/// serveur reste l'autorité (il vérifie aussi l'unicité), ceci ne sert qu'à
/// un retour immédiat dans le champ.
final _usernamePattern = RegExp(r'^[A-Za-z0-9_-]+$');

const usernameMinLength = 3;
const usernameMaxLength = 20;

/// Ce qui ne va pas dans un pseudo (le texte est choisi par la vue, dans la
/// langue de l'app).
enum UsernameProblem { tooShort, tooLong, invalidCharacters }

/// `null` si [username] est valide.
UsernameProblem? checkUsername(String username) {
  final trimmed = username.trim();
  if (trimmed.length < usernameMinLength) return UsernameProblem.tooShort;
  if (trimmed.length > usernameMaxLength) return UsernameProblem.tooLong;
  if (!_usernamePattern.hasMatch(trimmed)) {
    return UsernameProblem.invalidCharacters;
  }
  return null;
}
