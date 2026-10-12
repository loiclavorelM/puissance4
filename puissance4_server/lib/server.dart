import 'dart:io';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/anonymous.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_cloud_storage/serverpod_cloud_storage.dart';

import 'src/assistant/mcp/mcp_dev_server.dart';
import 'src/auth/guest_upgrade.dart';
import 'src/bot/bot_seed.dart';
import 'src/cache_busting.dart';
import 'src/generated/serverpod.dart';
import 'src/game/server_game.dart';
import 'src/profile/user_provisioning.dart';
import 'src/web/routes/app_config_route.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod. The generated Serverpod class is already connected
  // with your project's generated code.
  final pod = Serverpod(args);

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Configure the email identity provider for email/password authentication.
      // The default setup works with Serverpod Cloud without configuration. In
      // development the verification codes are logged to the console, and in
      // staging and production they are sent through the Serverpod Cloud email
      // service. If you want to use a custom provider for sending emails, use
      // `EmailIdpConfigFromPasswords`.
      ServerpodCloudEmailIdpConfig(
        appDisplayName: 'puissance4',
      ),
      // Anonymous sign-in: no external setup needed, works out of the box.
      // Used to give guest players (E0) a real AuthUser as soon as they get a
      // connection, before they create a permanent account.
      AnonymousIdpConfig(),
    ],
    // Creates the game-profile `User` row as soon as an `AuthUser` is
    // created, for every provider — see US1.2 (`T1.2.1`/`T1.2.2`).
    authUsersConfig: AuthUsersConfig(
      onAfterAuthUserCreated: createUserForAuthUser,
    ),
    // A guest who creates an email account keeps their progress: the new
    // account is merged into the anonymous one (US0.2, `guest_upgrade.dart`).
    accountMergeConfig: AccountMergeConfig(
      applicationMergeHandler: mergeGameUsers,
    ),
  );

  // Serve all files in the web/static relative directory under /web.
  // These are used by the default web page.
  pod.webServer.addRoute(
    StaticRoute.withCacheBusting(cacheBustingConfig),
    cacheBustingConfig.mountPrefix,
  );

  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/assets/assets/config.json',
  );

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under /.
    pod.webServer.addRoute(
      FlutterRoute(
        appDir,
        // If building the Flutter app with WASM, set the below parameter to
        // true and add the --wasm flag to the flutter build command.
        enableWasmHeaders: false,
      ),
      '/',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    final defaultRoute = StaticRoute.file(
      File(
        Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
      ),
    );

    pod.webServer.addMiddleware(
      FallbackMiddleware(
        fallback: defaultRoute,
        on: (response) => response.statusCode == 404,
      ).call,
      '/',
    );

    pod.webServer.addRoute(
      defaultRoute,
      '/**',
    );
  }

  // Configure cloud storage.
  // This setup works with Serverpod Cloud without extra configuration.
  // If you want to use a custom provider for cloud storage, replace these
  // with your preferred provider.
  pod.addCloudStorage(
    await ServerpodCloudProvider.private(
      fallback: () => DatabaseCloudStorage('private'),
    ),
  );
  pod.addCloudStorage(
    await ServerpodCloudProvider.public(
      fallback: () => DatabaseCloudStorage('public'),
    ),
  );

  // Les streams de partie attendront la fin de `resumePending` (plus bas)
  // avant de s'attacher.
  ServerGame.holdStreamsUntilResumed();

  // Start the server.
  await pod.start();

  // Serveur MCP de l'assistant pour tester ses outils sans LLM (Claude Code,
  // MCP Inspector) : développement seulement, sur 127.0.0.1 (E16).
  if (pod.runMode == 'development') {
    final port =
        int.tryParse(Platform.environment['ASSISTANT_MCP_DEV_PORT'] ?? '') ??
        McpDevServer.defaultPort;
    try {
      await McpDevServer.start(pod, port: port);
      stdout.writeln('Assistant MCP dev server on http://127.0.0.1:$port/mcp');
    } on SocketException catch (error) {
      stderr.writeln('Assistant MCP dev server not started: $error');
    }
  }

  // Chaque étape à part : l'échec de l'une ne doit pas priver le serveur de
  // l'autre (des bots pour le Classé, des parties reprises).
  await pod.withSession((session) async {
    // Seed/refresh reference data that isn't user-generated (cf. E5).
    try {
      await seedBots(session);
    } catch (error, stackTrace) {
      session.log(
        'Bot seeding failed',
        level: LogLevel.error,
        exception: error,
        stackTrace: stackTrace,
      );
    }
    // Reprogramme les rappels des parties serveur perdus avec l'arrêt, et
    // libère les streams de partie qui l'attendent (même en cas d'échec).
    try {
      await ServerGame.resumePending(session);
    } catch (error, stackTrace) {
      session.log(
        'Resuming server games failed',
        level: LogLevel.error,
        exception: error,
        stackTrace: stackTrace,
      );
    }
  });
}
