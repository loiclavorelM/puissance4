import 'dart:ui';

import 'package:flutter/material.dart' show ThemeMode;

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
  const AppPreferences({required this.language, required this.themeMode});

  /// Thème sombre tant qu'aucun n'a été choisi : c'est celui des maquettes.
  static const defaultThemeMode = ThemeMode.dark;

  /// Langue de l'appareil tant qu'aucune n'a été choisie.
  static AppPreferences get defaults => AppPreferences(
    language: AppLanguage.ofDevice(),
    themeMode: defaultThemeMode,
  );

  final AppLanguage language;

  /// Système, clair ou sombre.
  final ThemeMode themeMode;

  AppPreferences copyWith({AppLanguage? language, ThemeMode? themeMode}) {
    return AppPreferences(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
