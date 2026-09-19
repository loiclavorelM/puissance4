import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

import '../../../client.dart';
import 'server_connection_tracker.dart';

/// Déclenche un appel `ping()` ponctuel — jamais en boucle, et jamais si on
/// sait déjà qu'on n'a pas de connexion — à trois moments seulement :
/// démarrage, changement de connectivité OS détecté, et retour au premier
/// plan de l'app. Le résultat de l'appel est pris en compte via les hooks
/// `onSucceededCall`/`onFailedCall` du client (`ServerConnectionTracker`),
/// pas ici.
class ServerConnectionPinger with WidgetsBindingObserver {
  ServerConnectionPinger() {
    WidgetsBinding.instance.addObserver(this);
    client.connectivityMonitor?.addListener(_onConnectivityChanged);
    // Différé après le premier frame pour ne jamais concurrencer le
    // démarrage/premier paint de l'app, même indirectement.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(_pingIfConnected()),
    );
  }

  void _onConnectivityChanged(bool connected) {
    serverConnectionTracker.updateNetworkAvailability(connected);
    if (connected) unawaited(_ping());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_pingIfConnected());
  }

  /// Interroge l'état de connectivité réel (pas juste le dernier événement
  /// connu, potentiellement absent) avant de pinguer — utilisé au démarrage
  /// et au retour au premier plan, les deux moments où on n'a pas
  /// forcément d'événement récent de `connectivityMonitor` sous la main.
  Future<void> _pingIfConnected() async {
    final results = await Connectivity().checkConnectivity();
    final hasNetwork =
        !(results.length == 1 && results.first == ConnectivityResult.none);
    serverConnectionTracker.updateNetworkAvailability(hasNetwork);
    if (hasNetwork) unawaited(_ping());
  }

  Future<void> _ping() async {
    try {
      await client.connection.ping();
    } catch (_) {
      // Le résultat est déjà pris en compte via onSucceededCall/onFailedCall.
    }
  }
}
