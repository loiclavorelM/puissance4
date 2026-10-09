import 'dart:async';

import 'package:assistant_ui/assistant_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../live/viewmodel/live_updates_provider.dart';
import '../model/serverpod_assistant_ports.dart';

/// Le tableau de bord et l'assistant demandent une session serveur : un
/// invité local (sans réseau à la connexion) ne les a pas.
final assistantAvailableProvider = Provider<bool>(
  (ref) =>
      ref.watch(authViewModelProvider.select((s) => s.status)) ==
      AuthStatus.serverAuthenticated,
);

final dataSourceClientProvider = Provider<DataSourceClient>(
  (ref) => ServerpodDataSourceClient(ref.watch(gameDataChangesProvider).stream),
);

/// Contrôleur du package `assistant_ui`, enveloppé dans Riverpod : le
/// package ne dépend d'aucun gestionnaire d'état, l'app choisit le sien.
/// Recréé à chaque changement de session (autoDispose, et `_MainShell` est
/// démonté à la déconnexion).
final dashboardControllerProvider =
    ChangeNotifierProvider.autoDispose<DashboardController>((ref) {
      ref.watch(assistantAvailableProvider);
      final controller = DashboardController(
        ServerpodDashboardRepository(
          ref.watch(dashboardChangesProvider).stream,
        ),
      );
      unawaited(controller.reload());
      return controller;
    });
