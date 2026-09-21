import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:serverpod_offline_sync_client/serverpod_offline_sync_client.dart';

import 'client.dart';
import 'features/auth/view/login_screen.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/offline/model/server_connection_pinger.dart';
import 'features/offline/model/server_connection_tracker.dart';
import 'features/offline/view/server_connection_indicator.dart';
import 'features/offline/viewmodel/offline_sync_provider.dart';

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
class _MainMenuPlaceholder extends ConsumerStatefulWidget {
  const _MainMenuPlaceholder();

  @override
  ConsumerState<_MainMenuPlaceholder> createState() =>
      _MainMenuPlaceholderState();
}

class _MainMenuPlaceholderState extends ConsumerState<_MainMenuPlaceholder> {
  static const _background = Color(0xFF0D0E1F);

  bool _isSimulating = false;

  @override
  Widget build(BuildContext context) {
    // serverpod_offline_sync ne synchronise que les spaces liés à un
    // authUserId reconnu par le serveur (vérifié empiriquement) : pas de
    // session possible en AuthStatus.localGuest (pas d'authUserId du tout).
    // Limitation acceptée pour l'instant — voir le plan.
    final isAuthenticated =
        ref.watch(authViewModelProvider).status ==
        AuthStatus.serverAuthenticated;

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
      body: Center(
        // Outil de dev temporaire : pas encore de moteur de jeu (E4) pour
        // générer de vraies OfflineMatchResult, donc ce bouton permet de
        // tester le flux complet (création -> sync) depuis l'app plutôt
        // qu'avec un script. À retirer une fois E4 fait.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: (_isSimulating || !isAuthenticated)
                  ? null
                  : _simulateMatch,
              child: const Text('Simuler une partie'),
            ),
            if (!isAuthenticated)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Connecte-toi (même en invité, en ligne) pour tester la '
                  'synchro.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _simulateMatch() async {
    setState(() => _isSimulating = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final session = await ref
          .read(offlineSyncSessionHolderProvider)
          .getOrCreate();
      final random = Random();
      await OfflineMatchResult.db.insertRow(
        session,
        OfflineMatchResult(
          result:
              EnumMatchResult.values[random.nextInt(
                EnumMatchResult.values.length,
              )],
          botLevel:
              EnumBotLevel.values[random.nextInt(
                EnumBotLevel.values.length,
              )],
          moves: const [1, 4, 2, 5],
          playedAt: DateTime.now(),
        ),
      );
      // La ligne est déjà sauvegardée localement à ce stade (insertRow ne
      // fait aucun appel réseau) — une panne réseau ici ne doit pas être
      // affichée comme une erreur, juste comme "en attente de sync".
      // syncOnce ouvre un method stream (WebSocket), pas un appel RPC
      // classique : ses échecs réseau remontent en MethodStreamException
      // (ex. WebSocketConnectException), pas en ServerpodClientNetworkException.
      String message;
      try {
        await client.offlineSync.syncOnce(session);
        message = 'Partie simulée, créée et synchronisée';
      } on ServerpodClientNetworkException {
        message =
            'Partie simulée créée localement (pas de réseau, sera '
            'synchronisée au retour de la connexion)';
      } on MethodStreamException {
        message =
            'Partie simulée créée localement (pas de réseau, sera '
            'synchronisée au retour de la connexion)';
      }
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Erreur : $error')));
      }
    } finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }
}
