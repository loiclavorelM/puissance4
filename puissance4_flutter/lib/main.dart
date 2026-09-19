import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client.dart';
import 'features/auth/view/login_screen.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/offline/model/server_connection_pinger.dart';
import 'features/offline/model/server_connection_tracker.dart';
import 'features/offline/view/server_connection_indicator.dart';

late final ServerConnectionPinger serverConnectionPinger;

/// Permet d'afficher une pop-up depuis en dehors de l'arbre de widgets
/// (ex. réagir à un changement de connectivité) sans avoir besoin d'un
/// `BuildContext` particulier sous la main.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  serverConnectionPinger = ServerConnectionPinger();

  // Pop-up ponctuelle, uniquement sur le vrai front montant de "réseau OK
  // mais serveur injoignable" (voir ServerConnectionTracker — un simple
  // "pas de réseau" est déjà évident pour l'utilisateur via le point
  // gris/rouge, pas besoin d'insister dessus).
  serverConnectionTracker.onUnreachableDespiteNetwork.listen((_) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text(
          "Vous êtes connecté à internet, mais nos serveurs sont "
          'injoignables pour le moment.',
        ),
      ),
    );
  });

  runApp(const ProviderScope(child: MyApp()));
}

/// Builds a theme for the given [brightness].
ThemeData _buildTheme(Brightness brightness) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: brightness,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Serverpod Demo',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'Serverpod Example'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: _AuthGate());
  }
}

/// Switches between the login screen and the (placeholder) main menu based
/// on [authViewModelProvider] — covers a real Serverpod session and a
/// device-local guest profile alike.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  static const _background = Color(0xFF0D0E1F);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authViewModelProvider).status;
    return switch (status) {
      AuthStatus.loading => const ColoredBox(color: _background),
      AuthStatus.unauthenticated => const LoginScreen(),
      AuthStatus.serverAuthenticated ||
      AuthStatus.localGuest => const _MainMenuPlaceholder(),
    };
  }
}

/// Placeholder landing screen after sign-in — just the app's background.
/// The real main menu is a separate, still-to-build feature (T4.2.2).
class _MainMenuPlaceholder extends ConsumerWidget {
  const _MainMenuPlaceholder();

  static const _background = Color(0xFF0D0E1F);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          const ServerConnectionIndicator(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () => ref.read(authViewModelProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}
