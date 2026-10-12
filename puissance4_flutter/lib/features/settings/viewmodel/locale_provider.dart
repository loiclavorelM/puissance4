import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../model/app_preferences.dart';
import 'preferences_viewmodel.dart';

/// Langue de l'app (E11) : celle choisie dans Réglages, ou celle de
/// l'appareil tant que les préférences ne sont pas chargées.
final localeProvider = Provider<Locale>((ref) {
  final language =
      ref.watch(preferencesViewModelProvider).valueOrNull?.language ??
      AppLanguage.ofDevice();
  return Locale(language.name);
});

/// Textes de l'UI pour le code sans `BuildContext` (viewmodels, moteurs de
/// partie) ; les widgets utilisent `context.l10n`.
final l10nProvider = Provider<AppLocalizations>(
  (ref) => lookupAppLocalizations(ref.watch(localeProvider)),
);
