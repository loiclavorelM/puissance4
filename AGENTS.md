# Flutter & Serverpod project

This project is a Flutter app (frontend) backed by a Serverpod server (backend). Always build the app's backend with Serverpod.
Build for multiple users. Authentication uses Serverpod's **native auth module** (`serverpod_auth_idp_*`, email identity provider + JWT sessions), already wired up by the `serverpod create` scaffold in `puissance4_server/lib/server.dart` and the generated `email_idp_endpoint.dart`/`jwt_refresh_endpoint.dart` — do NOT bridge to Firebase Auth. On the Flutter side, sign-in/sign-up/sign-out go through `SignInWidget` and `client.auth.*` (see the `serverpod-auth` skill), never custom endpoints. Game-specific profile data (username, thumbnail, Elo) lives in our own `User` model, linked to the module's `AuthUser` via a nullable `authUser` relation (nullable so a local guest — E0 — can exist before ever signing in).

## Architecture

Follow **MVVM, feature-first**, in both packages — see `doc/03-Backlog-Epics-UserStories.md` for the feature list and `doc/latex/cahier-des-charges.tex` for the full rationale:

- `puissance4_flutter/lib/features/<feature>/{model,view,viewmodel}` — required folder names for the course. `model` = plain business models/rules **and** repositories (Serverpod client calls, local storage), `view` = widgets, `viewmodel` = Riverpod Notifiers/Providers (state + presentation logic, testable without mounting a widget). No separate `UseCase` class per action, no full Clean Architecture ceremony.
- `puissance4_server/lib/src/<feature>/` — one endpoint group per feature/epic.
- New feature-specific code must be added inside the matching feature folder, not in global `screens/`, `models/`, `services/` folders. The one exception is `puissance4_flutter/lib/core/` (`theme/`, `widgets/`) for cross-cutting design-system pieces — the color palette (`AppColors`) and small reusable widgets shared across features (e.g. `ComingSoonTab`) — since duplicating those per feature is exactly what a design system exists to avoid.

The user starts the server and Flutter app with `serverpod start`. There is no need to check if the server is running: make the changes and call the `serverpod` MCP tools as needed. If the server is not running, an informative error message will be received from the MCP server. Then STOP and ask the user to start it. NEVER start the server yourself. The Flutter app is started along with it, or can be launched from the MCP tool `spawn_flutter_app`.

While running, `serverpod start` watches for file changes to run incremental code generation and hot reload both the server and the Flutter app.

Calling `serverpod generate` directly is not needed, but might be useful to troubleshoot when an incremental generation fails.

ALWAYS use the MCP server instead of the command line. Use the MCP server to:

- `create_migration` and `apply_migrations` for database (after you change data models).
- `create_repair_migration` if the database has drifted out of sync with the migrations.
- `tail_server_logs` to read logs from the server.
- `tail_flutter_logs` to read the raw stdout/stderr of the Flutter app.
- `hot_reload` / `hot_restart` to reload or restart the server and the Flutter app. ALWAYS call `hot_restart` after doing changes in the Flutter app that may not work with normal hot reload (which is automatically applied).
- `spawn_flutter_app` to start a Flutter app declared under `serverpod: flutter_apps:` in the server `pubspec.yaml`.
- `get_flutter_app_dtd` (Dart tooling daemon) for connecting to the app through the `dart` MCP.

NEVER edit generated code. The server's `lib/src/generated/` directory and the whole `puissance4_client` package are rewritten by the code generator. Change the `.spy.yaml` models, the endpoints, or `lib/server.dart` instead.

Migrations are a narrow exception: the `migration.sql` of a generated migration MAY be edited by hand when the generated SQL would lose data — to add a data transformation, or to reach a destructive change through non-destructive steps. Never touch the other files in the migration directory, and keep the schema the SQL ends up with identical to `definition.sql` — new databases are created from that file and never run `migration.sql`.

Only when the server cannot be started at all, fall back to the CLI in the server package:

- `serverpod generate` to regenerate the client and the generated server code.
- `serverpod create-migration` after changing a model with a `table` (add `--force` for destructive changes). It only writes the migration; `serverpod start` applies pending migrations when it boots the server.

Tests need no Docker. `config/test.yaml` sets `database.dataPath`, so Serverpod starts and manages the test database (an embedded PostgreSQL) itself, and the project's `docker-compose.yaml` is not used for it. Just run `dart test` in the server package.

Checklist after doing changes, in this order:

- `dart analyze` (CLI)
- `dart format` (CLI)
- `create_migration` and `apply_migrations` (MCP - only if necessary)
- Do `serverpod` MCP `hot_restart` if required (hot reload is done automatically). Will also hot restart Flutter app
- Run tests, if applicable (`dart test` in the server package)
- Check `serverpod` MCP `tail_server_logs` and `tail_flutter_logs` for any issues.

If the user asks you to test the app:

1. Use `get_flutter_app_dtd` (`serverpod` MCP) to get the Flutter app's DTD
2. Pass the DTD to `connect_dart_tooling_daemon` (`dart` MCP) to connect to the app
3. Use `flutter_driver` (`dart` MCP) to navigate through the app

The app is launched from `puissance4_flutter/lib/driver.dart`, which starts the Flutter driver extension with text entry emulation turned off so the app stays usable by hand. To let the driver type, set `enableTextEntryEmulation: true` there and `hot_restart` the app.

IMPORTANT: After building the first version of the app, update this AGENTS.md file with information about the app we're building. KEEP the info about the MCP server and the checklist. Remove this paragraph.
