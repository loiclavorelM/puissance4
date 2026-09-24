/// Langues proposées dans Réglages — pas encore appliquées à l'UI (la lib
/// l10n arrive avec E11), seulement mémorisées.
enum AppLanguage {
  fr('Français'),
  en('English');

  const AppLanguage(this.label);

  /// Nom de la langue dans sa propre langue (comme dans la maquette).
  final String label;
}

/// Préférences locales à l'appareil (pas synchronisées avec le compte, donc
/// disponibles aussi pour l'invité local E0).
class AppPreferences {
  const AppPreferences({required this.language, required this.darkTheme});

  /// L'app est aujourd'hui entièrement sombre, d'où `darkTheme: true`.
  static const defaults = AppPreferences(
    language: AppLanguage.fr,
    darkTheme: true,
  );

  final AppLanguage language;

  /// Pas encore appliqué : il n'existe pas de thème clair (cf. AppColors).
  final bool darkTheme;

  AppPreferences copyWith({AppLanguage? language, bool? darkTheme}) {
    return AppPreferences(
      language: language ?? this.language,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }
}
