import 'package:serverpod_auth_idp_server/providers/google.dart';

/// By extending [GoogleIdpBaseEndpoint], the Google identity provider
/// endpoint is made available on the server and enables the corresponding
/// sign-in widget on the client. Signing in will still fail until real
/// OAuth credentials replace the placeholder `googleClientSecret` in
/// `config/passwords.yaml` — see `server.dart`.
class GoogleIdpEndpoint extends GoogleIdpBaseEndpoint {}
