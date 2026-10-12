import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_flutter/features/settings/model/preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stockage en mémoire : seules les méthodes utilisées par le repository.
class _MemoryPrefs implements SharedPreferencesAsync {
  final values = <String, Object>{};

  @override
  Future<String?> getString(String key) async => values[key] as String?;

  @override
  Future<bool?> getBool(String key) async => values[key] as bool?;

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _MemoryPrefs prefs;
  late PreferencesRepository repository;

  setUp(() {
    prefs = _MemoryPrefs();
    repository = PreferencesRepository(prefs: prefs);
  });

  test('defaults to the dark theme', () async {
    expect((await repository.load()).themeMode, ThemeMode.dark);
  });

  test('keeps the choice made with the former dark theme switch', () async {
    prefs.values['pref.darkTheme'] = false;
    expect((await repository.load()).themeMode, ThemeMode.light);

    prefs.values['pref.darkTheme'] = true;
    expect((await repository.load()).themeMode, ThemeMode.dark);
  });

  test('saves the chosen mode and drops the former switch', () async {
    prefs.values['pref.darkTheme'] = false;
    await repository.saveThemeMode(ThemeMode.system);

    expect((await repository.load()).themeMode, ThemeMode.system);
    expect(prefs.values, isNot(contains('pref.darkTheme')));
  });
}
