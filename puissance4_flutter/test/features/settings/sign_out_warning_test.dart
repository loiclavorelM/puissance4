import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_flutter/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:puissance4_flutter/features/offline/model/server_connection_tracker.dart';
import 'package:puissance4_flutter/features/offline/viewmodel/server_connection_provider.dart';
import 'package:puissance4_flutter/features/profile/viewmodel/profile_provider.dart';
import 'package:puissance4_flutter/features/settings/model/app_preferences.dart';
import 'package:puissance4_flutter/features/settings/view/settings_screen.dart';
import 'package:puissance4_flutter/features/settings/viewmodel/preferences_viewmodel.dart';

import '../../helpers/l10n.dart';

/// Retient les appels à [signOut] au lieu de toucher au serveur.
class _FakeAuth extends AuthViewModel {
  _FakeAuth(this.status);

  final AuthStatus status;
  int signOuts = 0;

  @override
  AuthState build() => AuthState(status: status);

  @override
  Future<void> signOut() async => signOuts++;
}

class _DefaultPreferences extends PreferencesViewModel {
  @override
  Future<AppPreferences> build() async => AppPreferences.defaults;
}

UserProfileDto _profile({required bool isGuest}) => UserProfileDto(
  id: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
  username: 'alice',
  elo: 1000,
  nbParties: 0,
  nbVictoires: 0,
  isGuest: isGuest,
);

void main() {
  late _FakeAuth auth;

  /// Ouvre les Réglages (poussés par-dessus un écran, comme dans l'app) puis
  /// appuie sur « Se déconnecter ».
  Future<void> tapSignOut(
    WidgetTester tester, {
    required AuthStatus status,
    UserProfileDto? profile,
  }) async {
    auth = _FakeAuth(status);
    // Écran assez haut pour que la ListView construise tout, bouton compris.
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...l10nOverrides,
          authViewModelProvider.overrideWith(() => auth),
          myProfileProvider.overrideWith((ref) => Stream.value(profile)),
          preferencesViewModelProvider.overrideWith(_DefaultPreferences.new),
          // Le provider libère son tracker en fin de test : pas le singleton.
          serverConnectionTrackerProvider.overrideWith(
            (ref) => ServerConnectionTracker(),
          ),
        ],
        child: localizedApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();
  }

  testWidgets('an email account signs out without confirmation', (
    tester,
  ) async {
    await tapSignOut(
      tester,
      status: AuthStatus.serverAuthenticated,
      profile: _profile(isGuest: false),
    );

    expect(find.byType(AlertDialog), findsNothing);
    expect(auth.signOuts, 1);
  });

  testWidgets('an anonymous guest is warned and can create an account '
      'instead', (tester) async {
    await tapSignOut(
      tester,
      status: AuthStatus.serverAuthenticated,
      profile: _profile(isGuest: true),
    );

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Créer un compte'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(auth.signOuts, 0);
  });

  testWidgets('a local guest is warned, then signed out once confirmed', (
    tester,
  ) async {
    await tapSignOut(tester, status: AuthStatus.localGuest);

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    // Sans serveur, pas de création de compte possible.
    expect(
      find.descendant(of: dialog, matching: find.text('Créer un compte')),
      findsNothing,
    );

    await tester.tap(
      find.descendant(of: dialog, matching: find.text('Se déconnecter')),
    );
    await tester.pumpAndSettle();

    expect(auth.signOuts, 1);
    expect(find.byType(SettingsScreen), findsNothing);
  });
}
