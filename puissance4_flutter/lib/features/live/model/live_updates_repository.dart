import 'package:puissance4_client/puissance4_client.dart';

import '../../../client.dart';

class LiveUpdatesRepository {
  /// Stream (WebSocket) des changements poussés par le serveur pour le
  /// joueur connecté — voir `LiveEndpoint.watchUpdates`.
  Stream<LiveEvent> watch() => client.live.watchUpdates();
}
