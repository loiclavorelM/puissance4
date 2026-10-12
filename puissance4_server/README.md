# puissance4_server

Serverpod server of Puissance 4. See the [main README](../README.md) for the
features, the architecture and how to run the project locally.

```bash
docker compose up -d   # PostgreSQL (8090) and Redis (8091) for development
serverpod start        # server + Flutter app, migrations, hot reload
dart test              # integration tests on an embedded PostgreSQL, no Docker
```

- Endpoints: `doc/05-endpoints.md`; data model: `doc/04-entities.md`.
- Secrets (`config/passwords.yaml`, not committed): database, `ollamaApiKey`
  for the LLM features.
- `assets/models/`: the RL bots' `.tflite` models, played by the server in
  Ranked (`BotNetworks`) and deployed with it.
