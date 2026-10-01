import 'package:shared_preferences/shared_preferences.dart';

import 'app_preferences.dart';

/// Persiste [AppPreferences] sur l'appareil — `shared_preferences` plutôt
/// que `flutter_secure_storage` : rien de sensible ici.
class PreferencesRepository {
  PreferencesRepository({SharedPreferencesAsync? prefs})
    : _prefs = prefs ?? SharedPreferencesAsync();

  static const _languageKey = 'pref.language';
  static const _darkThemeKey = 'pref.darkTheme';

  final SharedPreferencesAsync _prefs;

  Future<AppPreferences> load() async {
    final languageName = await _prefs.getString(_languageKey);
    final darkTheme = await _prefs.getBool(_darkThemeKey);
    return AppPreferences(
      language: AppLanguage.values.firstWhere(
        (language) => language.name == languageName,
        orElse: () => AppPreferences.defaults.language,
      ),
      darkTheme: darkTheme ?? AppPreferences.defaults.darkTheme,
    );
  }

  Future<void> saveLanguage(AppLanguage language) =>
      _prefs.setString(_languageKey, language.name);

  Future<void> saveDarkTheme(bool darkTheme) =>
      _prefs.setBool(_darkThemeKey, darkTheme);
}
