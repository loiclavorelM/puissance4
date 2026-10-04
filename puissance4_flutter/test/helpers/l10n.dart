import 'package:flutter/material.dart';
import 'package:puissance4_flutter/core/l10n/l10n.dart';
import 'package:puissance4_flutter/features/settings/viewmodel/locale_provider.dart';

/// Les tests vérifient les textes français (langue modèle des ARB).
const testLocale = Locale('fr');

/// À ajouter aux overrides d'un `ProviderScope`/`ProviderContainer` : textes
/// des viewmodels et moteurs en français, quelle que soit la machine.
final l10nOverrides = [localeProvider.overrideWithValue(testLocale)];

/// `MaterialApp` avec les traductions de l'app, en français.
MaterialApp localizedApp({required Widget home}) => MaterialApp(
  locale: testLocale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: home,
);
