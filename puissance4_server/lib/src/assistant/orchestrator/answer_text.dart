/// Retire les tableaux markdown d'une réponse du LLM. Le prompt les
/// interdit (le chat ne sait pas les afficher et le widget montre déjà les
/// chiffres), mais gpt-oss en recopie parfois un, souvent avec des cases
/// vides (`—`, `…`) : on enlève ses lignes plutôt que de les afficher brutes.
String withoutMarkdownTables(String text) {
  final lines = [
    for (final line in text.split('\n'))
      if (!line.trimLeft().startsWith('|')) line,
  ];
  return lines.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}
