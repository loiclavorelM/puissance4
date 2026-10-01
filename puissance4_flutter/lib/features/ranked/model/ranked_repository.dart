import 'package:puissance4_client/puissance4_client.dart';

import '../../../client.dart';

/// Classé : partie contre un bot joué par le serveur (`RankedEndpoint`).
/// Une fois créée, elle se suit comme toute partie serveur
/// (`ServerGameRepository`).
class RankedRepository {
  Future<UuidValue> startRanked() => client.ranked.startRanked();
}
