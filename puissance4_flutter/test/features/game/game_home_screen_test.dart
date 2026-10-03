import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_flutter/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:puissance4_flutter/features/game/view/game_home_screen.dart';
import 'package:puissance4_flutter/features/game/viewmodel/game_home_viewmodel.dart';
import 'package:puissance4_flutter/features/sensors/viewmodel/flat_provider.dart';

class _GuestAuth extends AuthViewModel {
  @override
  AuthState build() => const AuthState(status: AuthStatus.localGuest);
}

void main() {
  late StreamController<(double, double, double, DateTime)> accelerometer;
  setUp(() => accelerometer = StreamController.broadcast());
  tearDown(() => accelerometer.close());

  /// Téléphone posé à plat, immobile, pendant une seconde.
  Future<void> layFlat(WidgetTester tester) async {
    final t0 = DateTime(2026);
    for (var ms = 0; ms <= 1000; ms += 100) {
      accelerometer.add((0, 0, 9.81, t0.add(Duration(milliseconds: ms))));
    }
    await tester.pumpAndSettle();
  }

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gravityProvider.overrideWithValue(accelerometer.stream),
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
          home: Scaffold(body: GameHomeScreen(onOpenSettings: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('face à face only shows up when the phone lies flat', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Face à face'), findsNothing);
    expect(
      find.text('Pose le téléphone à plat pour jouer à deux'),
      findsOneWidget,
    );

    await layFlat(tester);
    expect(find.text('Face à face'), findsOneWidget);

    // Relevé : le mode disparaît.
    accelerometer.add((0, 9.81, 0, DateTime(2026, 1, 1, 0, 0, 2)));
    await tester.pumpAndSettle();
    expect(find.text('Face à face'), findsNothing);
  });

  testWidgets('face à face opens a two-player game on the device', (
    tester,
  ) async {
    await pump(tester);
    await layFlat(tester);

    await tester.tap(find.text('Face à face'));
    await tester.pumpAndSettle();

    expect(find.text('À Joueur 1 de jouer'), findsOneWidget);
    expect(find.text('Joueur 2'), findsWidgets);
  });
}
