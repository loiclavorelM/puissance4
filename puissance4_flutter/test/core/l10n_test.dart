import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_flutter/core/l10n/l10n.dart';
import 'package:puissance4_flutter/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:puissance4_flutter/features/game/view/game_home_screen.dart';
import 'package:puissance4_flutter/features/game/viewmodel/game_home_viewmodel.dart';
import 'package:puissance4_flutter/features/sensors/viewmodel/motion_sensors_provider.dart';
import 'package:puissance4_flutter/features/settings/viewmodel/locale_provider.dart';

class _GuestAuth extends AuthViewModel {
  @override
  AuthState build() => const AuthState(status: AuthStatus.localGuest);
}

Map<String, dynamic> _arb(String locale) =>
    jsonDecode(File('lib/core/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _placeholders(String text) =>
    RegExp(r'\{(\w+)\}').allMatches(text).map((m) => m[1]!).toSet();

void main() {
  test('every French text has an English translation with the same '
      'placeholders', () {
    final fr = _arb('fr');
    final en = _arb('en');
    final keys = fr.keys.where((k) => !k.startsWith('@'));
    for (final key in keys) {
      expect(en, contains(key), reason: 'missing English text for $key');
      expect(
        _placeholders(en[key] as String),
        _placeholders(fr[key] as String),
        reason: 'placeholders differ for $key',
      );
    }
    expect(
      en.keys.where((k) => !k.startsWith('@')).toSet(),
      keys.toSet(),
      reason: 'English has keys the French template does not',
    );
  });

  testWidgets('the app speaks the language chosen in the settings', (
    tester,
  ) async {
    Future<void> pumpIn(Locale locale) async {
      await tester.pumpWidget(
        ProviderScope(
          key: ValueKey(locale),
          overrides: [
            localeProvider.overrideWithValue(locale),
            motionSensorsProvider.overrideWithValue(false),
            authViewModelProvider.overrideWith(_GuestAuth.new),
            gameHomeViewModelProvider.overrideWithValue(
              const GameHomeState(
                username: 'alice',
                elo: 1000,
                parties: 0,
                victoires: 0,
                isProfileLoading: false,
                hasProfileError: false,
              ),
            ),
          ],
          child: MaterialApp(
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(body: GameHomeScreen(onOpenSettings: () {})),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpIn(const Locale('fr'));
    expect(find.text('CHOISIS TON MODE'), findsOneWidget);
    expect(find.text('Face à face'), findsOneWidget);

    await pumpIn(const Locale('en'));
    expect(find.text('CHOOSE YOUR MODE'), findsOneWidget);
    expect(find.text('Face to face'), findsOneWidget);
    expect(find.text('Ranked'), findsOneWidget);
  });
}
