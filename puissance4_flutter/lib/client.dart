import 'dart:async';

import 'package:flutter/services.dart' show appFlavor;
import 'package:puissance4_client/puissance4_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'features/offline/model/server_connection_tracker.dart';

/// Serveur de production (Serverpod Cloud), utilisé par la flavor `prod`.
const prodServerUrl = 'https://puissance4.api.serverpod.space/';

// Flavor `prod` (Android) : toujours [prodServerUrl].
//
// Flavor `dev` et web : `getServerUrl()` — `--dart-define=SERVER_URL=...` si
// donné, sinon assets/config.json, sinon http://$localhost:8080/. Sur un vrai
// téléphone, passer l'IP du PC (`ip addr` sous Linux) :
// `flutter run --flavor dev --dart-define=SERVER_URL=http://192.168.1.84:8080/`.
// L'app web déployée reçoit son config.json du serveur qui la sert.
final serverUrl = appFlavor == 'prod'
    ? Future.value(prodServerUrl)
    : getServerUrl();

/// Sets up a global client object that can be used to talk to the server from
/// anywhere in our app. The client is generated from your server code
/// and is set up to connect to a Serverpod running on a local server on
/// the default port. You will need to modify this to connect to staging or
/// production servers.
/// In a larger app, you may want to use the dependency injection of your choice
/// instead of using a global client object. This is just a simple example.
late final Client client;

Future<void> initializeClient() async {
  client =
      Client(
          await serverUrl,
          onSucceededCall: (_) => serverConnectionTracker.markSucceeded(),
          onFailedCall: (_, error, _) =>
              serverConnectionTracker.markFailed(error),
        )
        ..connectivityMonitor = FlutterConnectivityMonitor()
        ..authSessionManager = FlutterAuthSessionManager();
  unawaited(client.auth.initialize());
}
