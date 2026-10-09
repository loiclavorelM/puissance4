import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import 'app_preferences.dart';

/// Persiste [AppPreferences] sur l'appareil — `shared_preferences` plutôt
/// que `flutter_secure_storage` : rien de sensible ici.
class PreferencesRepository {
  PreferencesRepository({SharedPreferencesAsync? prefs})
    : _prefs = prefs ?? SharedPreferencesAsync();

  static const _languageKey = 'pref.language';
  static const _themeModeKey = 'pref.themeMode';

  /// Ancien interrupteur « Thème sombre », relu tant qu'aucun mode n'a été
  /// choisi pour garder le choix fait avant le thème clair.
  static const _legacyDarkThemeKey = 'pref.darkTheme';

  final SharedPreferencesAsync _prefs;

  Future<AppPreferences> load() async {
    final languageName = await _prefs.getString(_languageKey);
    final themeModeName = await _prefs.getString(_themeModeKey);
    final legacyDarkTheme = await _prefs.getBool(_legacyDarkThemeKey);
    return AppPreferences(
      language: AppLanguage.values.firstWhere(
        (language) => language.name == languageName,
        orElse: () => AppPreferences.defaults.language,
      ),
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == themeModeName,
        orElse: () => switch (legacyDarkTheme) {
          false => ThemeMode.light,
          true || null => AppPreferences.defaultThemeMode,
        },
      ),
    );
  }

  Future<void> saveLanguage(AppLanguage language) =>
      _prefs.setString(_languageKey, language.name);

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await _prefs.setString(_themeModeKey, themeMode.name);
    await _prefs.remove(_legacyDarkThemeKey);
  }
}
