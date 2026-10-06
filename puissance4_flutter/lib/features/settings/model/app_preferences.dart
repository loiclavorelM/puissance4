import 'dart:ui';

/// Langues de l'app (E11), choisies dans Réglages.
enum AppLanguage {
  fr('Français'),
  en('English');

  const AppLanguage(this.label);

  /// Langue de l'appareil si l'app la parle, sinon l'anglais.
  static AppLanguage ofDevice() =>
      PlatformDispatcher.instance.locale.languageCode == 'fr' ? fr : en;

  /// Nom de la langue dans sa propre langue (comme dans la maquette).
  final String label;
}

/// Préférences locales à l'appareil (pas synchronisées avec le compte, donc
/// disponibles aussi pour l'invité local E0).
class AppPreferences {
  const AppPreferences({required this.language, required this.darkTheme});

  /// Langue de l'appareil tant qu'aucune n'a été choisie. L'app est
  /// aujourd'hui entièrement sombre, d'où `darkTheme: true`.
  static AppPreferences get defaults =>
      AppPreferences(language: AppLanguage.ofDevice(), darkTheme: true);

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
