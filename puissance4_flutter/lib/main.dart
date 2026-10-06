import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client.dart';
import 'core/l10n/l10n.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/view/login_screen.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/friends/view/challenge_banner.dart';
import 'features/friends/view/friends_screen.dart';
import 'features/friends/viewmodel/friends_viewmodel.dart';
import 'features/game/view/game_home_screen.dart';
import 'features/history/view/history_screen.dart';
import 'features/history/viewmodel/history_viewmodel.dart';
import 'features/leaderboard/view/leaderboard_screen.dart';
import 'features/leaderboard/viewmodel/leaderboard_viewmodel.dart';
import 'features/live/viewmodel/live_updates_provider.dart';
import 'features/offline/model/server_connection_pinger.dart';
import 'features/offline/model/server_connection_tracker.dart';
import 'features/offline/viewmodel/offline_sync_provider.dart';
import 'features/settings/view/settings_screen.dart';
import 'features/settings/viewmodel/locale_provider.dart';

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
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null || !messenger.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(messenger.context.l10n.serversUnreachable)),
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      onGenerateTitle: (context) => context.l10n.appTitle,
      // Langue choisie dans Réglages, sinon celle de l'appareil (E11).
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: _AuthGate());
  }
}

/// Switches between the login screen and the main navigation shell based
/// on [authViewModelProvider] — covers a real Serverpod session and a
/// device-local guest profile alike.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authViewModelProvider).status;
    return switch (status) {
      AuthStatus.loading => const ColoredBox(color: AppColors.background),
      AuthStatus.unauthenticated => const LoginScreen(),
      AuthStatus.serverAuthenticated ||
      AuthStatus.localGuest => const _MainShell(),
    };
  }
}

/// Coquille de navigation principale (post connexion) — 4 onglets : Jouer,
/// Classement, Historique (`doc/latex/figures/maquette-2.png` et
/// suivantes) et Amis (E15, hors maquettes). Réglages n'a pas son propre onglet : l'icône engrenage de
/// l'écran Jouer le pousse en route à part (pas besoin des deux accès).
/// `IndexedStack` garde l'état de chaque onglet en mémoire (ex. le bouton de
/// test en cours sur Jouer) quand on change d'onglet.
class _MainShell extends ConsumerStatefulWidget {
  const _MainShell();

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell> {
  static const _leaderboardTabIndex = 1;
  static const _historyTabIndex = 2;
  static const _friendsTabIndex = 3;

  int _selectedIndex = 0;

  void _openTab(int index) {
    setState(() => _selectedIndex = index);
    // Les changements serveur arrivent déjà en temps réel
    // (`liveUpdatesProvider`) ; ce refetch à l'ouverture de l'onglet reste un
    // filet pour ce qui n'est pas diffusé (parties Normal synchronisées
    // depuis un autre appareil, nouveaux joueurs au classement). Le cache
    // local reste affiché pendant le rechargement, donc pas de spinner.
    if (index == _leaderboardTabIndex) {
      ref.invalidate(leaderboardProvider);
    }
    if (index == _historyTabIndex) {
      ref.invalidate(serverHistoryProvider);
      ref.invalidate(offlineHistoryProvider);
    }
    if (index == _friendsTabIndex) {
      ref.invalidate(friendsOverviewProvider);
      ref.invalidate(recentOpponentsProvider);
    }
  }

  /// « Ajouter des amis » depuis le classement entre amis vide.
  void _openAddFriends() {
    ref
        .read(friendsTabRequestProvider.notifier)
        .open(FriendsScreen.addTabIndex);
    _openTab(_friendsTabIndex);
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    // Garde `offlineSyncOnReconnectProvider` vivant tant que l'app est
    // connectée/en invité — sans ça, rien ne le construit puisqu'aucune
    // vue n'a besoin de sa valeur (`void`), seulement de son effet de bord.
    ref.watch(offlineSyncOnReconnectProvider);
    ref.watch(liveUpdatesProvider);

    final screens = [
      GameHomeScreen(onOpenSettings: _openSettings),
      LeaderboardScreen(onAddFriends: _openAddFriends),
      const HistoryScreen(),
      const FriendsScreen(),
    ];
    final incomingRequests = ref.watch(incomingFriendRequestCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Défi d'un ami (E15), visible depuis tous les onglets.
            const ChallengeBanner(),
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: screens),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : Colors.white38,
            ),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 12,
              color: states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : Colors.white38,
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.card,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _openTab,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: context.l10n.tabPlay,
            ),
            NavigationDestination(
              icon: const Icon(Icons.emoji_events_outlined),
              selectedIcon: const Icon(Icons.emoji_events),
              label: context.l10n.tabLeaderboard,
            ),
            NavigationDestination(
              icon: const Icon(Icons.history),
              label: context.l10n.tabHistory,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: incomingRequests > 0,
                label: Text('$incomingRequests'),
                child: const Icon(Icons.people_outline),
              ),
              selectedIcon: Badge(
                isLabelVisible: incomingRequests > 0,
                label: Text('$incomingRequests'),
                child: const Icon(Icons.people),
              ),
              label: context.l10n.tabFriends,
            ),
          ],
        ),
      ),
    );
  }
}
