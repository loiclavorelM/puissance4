# Puissance 4 — Connect Four with AlphaZero bots, built on Serverpod

A mobile-first Connect Four app (Flutter + Serverpod) where every bot is a neural
network **we trained ourselves** with AlphaZero-style self-play. It plays fully
offline on the phone, ranks you against server-validated bots, lets you play
friends in real time, and explains your mistakes with an LLM coach.

- **Web app:** https://puissance4.serverpod.space/
- **Android APK:** [latest release](https://github.com/loiclavorelM/puissance4/releases/latest)
- **Demo video:** _(link to add)_

<!-- Screenshots: add a few phone captures here (game, Normal level picker, ranked, review, dashboard). -->

## The problem

Casual Connect Four apps give you either a random bot or an unbeatable solver,
need a connection for everything, and never tell you *why* you lost. We wanted:

- opponents that feel human at every level, from "plays almost at random" to
  "thinks 800 moves ahead" — and that work on a plane;
- a ranked mode nobody can cheat;
- a coach that explains a bad move in plain words, and an assistant that
  builds your stats dashboard from a sentence.

## Features

| Mode / feature | What it does |
|---|---|
| **Normal** | 5 RL bots running **on the device**, playable offline; games sync to the server when back online. |
| **Ranked (Classé)** | Played **by the server**, which validates every move and picks the bot closest to your Elo (K = 32). |
| **Multiplayer** | Real-time 1v1 with a 6-character room code or an open-room lobby; challenge a friend in one tap. |
| **Face to face** | Two players on one phone, offered only when the phone **lies flat** on the table. |
| **Replay & review** | Every game is stored move by move; replay it, see the best move at each position and ask the LLM *why*. |
| **Friends** | Add by username, friend code, **QR code** or by **shaking both phones** at the same time; presence and head-to-head rivalries. |
| **Assistant & dashboard** | Ask "add a chart of my win rate against Expert": an LLM calls MCP tools to answer or to edit your dashboard. |
| **Everywhere** | Leaderboard, profile photo, guest mode, French/English, light/dark theme, shake to restart a game. |

## Technical highlights

### 1. Our own AlphaZero, from Colab to the phone *and* the server
- **Training** (`rl_training/notebooks/`): residual policy/value network
  (6 blocks × 64 channels, 448k parameters) trained by self-play with MCTS on
  Google Colab, resumable from Drive, evaluated against heuristic bots and its
  previous snapshots (estimated Elo gap). The 5 difficulty levels are 5
  snapshots × MCTS budget × temperature.
- **Export:** PyTorch → Keras → SavedModel → **TFLite**, checked output for
  output (PyTorch = Keras = TFLite).
- **On the phone:** `tflite_flutter` in a background isolate; the Expert runs
  **800 MCTS simulations per move** and answers almost instantly on a recent
  phone.
- **Same network in pure Dart:** `ConnectFourNet` reads the weights **directly
  from the `.tflite` flatbuffer** and recomputes the network with SIMD
  (`Float32x4`) — no native library. It matches TFLite to 1e-5 and is what the
  **Serverpod server** uses to play Ranked, and what the web build uses.
- **One shared brain:** rules, bot levels, MCTS and a tactical guard (win /
  block / never hand over a win) live in the pure-Dart package
  `puissance4_rules`, imported by both the app and the server.

### 2. Serverpod native authentication
Email sign-up/sign-in with the `serverpod_auth_idp` module and JWT sessions —
no Firebase. A **guest** is an anonymous `AuthUser` created as soon as the
server is reachable; "Create an account" then attaches the email identity to
that same `AuthUser`, so the profile, Elo, games and sync space are kept with
no data migration. Our own `User` model (username, photo, Elo) is linked to the
module's `AuthUser` through a nullable relation.

### 3. Offline-first with `database: sync`
Normal games are an `OfflineMatchResult` model declared `database: sync`
(**serverpod_offline_sync**): written to a local SQLite on the phone, merged
into PostgreSQL by CRDT when the connection comes back. Lesson learned: the
sync session's `persistentUserId` must equal the `authUserId`, or the server
silently drops every row.

### 4. Real-time, server-authoritative games
Multiplayer and Ranked are a server state machine (`ServerGame`): the database
is the source of truth, rows are locked per move, and every game in progress
always has a scheduled end (60 s per move, 15 s reconnection grace, resumed at
boot) — **no ghost games**. Clients follow a game through **Serverpod streams**;
presence, friend requests and "data changed" signals go through
`session.messages`. The in-memory pieces (scheduler, rooms, presence, shake
pairing) sit behind interfaces, ready for Redis in a cluster.

### 5. LLM coach and MCP assistant
- **Move explanations:** an exact negamax search finds the best move, then an
  LLM (Ollama Cloud, `gpt-oss:120b`, key kept server-side, rate-limited per
  player) explains it in natural language.
- **Assistant:** a chat backed by a **Model Context Protocol** server
  (`mcp_dart`) running inside Serverpod. Tools (game stats, Elo history,
  dashboard widgets…) are **bound to the authenticated player** — never a
  `userId` argument — and connected to the orchestrator by an in-memory
  transport. A privacy filter pseudonymises other players before anything
  reaches the LLM, and JSON contracts shared by server and app describe every
  tool and widget. Real-LLM evals run with `dart test -t eval`.
- A development-only MCP endpoint (`127.0.0.1:8095/mcp`) lets Claude Code or
  MCP Inspector query a player's data.

### 6. More Serverpod
File uploads to Serverpod cloud storage (profile photos), local caching
(leaderboard), generated client, `serverpod_test`
integration tests on an embedded PostgreSQL (no Docker), and deployment to
**Serverpod Cloud** — the server ships its models in `assets/`.

### 7. Context-aware mobile
Accelerometer (shake to restart, shake-to-add a friend, phone lying flat
unlocks Face to face), camera (QR scanner), connectivity (offline indicator,
sync on reconnect).

## Architecture

```
puissance4_flutter/   Flutter app — MVVM, feature-first (features/<f>/{model,view,viewmodel}), Riverpod
puissance4_server/    Serverpod server — one endpoint group per feature (lib/src/<f>/)
puissance4_client/    Client generated by Serverpod
puissance4_rules/     Pure Dart, shared: rules, bot levels, MCTS, ConnectFourNet, review search
packages/
  assistant_contracts JSON contracts (tools, widgets) shared by server and app
  assistant_ui        Dashboard and chat widgets (Flutter, no Serverpod)
rl_training/          Colab notebook: self-play training, evaluation, TFLite export
doc/                  Backlog, data model, endpoints, assistant spec, specification (LaTeX)
```

One game screen renders every mode: it only reads a `GameSnapshot` from a
`GameEngine` (local rules + on-device bot, server game, or replay).

## Run it locally

Requirements: Flutter ≥ 3.44, the Serverpod CLI 4.0.3, Docker (for the
development PostgreSQL and Redis).

```bash
cd puissance4_server
docker compose up -d            # PostgreSQL on 8090, Redis on 8091
serverpod start                 # server + Flutter app, migrations, hot reload
```

- The app reads its server URL from `puissance4_flutter/assets/config.json`
  (copy `config.example.json`; defaults to `http://localhost:8080`).
- The LLM features need an Ollama Cloud key: `ollamaApiKey` in
  `puissance4_server/config/passwords.yaml` (not committed).

### Tests
```bash
cd puissance4_rules && dart test     # rules, MCTS, Dart network vs TFLite parity
cd puissance4_server && dart test    # endpoints and game flows, embedded PostgreSQL
cd puissance4_flutter && flutter test
```

CI (GitHub Actions) lints and tests every pull request; merging into
`production` builds the web app and a signed APK, deploys to Serverpod Cloud
and publishes the APK as a GitHub release.
