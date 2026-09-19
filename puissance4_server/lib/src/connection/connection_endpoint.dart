import 'package:serverpod/serverpod.dart';

/// Endpoint volontairement vide : sert uniquement de sonde de joignabilité
/// pour `ServerConnectionTracker` côté client. Le simple fait que l'appel
/// réussisse ou échoue passe par les hooks globaux
/// `onSucceededCall`/`onFailedCall` du client généré.
class ConnectionEndpoint extends Endpoint {
  Future<void> ping(Session session) async {}
}
