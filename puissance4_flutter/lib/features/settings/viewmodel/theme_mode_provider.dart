import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/app_preferences.dart';
import 'preferences_viewmodel.dart';

/// Thème de l'app : celui choisi dans Réglages, ou le thème sombre tant que
/// les préférences ne sont pas chargées (pas de flash clair au démarrage).
final themeModeProvider = Provider<ThemeMode>(
  (ref) =>
      ref.watch(preferencesViewModelProvider).valueOrNull?.themeMode ??
      AppPreferences.defaultThemeMode,
);
