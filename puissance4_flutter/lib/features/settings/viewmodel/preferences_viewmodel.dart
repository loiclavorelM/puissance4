import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/app_preferences.dart';
import '../model/preferences_repository.dart';

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepository(),
);

final preferencesViewModelProvider =
    AsyncNotifierProvider<PreferencesViewModel, AppPreferences>(
      PreferencesViewModel.new,
    );

/// Préférences affichées dans Réglages, appliquées à toute l'app : la langue
/// via `localeProvider` (E11), le thème via `themeModeProvider`.
class PreferencesViewModel extends AsyncNotifier<AppPreferences> {
  PreferencesRepository get _repository =>
      ref.read(preferencesRepositoryProvider);

  @override
  Future<AppPreferences> build() => _repository.load();

  AppPreferences get _current => state.valueOrNull ?? AppPreferences.defaults;

  /// Mise à jour optimiste : l'écran réagit tout de suite, l'écriture disque
  /// suit.
  Future<void> setLanguage(AppLanguage language) async {
    state = AsyncData(_current.copyWith(language: language));
    await _repository.saveLanguage(language);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = AsyncData(_current.copyWith(themeMode: themeMode));
    await _repository.saveThemeMode(themeMode);
  }
}
