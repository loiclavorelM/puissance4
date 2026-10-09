# Assistant, serveur MCP et tableau de bord modulable — analyse et version révisée

> Révision de `puissance4-assistant-mcp.md`, confrontée au code du dépôt (branche `develop`, octobre 2026). La partie 1 dit si c'est faisable et ce qui change. La partie 2 est la spec propre, à suivre pour l'implémentation. L'objectif, les règles et la correspondance avec le projet pro du document d'origine restent valables, sauf mention contraire.

---

## Partie 1 — Analyse de faisabilité

### Verdict

**Faisable, sans obstacle bloquant.** Le dépôt a déjà une bonne partie des fondations : un client Ollama Cloud avec la clé côté serveur, tous les coups enregistrés en base (y compris les parties Normal synchronisées), un canal temps réel par joueur et un module d'analyse de coups. Les nouveautés réelles sont le serveur MCP (`mcp_dart`), l'orchestrateur avec appels d'outils, le filtre de confidentialité et le package Flutter de tableau de bord.

Cinq points du document d'origine sont à corriger : l'un est un vrai conflit (port 8090), un autre une faille de sécurité (`userId` en paramètre d'outil). Les trois autres simplifient l'architecture.

### Ce qui existe déjà

| Besoin du document | Déjà dans le dépôt | Conséquence |
|---|---|---|
| Client Ollama Cloud, clé côté serveur | `review/review_config.dart` : `LlmClient`, `OllamaCloudClient`, `ollamaApiKey` et `ollamaModel` dans `passwords.yaml`, modèle par défaut `gpt-oss:120b` | On étend ce client (messages + outils) au lieu d'en écrire un deuxième. Le remplacement par un faux client en test est déjà prévu. |
| Limite d'appels par joueur | `ReviewEndpoint` : compte par heure sur `MoveExplanation` | Même schéma sur le journal de l'assistant. |
| Parties et coups en base | `Partie.moves` (Multi, Classé), `OfflineMatchResult.moves` (Normal, table `database: sync`) | L'hypothèse de la section 8 est vraie : pas de stockage de coups à ajouter. |
| Parties Normal lisibles par le serveur | `OfflineMatchResult.spaceId` → `offline_sync_spaces.id`, et l'espace personnel a `uuidSpaceId == authUserId` (`OfflineSyncSpace`, serverpod_offline_sync 0.0.8) | Lisibles par une jointure, mais seulement une fois synchronisées. À confirmer par un test d'intégration. |
| Signal « des données ont changé » | `LiveEndpoint.watchUpdates` + `LiveEvent` sans payload, canal par joueur (`live_notifier.dart`), déjà `historyChanged` | Inutile de créer `DataEndpoint.watch()` et un stream dans `DashboardEndpoint` : on ajoute `dashboardChanged` à `EnumLiveEventType`. |
| Analyse de partie (`analyze_game`) | `MoveAnalysis.of(moves, index)` et `HeuristicBot.scoreColumns` (`puissance4_rules`) | Le bonus devient quasi gratuit. |
| Cases jouées (`moves.byCell`) | `Connect4Rules.stacks(moves)` donne la ligne de chaque pion, `Connect4Rules.winningCells(moves)` l'alignement gagnant | Rien à ajouter aux règles. |
| Aperçus de widgets | Aperçus Flutter (`*_previews.dart`, par ex. `app_palette_previews.dart`) | On les utilise à la place de Widgetbook : une dépendance de moins, et la même pratique que le reste de l'app. |
| Tests serveur sans Docker | `serverpod_test`, base embarquée, `test/integration/*` | Les outils MCP et les sources se testent comme les endpoints existants. |

### Ce qui change par rapport au document d'origine

**1. Le port 8090 est pris.** `config/development.yaml` y met PostgreSQL (docker-compose), et Redis est sur 8091. Le serveur MCP de développement passe sur **8095**, configurable.

**2. `userId` comme paramètre d'outil : faille à supprimer.** Dans le document, l'outil MCP accepte un `userId` que l'orchestrateur ajoute, et on retire ce paramètre du schéma envoyé au LLM. Or le même serveur MCP est ouvert à MCP Inspector et à Claude Code : n'importe quel processus local pourrait alors lire ou modifier le tableau de bord de n'importe quel joueur. Il faut aussi maintenir deux schémas par outil.
→ **L'identité est liée à la connexion MCP, jamais à un argument.** Chaque `McpServer` est construit pour un joueur (`serverFactory` reçoit le contexte). Les schémas exposés au LLM sont alors exactement ceux du serveur MCP, sans retouche. Côté pro, c'est le `ClaimsPrincipal` du JWT, injecté par l'infrastructure : la transposition devient plus fidèle.

**3. L'orchestrateur n'a pas besoin de passer par HTTP.** Il tourne dans le même processus que le serveur MCP. Faire un aller-retour HTTP sur 127.0.0.1 ajoute un port, un serveur à superviser, une dépendance au nœud courant en cluster (Serverpod Cloud, Redis) et un risque d'usurpation (point 2).
→ **Client et serveur MCP reliés en mémoire** : deux `StreamController` branchés sur deux `IOStreamTransport` (mcp_dart). Le protocole MCP est conservé de bout en bout, donc on garde le catalogue auto-décrit, l'indépendance vis-à-vis du LLM et la frontière JSON. On évite seulement le réseau. Le transport HTTP n'existe qu'en **développement**, pour Inspector et Claude Code.

**4. Un seul transport HTTP partagé ne marche pas avec plusieurs clients.** C'était le point « à vérifier ». Il faut un `McpServer` par session ou par requête. mcp_dart 2.4.2 le fait avec `StreamableMcpServer(serverFactory: …)`, mais ce composant ne transmet pas l'identité authentifiée jusqu'aux outils. L'esquisse de la section 9 est donc remplacée par un petit serveur HTTP à nous, sans état, qui crée un `McpServer` lié au joueur à chaque requête (partie 2, section 7).

**5. Les streams en double.** `DataEndpoint.watch()` et le stream de `DashboardEndpoint` reproduisent `LiveEndpoint` (voir le tableau ci-dessus). On garde un seul canal temps réel par joueur.

Ajustements plus petits :

- **Modèles réels** : il n'y a ni `Player.displayName`, ni `Player.email`, ni `Game.chatMessages`. Les champs sensibles sont `User.username`, `User.friendCode`, `User.thumbnailPath` et `Partie.code`. Les e-mails vivent dans le module d'auth et aucune source ne les lit. `ai-exposure.json` est réécrit en conséquence (section 11).
- **Les bots ne sont pas des personnes.** Leur nom est public et utile au LLM (« tu perds surtout contre Expert »). La règle `opponent` pseudonymise donc les humains et laisse les noms de bots en clair.
- **Mode de jeu** : on ajoute un paramètre `mode` (`normal`, `classe`, `multi`) aux sources. Le Face à face n'est pas enregistré, il n'apparaît donc nulle part. Les parties `abandoned` sont exclues, comme dans l'Historique.
- **Elo** : on ajoute la source `elo.history`. C'est la courbe la plus naturelle de l'app, et `EloHistory` existe déjà.
- **Normal pas encore synchronisé** : le serveur ne voit pas une partie Normal jouée hors ligne avant sa synchronisation. Il faut le dire dans le prompt système (« les parties hors ligne apparaissent après synchronisation »). Pour rafraîchir les widgets, c'est l'app qui émet le signal à la fin d'une partie Normal, après sa synchronisation : le hook `onMergeSuccess` n'est pas accessible, car l'endpoint de synchro appartient au module.
- **Contrats JSON** : un dossier `contracts/` à la racine n'est lisible ni par l'app Flutter (les assets doivent être dans un package) ni par le serveur déployé (seul `puissance4_server` est envoyé). Ils vont donc dans un package `assistant_contracts`, qui les embarque en constantes Dart générées (section 5).
- **Règles du dépôt (`AGENTS.md`)** : `packages/assistant_ui` est volontairement hors de `features/`, puisqu'il doit être transposable. Il respecte quand même l'esprit des règles : textes dans ses propres ARB (fr, en), aucune couleur en dur, jetons de thème fournis par l'app à partir d'`AppPalette`. Le branchement côté app vit dans `features/assistant/{model,view,viewmodel}` avec Riverpod, comme les autres features.
- **Streaming token par token** : on l'abandonne dans la première version. `ChatModel.getResponse` suffit, et `getStreamingResponse` reste dans l'interface pour plus tard.
- **Grille 12 colonnes** : l'app vise d'abord le téléphone. Un `DashboardGrid` maison (`LayoutBuilder` : grille au-delà de 600 px, pile en dessous) évite `flutter_layout_grid`.

### Réponses aux points « à vérifier »

| Point | Réponse |
|---|---|
| Noms de l'API mcp_dart 2.4.2 | Confirmés : `McpServer(Implementation(...), options: McpServerOptions(...))`, `registerTool(name, description:, inputSchema:, annotations:, callback: (args, extra) async => CallToolResult(...))`, `TextContent`, `McpClient.listTools()` / `callTool(...)`. `JsonSchema.fromJson(map)` existe, ce qui permet de construire le schéma depuis les contrats. `ToolAnnotations` (lecture seule, destructif) existe aussi. Licence MIT. |
| Plusieurs clients MCP | Un `McpServer` par requête, lié au joueur authentifié : transport bas niveau `StreamableHTTPServerTransport` en mode sans état (partie 2, section 7). |
| Identité dans le serveur MCP de dev | Jeton Serverpod validé par `AuthServices.instance.authenticationHandler`, rafraîchi pour Claude Code par `headersHelper` (partie 2, section 7). |
| Format des messages `tool` d'Ollama | `{"role": "tool", "tool_name": "<nom>", "content": "<texte>"}`. Les appels arrivent dans `message.tool_calls[]` : `function.name`, `function.arguments` (un objet), `function.index`. La doc ne montre pas d'id, mais Ollama Cloud en renvoie un (`"id": "call_…"`, vu au lot 0). L'orchestrateur le reprend s'il est présent, et en génère un sinon. |
| Licences | `fl_chart` 1.2.0 : MIT. `mcp_dart` 2.4.2 : MIT. `flutter_layout_grid` et `widgetbook` : MIT, mais ne sont plus nécessaires. Aho-Corasick : écrit à la main (environ 80 lignes). |
| Modèle de données | Voir le tableau « Ce qui existe déjà » et la section 8. |

### Résultats du lot 0 (9 octobre 2026)

Tout a été vérifié par des scripts jetables et un test d'intégration, puis supprimés. Les conclusions sont reportées dans la partie 2.

| Vérification | Résultat |
|---|---|
| `McpServer` et `McpClient` en mémoire (`IOStreamTransport`) | Ça marche : protocole 2026-07-28 négocié, liste et appel d'outils. mcp_dart valide lui-même les arguments contre `inputSchema` et renvoie `isError` avec un message lisible (« Required property is missing: greeting »). |
| Serveur HTTP de dev, joueur lié à la requête | Ça marche avec les deux générations de protocole. Il faut deux chemins : sessions `initialize` (2025-11-25) liées au joueur qui les ouvre, et sans état pour 2026-07-28. Un serveur neuf à chaque requête ne suffit pas pour l'ancien protocole (« Server not initialized »). Une session reprise avec le jeton d'un autre joueur reçoit un 403, et un mauvais Host un 403 (protection DNS rebinding). |
| Claude Code comme client | `claude mcp list` : « ✔ Connected » avec un jeton valide, et un 401 explicite avec un mauvais jeton. |
| Jeton Serverpod hors endpoint | Test d'intégration : un JWT émis par `tokenManager.issueToken` est validé par `AuthServices.instance.authenticationHandler` et mène au bon `User`. Un jeton forgé donne `null`. |
| `headersHelper` | Documenté par Claude Code : relancé à chaque connexion et après un 401 ou un 403. `dart run` d'un script : 1,8 s une fois compilé (limite : 10 s). `client.emailIdp.login(email:, password:)` existe dans le client généré. |
| Parties Normal par l'espace personnel | Base de dev : les 29 `OfflineMatchResult` retrouvent toutes leur `User` par `offline_sync_spaces.uuidSpaceId = user.authUserId`. Il n'y a ni orphelin ni colonne de suppression. |
| Appel d'outil Ollama (`gpt-oss:120b`) | Aller-retour complet en 0,5 à 1 s par tour, environ 200 à 400 tokens en entrée. Ollama renvoie un id d'appel. Le résultat repart en `role: tool` avec `tool_name`. La réponse finale utilise du gras Markdown. |
| **Schéma imbriqué `params`** | **3 fois sur 3, le modèle invente les clés** (`opponentId`, `timeframe`, `since`/`until` en dates absolues), même avec `additionalProperties: false`. **Avec des arguments à plat**, 4 fois sur 4, c'est exact : `source`, `range: "this:month"`, et `opponent: "[Player:1]"` recopié tel quel. |

Ce que le lot 0 change dans la spec :

1. **Les arguments des outils sont à plat** (section 7) : pas d'objet `params`, ni `query`/`chart` imbriqués dans les arguments. L'outil transforme ces arguments en définition de widget (le contrat stocké garde sa forme imbriquée). Les schémas d'outils ont `additionalProperties: false`.
2. **Le serveur MCP de dev a deux chemins** (section 7).
3. **Les quatre `ToolAnnotations` sont toujours données explicitement** : par défaut, mcp_dart publie `destructiveHint: true` et `openWorldHint: true`.
4. **Le prompt système demande des formulations neutres pour les jetons** : le modèle a écrit « contre lui » pour `[Player:1]`.

### Risques

| Risque | Mesure |
|---|---|
| Qualité des appels d'outils selon le modèle Ollama | Lot 0 : un outil bidon sur `gpt-oss:120b`, puis `evals/` sur deux modèles avant de construire l'interface. Le modèle reste un mot de passe (`assistantModel`), modifiable sans redéployer. |
| Plafonds de l'offre gratuite Ollama | Limite par joueur et par heure, et coupure globale si la clé est absente (comme `ReviewException.notConfigured`). Les évals tournent hors `dart test`. |
| `mcp_dart` maintenu par une seule personne | Il est isolé derrière `assistant/mcp/`. Le reste ne voit que des fonctions d'outils pures. |
| `serverpod_offline_sync` en 0.0.x | La lecture des parties Normal est isolée dans un seul `GameRecordRepository`, couvert par un test. |
| Périmètre de cours | Nouvel epic **E16 `[hors cahier des charges]`**, sur une branche `feature/assistant`. Il ne touche à aucun écran existant, sauf pour ajouter une entrée de navigation. |

---

## Partie 2 — Spec révisée

### 1. Objectif

Inchangé : un assistant LLM (Ollama Cloud) pilote un tableau de bord modulable via un serveur MCP, avec pseudonymisation des données sensibles, et tout ce qui peut l'être reste transposable vers .NET, Flutter, REST et SignalR.

### 2. La fonctionnalité

Inchangée (section 2 d'origine). Le joueur compose son tableau de bord en parlant à l'assistant, qui répond aussi en texte, propose des graphiques à épingler, et ne voit jamais ni les coups bruts ni les noms des adversaires humains.

Réservée aux joueurs connectés, invités anonymes compris. Le tableau de bord suit le compte quand un invité le transforme en compte e-mail (`mergeGameUsers`).

### 3. Architecture

```
App Flutter ── chat(conversationId, inputJson) ──▶ AssistantEndpoint ──▶ Orchestrateur ──messages + outils──▶ Ollama Cloud
     ▲  ▲                                            (stream d'événements)      │  ◀── texte ou tool_calls ───
     │  │                                                                       │ privacy (entrée, arguments, résultats, sortie)
     │  │                                                                       ▼
     │  │                                               McpClient ══ en mémoire ══ McpServer (lié au joueur)
     │  │                                                                       │
     │  │                                                                       ▼
     │  │                                     AssistantTools (fonctions pures) → sources, tableau de bord (base Serverpod)
     │  │
     │  └── DataEndpoint.query(source, paramsJson) : données des widgets, sans LLM, vrais noms
     └───── LiveEndpoint.watchUpdates : dashboardChanged, historyChanged (existant)

En développement seulement : 127.0.0.1:8095/mcp (sans état, jeton Serverpod) ── MCP Inspector, Claude Code
```

Déroulé d'une demande :

1. L'app envoie à `AssistantEndpoint.chat` le texte et les mentions choisies dans l'autocomplétion.
2. L'orchestrateur ouvre une connexion MCP en mémoire liée au joueur authentifié et charge la liste des outils.
3. Il pseudonymise la question, puis envoie à Ollama le prompt système, l'historique (déjà pseudonymisé) et les outils.
4. Pour chaque appel d'outil : il rétablit les vraies valeurs dans les arguments, appelle l'outil via MCP, protège le résultat selon `ai-exposure.json`, puis le renvoie au LLM. 6 tours au maximum.
5. Pendant ce temps, il émet des événements : statut des outils, bloc de widget, texte rétabli, fin ou erreur. Une écriture sur le tableau de bord publie aussi `LiveEvent(dashboardChanged)`.
6. L'app recharge le tableau de bord, et chaque widget charge ses données via `DataEndpoint`.

### 4. Règles de conception

Celles du document d'origine, avec deux reformulations :

1. **Le LLM décide, le backend exécute.**
2. **L'identité vient de la connexion, jamais d'un argument.** Le `McpServer` est construit pour un joueur. Aucun outil n'a de paramètre `userId`, et les schémas envoyés au LLM sont ceux du serveur MCP, tels quels.
3. **Écritures** : le tableau de bord du joueur est modifié tout de suite, avec des versions annulables. Toute autre écriture est une proposition que le joueur confirme.
4. **Les données lourdes contournent le LLM** : un résultat d'outil contient au plus 20 lignes ou des statistiques.
5. **Un bloc du chat est une définition de widget** : même registre, bouton « Épingler ».
6. **Rien ne sort par la réponse** : ni image ni lien externe.
7. **Validation stricte, erreurs lisibles** : l'erreur dit quoi corriger.
8. **Chaque appel est tracé** : dans `AssistantRequestLog`, version avec jetons seulement. Jamais de prompt brut dans `session.log`.
9. **Le transport HTTP MCP n'existe qu'en développement**, sur 127.0.0.1, avec authentification.
10. **Les données sensibles sont pseudonymisées ou masquées** selon `ai-exposure.json`, par un filtre unique dans l'orchestrateur.

### 5. Organisation du dépôt

```
packages/
  assistant_contracts/                 # pur Dart, transposable : la source de vérité JSON
    contracts/
      widget-definition.schema.json
      data.schema.json
      chart-rules.json
      assistant-events.schema.json
      assistant-input.schema.json       # texte + mentions
      ai-exposure.json
      tools/*.json                      # nom, description, inputSchema, annotations
      prompts/system.md
      evals/requests.yaml
      fixtures/                         # définitions et données d'exemple (aperçus, goldens, tests)
    lib/assistant_contracts.dart        # constantes générées depuis contracts/ (String JSON)
    tool/generate.dart                  # contracts/ → lib/src/generated.dart
    test/in_sync_test.dart              # échoue si generated.dart est en retard sur contracts/
  assistant_ui/                         # Flutter, transposable : ni Serverpod, ni Riverpod
puissance4_server/lib/src/assistant/    # Serverpod : sources, outils, MCP, orchestrateur, privacy
puissance4_flutter/lib/features/assistant/{model,view,viewmodel}
```

- Les deux packages entrent dans le `workspace:` du `pubspec.yaml` racine, comme `puissance4_rules`.
- Règle vérifiable : ni `assistant_contracts` ni `assistant_ui` ne dépendent de Serverpod. Un test dans chaque package lit son `pubspec.yaml` et échoue sinon.
- On génère des constantes plutôt que de lire des fichiers à l'exécution, ce qui marche partout : serveur compilé AOT, Flutter web, tests. Le JSON reste la source de vérité recopiée telle quelle dans le projet pro.

### 6. Contrats

#### Définition de widget

Inchangée sur le fond (section 6 d'origine : `kpi`, `table`, `chart`, `query`, `chart` spec, `refresh`, `drilldown`, `display`, `layout`). Précisions :

- `id` : `w_` suivi de 8 caractères, attribué par le serveur, jamais par le LLM.
- `params` : plages relatives (`"range": "last:7d"`, `"this:week"`, `"this:month"`) ou `"lastGames": n` (de 1 à 200), jamais de dates absolues. `$dashboard.xxx` reprend un filtre du tableau de bord.
- `display` : jetons de thème `accent`, `success`, `warn`, `danger`, `neutral`, plus `rouge` et `jaune` (les couleurs des pions, résolues depuis `AppPalette`).
- `refresh.mode: live` : le widget recharge sur `historyChanged` (fin de partie, fusion d'une synchro Normal), au plus une fois toutes les `minIntervalSeconds`.

Exemple de carte de chaleur, qui reprend le dessin du plateau :

```json
{
  "type": "chart",
  "title": "Où je joue (30 dernières parties)",
  "query": { "source": "moves.byCell", "params": { "lastGames": 30, "who": "me" } },
  "chart": {
    "mark": "heatmap",
    "x": { "field": "column", "type": "category" },
    "y": { "field": "row", "type": "category" },
    "value": { "field": "count", "aggregate": "sum" }
  },
  "display": { "cell": "circle", "color": "rouge" }
}
```

#### Données et règles de graphiques

Inchangées (`kpi` ou `rows` typées, 2 000 lignes au maximum par source, `chart-rules.json`). Le serveur (outils) et `assistant_ui` (panneau « Modifier ») lisent tous deux `chart-rules.json` via `assistant_contracts`.

#### Événements de l'assistant

Inchangés, sauf un : `dashboardChanged` passe aussi par `LiveEvent` pour les autres appareils du joueur.

```json
{ "event": "toolStatus", "tool": "add_widget", "state": "started" }
{ "event": "dashboardChanged", "version": 12 }
{ "event": "block", "block": { "kind": "widget", "definition": { } } }
{ "event": "text", "text": "C'est fait : ..." }
{ "event": "done", "usage": { "inputTokens": 5400, "outputTokens": 180 } }
{ "event": "error", "code": "rateLimited" }
```

`error` porte un **code** (`notConfigured`, `unavailable`, `rateLimited`, `tooManySteps`), pas un texte : l'app le traduit, comme `ReviewException`.

### 7. Outils MCP

Ceux du document d'origine, sans `userId` :

Les arguments sont **à plat** (résultat du lot 0) : par exemple `add_widget(type, title, source, range, lastGames, mode, who, only, mark, x, y, value, color, colorLimit, stack, horizontal, refresh, slot)`. L'outil construit la définition de widget imbriquée du contrat. Chaque schéma a `additionalProperties: false`, et une clé inconnue reçoit une erreur qui nomme les clés valides.

| Outil | Annotation | Retour |
|---|---|---|
| `list_data_sources` | lecture seule | catalogue : sources, champs typés, paramètres |
| `get_dashboard` | lecture seule | version, filtres, définitions |
| `add_widget` | écriture | `id`, `version`, statistiques (nombre de lignes, valeurs distinctes par champ) |
| `update_widget` | écriture | `version`, statistiques |
| `remove_widget` | écriture, destructif | `version` |
| `arrange_widgets` | écriture | `version` |
| `undo_dashboard` | écriture | `version` |
| `set_dashboard_filters` | écriture | `version` |
| `query_data` | lecture seule | données tronquées (31 points, 20 lignes) |
| `analyze_game` (bonus) | lecture seule | 3 coups décisifs au plus : index, joué, recommandé, verdict (`MoveAnalysis`) |

Statistiques au lieu des données, erreurs actionnables et règles de choix du graphique : inchangées (section 7 d'origine).

Structure côté serveur :

```dart
/// Contexte d'un appel d'outil : qui, et avec quelle session. Jamais un argument.
final class ToolContext {
  ToolContext(this.session, this.user);
  final Session session;
  final User user;
}

/// Un outil = sa description (assistant_contracts) + une fonction pure.
typedef ToolHandler =
    Future<ToolOutcome> Function(ToolContext context, Map<String, Object?> args);

/// Construit un serveur MCP lié à un joueur. Utilisé en mémoire par
/// l'orchestrateur, et à chaque requête par le transport HTTP de développement.
/// Chaque appel d'outil ouvre sa propre session Serverpod.
McpServer buildAssistantMcpServer(Serverpod pod, User user) {
  final server = McpServer(
    const Implementation(name: 'puissance4', version: '0.1.0'),
  );
  for (final tool in AssistantContracts.tools) {
    server.registerTool(
      tool.name,
      description: tool.description,
      inputSchema: JsonSchema.fromJson(tool.inputSchema),
      annotations: tool.annotations,
      callback: (args, extra) => pod.withSession((session) async {
        final outcome = await assistantTools[tool.name]!(ToolContext(session, user), args);
        return outcome.toCallToolResult(); // isError + message actionnable si invalide
      }),
    );
  }
  return server;
}
```

Connexion en mémoire, utilisée par l'orchestrateur :

```dart
Future<McpClient> connectInMemory(McpServer server) async {
  final toServer = StreamController<List<int>>();
  final toClient = StreamController<List<int>>();
  await server.connect(IOStreamTransport(stream: toServer.stream, sink: toClient.sink));
  final client = McpClient(const Implementation(name: 'orchestrator', version: '0.1.0'));
  await client.connect(IOStreamTransport(stream: toClient.stream, sink: toServer.sink));
  return client;
}
```

Transport HTTP de développement, démarré par `server.dart` seulement si `runMode == development` et si `assistantMcpDevPort` est défini (8095).

`StreamableMcpServer` ne convient pas ici : son `authenticationHandler` répond seulement « accepté » ou « refusé », sans dire *qui*. `serverFactory(sessionId)` ne voit pas la requête, et l'`extra` des outils ne porte ni en-têtes ni principal. On écrit donc le petit serveur nous-mêmes. Il authentifie chaque requête, puis l'aiguille selon le protocole (vérifié au lot 0, avec Claude Code comme client) :

- **MCP 2025-11-25 (`initialize`)** : un transport avec session, enregistré avec le joueur qui l'a ouverte. Les requêtes suivantes portent `Mcp-Session-Id`, et une session présentée avec le jeton d'un autre joueur reçoit un 403.
- **MCP 2026-07-28** : sans état, avec un `McpServer` lié au joueur pour la seule requête.

```dart
/// Sessions MCP 2025-11-25 : transport + joueur qui l'a ouverte.
final _sessions = <String, ({StreamableHTTPServerTransport transport, UuidValue userId})>{};

Future<HttpServer> startMcpDevServer(Serverpod pod, {required int port}) async {
  final http = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  http.listen((request) async {
    if (request.uri.path != '/mcp') return _reply(request, HttpStatus.notFound);
    final user = await pod.withSession((s) => authenticateMcpRequest(s, request));
    if (user == null) return _reply(request, HttpStatus.unauthorized);

    final sessionId = request.headers.value('mcp-session-id');
    if (sessionId != null) {
      final session = _sessions[sessionId];
      if (session == null) return _reply(request, HttpStatus.notFound);
      if (session.userId != user.id) return _reply(request, HttpStatus.forbidden);
      return session.transport.handleRequest(request);
    }

    final body = request.method == 'POST'
        ? jsonDecode(await utf8.decodeStream(request))
        : null;
    final server = buildAssistantMcpServer(pod, user);

    if (body is Map && body['method'] == 'initialize') {
      late final StreamableHTTPServerTransport transport;
      transport = StreamableHTTPServerTransport(
        options: _options(
          sessionIdGenerator: generateUUID,
          onsessioninitialized: (sid) =>
              _sessions[sid] = (transport: transport, userId: user.id!),
        ),
      );
      await server.connect(transport);
      // connect() remplace transport.onclose : on nettoie via le serveur.
      final previous = server.server.onclose;
      server.server.onclose = () {
        previous?.call();
        _sessions.removeWhere((_, s) => identical(s.transport, transport));
      };
      return transport.handleRequest(request, body);
    }

    final transport = StreamableHTTPServerTransport(
      options: _options(sessionIdGenerator: () => null, enableJsonResponse: true),
    );
    await server.connect(transport);
    try {
      await transport.handleRequest(request, body);
    } finally {
      await server.close();
    }
  });
  return http;
}

// _options : enableDnsRebindingProtection: true, allowedHosts: {'127.0.0.1', 'localhost'}.
```

Les sessions vivent en mémoire, ce qui suffit à un outil de développement qui tourne sur un seul nœud. Côté .NET, le SDK MCP officiel gère lui-même les sessions derrière l'authentification ASP.NET Core, et le serveur est construit avec le `ClaimsPrincipal`.

**Authentification : de vrais jetons Serverpod.** On valide le jeton par le même chemin que les endpoints, `AuthServices.instance.authenticationHandler(session, token)` (qui appelle `tokenManager.validateToken`). `AuthenticationInfo.authUserId` donne ensuite le `User` :

```dart
Future<User?> authenticateMcpRequest(Session session, HttpRequest request) async {
  final header = request.headers.value(HttpHeaders.authorizationHeader);
  if (header == null || !header.startsWith('Bearer ')) return null;
  final info = await AuthServices.instance.authenticationHandler(session, header.substring(7));
  if (info == null) return null;
  return User.db.findFirstRow(session, where: (t) => t.authUserId.equals(info.authUserId));
}
```

Le jeton d'accès JWT expire au bout de 10 minutes (valeur par défaut de `JwtConfig`). Pour qu'il reste valide, on l'obtient par un script :

- `puissance4_server/tool/mcp_token.dart` se connecte avec un compte e-mail via le client généré et affiche `{"Authorization": "Bearer …"}`. Les identifiants viennent d'un fichier non versionné, car Claude Code retire de l'environnement les variables qui ressemblent à des secrets.
- Côté Claude Code, on le branche avec `headersHelper` dans `.mcp.json`. Claude Code le relance à chaque connexion, et aussi après un 401 ou un 403 sur un appel d'outil, puis réessaie une fois. L'expiration est ainsi gérée automatiquement. Le script doit répondre en moins de 10 secondes : on le compile, ou il garde le jeton en cache jusqu'à expiration.
- Pour MCP Inspector, on colle le jeton à la main (10 minutes suffisent).

Le lot 0 a vérifié cette chaîne. `mcp_token.dart` lit `assistantMcpDevEmail` et `assistantMcpDevPassword` dans `config/passwords.yaml` (section `development`, fichier non versionné) et appelle `client.emailIdp.login`. Le repli par secret statique n'est pas nécessaire.

### 8. Sources de données

Toutes reposent sur un seul `GameRecordRepository`, qui fusionne :

- `Partie` (Multi, Classé), avec `status == finished`, filtrée sur les `Player` du joueur ;
- `OfflineMatchResult` (Normal), avec `status == finished`, filtrée sur `spaceId` = l'espace dont `uuidSpaceId == authUserId`.

Il produit des `GameRecord { id, mode, playedAt, result, playedAs, moves, opponentKind (bot | human), opponentName, eloDelta? }`.

| Clé | Renvoie | Paramètres |
|---|---|---|
| `games.summary` | kpi : taux de victoire (delta sur la période précédente) | `range` ou `lastGames`, `mode`, `opponent` |
| `games.byDay` | lignes `day`, `result`, `count` | `range`, `mode` |
| `games.length` | lignes `moves`, `count` | `range` ou `lastGames`, `mode` |
| `moves.firstColumn` | lignes `column`, `count` | `lastGames`, `mode` |
| `moves.byCell` | lignes `row`, `column`, `count` (6 × 7) | `lastGames`, `who` (`me`, `opponent`), `only` (`all`, `winning`), `mode` |
| `results.byOpponent` | lignes `opponent`, `opponentKind`, `result`, `count` | `range`, `mode` |
| `games.recent` | lignes `id`, `playedAt`, `mode`, `opponent`, `result`, `moves` (nombre) | `limit` (20 au maximum), `mode` |
| `elo.history` | lignes `day`, `elo` | `range` |
| `streaks` | kpi : série en cours et record | `mode` |

- Colonnes affichées de 1 à 7 et lignes de 1 à 6 (bas = 1), comme dans `MovePrompt`.
- `moves.byCell` utilise les coups et `Connect4Rules.winningCells` (déjà dans `puissance4_rules`).
- `DataEndpoint.query(source, paramsJson) → String` (JSON de `data.schema.json`). Même code que `query_data`, mais sans troncature et sans filtre de confidentialité.

### 9. Backend Serverpod

`puissance4_server/lib/src/assistant/` :

```
assistant_endpoint.dart     # chat(conversationId, inputJson) → Stream<String>, listConversations, getMessages
dashboard_endpoint.dart     # get, saveWidget, removeWidget, undo, setFilters
data_endpoint.dart          # query, searchMentions
assistant_config.dart       # modèle, limites, ChatModel remplaçable en test (comme ReviewConfig)
sources/                    # GameRecordRepository + une classe par source
dashboard/                  # DashboardStore (versions), validation (chart-rules)
mcp/                        # buildAssistantMcpServer, connectInMemory, transport de dev
tools/                      # un handler par outil
orchestrator/               # ChatModel, OllamaChatModel, boucle
privacy/                    # ExposurePolicy, TokenMap, NameIndex (Aho-Corasick), PrivacyFilter
*.spy.yaml
```

Modèles (`.spy.yaml`) : le JSON des contrats est stocké en `String` pour rester transposable.

| Modèle | Champs principaux |
|---|---|
| `Dashboard` | `userId` (unique, `onDelete=Cascade`), `version`, `definitionJson`, `updatedAt` |
| `DashboardVersion` | `dashboardId`, `version`, `definitionJson`, `author` (`assistant` ou `player`), `createdAt`. On garde les 50 dernières. |
| `AssistantConversation` | `userId`, `createdAt`, `updatedAt` |
| `AssistantMessage` | `conversationId`, `index`, `role`, `contentJson` (**pseudonymisé**) |
| `AssistantToken` | `conversationId`, `token` (`[Player:1]`), `kind`, `refId` (`User.id`). La correspondance pointe vers l'id, jamais vers le nom en clair : le nom se relit au moment de rétablir. |
| `AssistantRequestLog` | `conversationId`, `userId`, `model`, `inputTokens`, `outputTokens`, `toolsJson`, `durationMs`, `errorCode`, `createdAt`. Sert aussi à la limite par heure. |

Les tables de correspondance sont en base, pas en mémoire : un autre nœud du cluster peut poursuivre la conversation. Le merge invité → compte (`guest_upgrade.dart`) rattache `Dashboard` et `AssistantConversation` au compte conservé.

`EnumLiveEventType` reçoit `dashboardChanged`. Pour les parties Normal, l'app émet elle-même le signal « données changées » après la synchronisation de fin de partie (`NormalGameRecorder.onFinished`).

#### Orchestrateur

Interface calquée sur `IChatClient`, comme dans le document d'origine. `OllamaChatModel` remplace `OllamaCloudClient` de `review/` : un seul client, et `LlmClient` (revue de coup) devient un cas particulier sans outils.

- `POST https://ollama.com/api/chat`, `stream: false`, `tools: [{type: function, function: {name, description, parameters}}]`.
- Réponse : `message.tool_calls[]` avec `id` (renvoyé par Ollama Cloud, généré par l'orchestrateur s'il manque) et `function.{name, arguments}`.
- Résultat d'outil renvoyé en `{role: "tool", tool_name, content}`, dans l'ordre des appels.
- Tokens : `prompt_eval_count` et `eval_count`.
- Prompt système stable, depuis `contracts/prompts/system.md`. Il demande des formulations neutres pour les jetons (`[Player:1]` peut désigner n'importe qui). La date du jour, la langue (`fr`, `en`) et le rappel sur les parties hors ligne vont dans le message utilisateur.

La boucle reste celle du document d'origine, mais sans `userId` dans `mcpCall`, puisque le client MCP est déjà lié au joueur :

```dart
final client = await connectInMemory(buildAssistantMcpServer(() async => context));
final tools = (await client.listTools()).tools; // envoyés tels quels au LLM
...
final result = await client.callTool(CallToolRequest(name: call.name, arguments: args));
```

### 10. Flutter

#### `packages/assistant_ui` (transposable)

Arborescence du document d'origine, avec ces ajustements :

- **Pas de gestionnaire d'état** : les contrôleurs (`DashboardController`, `ChartController`, `ChatController`) sont des `ChangeNotifier` du SDK, et l'app les enveloppe dans des providers Riverpod.
- **Thème** : `DashboardTokens extends ThemeExtension`. L'app la construit depuis `AppPalette`, en clair comme en sombre. Le package ne contient aucune couleur.
- **l10n** : ARB propres au package (`assistant_ui_fr.arb`, `assistant_ui_en.arb`), et l'app ajoute `AssistantUiLocalizations.delegate`. Les libellés des sources et des champs viennent des contrats (`label`), en fr et en en.
- **Graphiques** : `fl_chart` 1.2.0 pour les barres, courbes, aires et donuts. La carte de chaleur est un `CustomPainter` maison qui dessine les cases en ronds, comme le plateau.
- **Grille** : `DashboardGrid` maison (12 colonnes au-delà de 600 px, pile triée par (y, x) en dessous).
- **Aperçus et tests** : un aperçu Flutter par type de widget et par moteur de rendu (`*_previews.dart`), alimenté par `assistant_contracts/fixtures`, et des tests golden sur les mêmes fixtures.

Ports : ceux du document d'origine, sauf que `DataSourceClient.staleSources()` devient `Stream<void> dataChanged()`, alimenté par `historyChanged`.

#### `puissance4_flutter/lib/features/assistant/`

- `model/` : `ServerpodDashboardRepository`, `ServerpodDataSourceClient`, `ServerpodAssistantClient` (implémentations des ports sur `client.dashboard`, `client.data`, `client.assistant`, et `LiveEvent` pour les versions).
- `viewmodel/` : providers Riverpod qui exposent les contrôleurs du package et traduisent les codes d'erreur.
- `view/` : `AssistantScreen` (tableau de bord et chat en panneau), entrée de navigation à décider (onglet « Stats » ou accès depuis le Profil).

### 11. Données sensibles et pseudonymisation

Principe, filtre unique et cinq points d'application : inchangés (section 11 d'origine).

`ai-exposure.json` adapté aux vrais modèles :

```json
{
  "fields": {
    "opponent":         { "exposure": "pseudonymized", "kind": "Player", "except": "botNames" },
    "User.username":    { "exposure": "pseudonymized", "kind": "Player" },
    "User.friendCode":  { "exposure": "pseudonymized", "kind": "FriendCode" },
    "User.thumbnailPath": { "exposure": "hidden" },
    "Partie.code":      { "exposure": "hidden" },
    "AuthUser.*":       { "exposure": "hidden" }
  },
  "formats": {
    "FriendCode": "\\bP4-[A-Z0-9]{6}\\b",
    "RoomCode": "\\b[A-Z0-9]{6}\\b"
  },
  "self": "[Moi]"
}
```

- **Le nom du joueur lui-même** est aussi remplacé, par `[Moi]`.
- **Dictionnaire** : tous les `User.username` (ils sont uniques), sauf les noms de bots. On choisit tous les noms plutôt que les seuls adversaires du joueur : un nom tapé à la main ne doit pas fuiter même si ce n'est pas un adversaire. Normalisation, mot entier, plus longue correspondance, longueur minimale et liste de mots courants : comme dans l'original. L'index est reconstruit quand `updateUsername` réussit (et invalidé par un message global quand Redis est activé).
- **`RoomCode`** : la regex attrape aussi des mots ordinaires de 6 lettres majuscules. On l'applique seulement à une suite contenant au moins un chiffre. Remplacer un mot de trop gêne peu le LLM, alors qu'un code qui fuit est une vraie fuite.
- **Ordre de rétablissement** : les jetons des arguments d'outils redeviennent des **ids** (`opponent: [Player:1]` → `opponentUserId`). La source filtre par id, donc deux homonymes restent impossibles.

### 12. Correspondance avec le projet pro

Celle du document d'origine, avec ces lignes modifiées :

| Ici | Projet pro |
|---|---|
| `packages/assistant_contracts` (JSON + constantes générées) | `contracts/` recopié, et constantes générées en C# (source generator ou ressources incorporées) |
| `McpServer` construit par joueur, connexion en mémoire | SDK MCP C#, serveur dans le même processus avec un `ClaimsPrincipal` du scope DI |
| Transport HTTP de dev authentifié par jeton Serverpod | Endpoint MCP ASP.NET Core derrière l'authentification JWT existante |
| `LiveEvent` (`dashboardChanged`, `historyChanged`) | Hub SignalR, groupe par utilisateur |

### 13. Plan de réalisation

| Lot | Contenu | Critère de sortie |
|---|---|---|
| **0. Spike** (½ jour) — **fait le 9 octobre 2026** | Appel Ollama avec un outil bidon sur `gpt-oss:120b` ; `McpServer` et `McpClient` en mémoire ; serveur HTTP de dev sans état, authentifié par jeton Serverpod, vu depuis Claude Code (`headersHelper`) ; lecture d'un `OfflineMatchResult` via l'espace personnel | Les quatre fonctionnent |
| **1. Contrats et sources** | `assistant_contracts`, `GameRecordRepository`, les 9 sources, `DataEndpoint` | Tests d'intégration des sources (base embarquée), sans LLM |
| **2. Tableau de bord et MCP** | Modèles et migration, `DashboardStore` (versions, annulation), validation, outils, `dashboardChanged`, transport de dev | Tous les outils pilotables depuis Claude Code (`claude mcp add --transport http p4 http://127.0.0.1:8095/mcp`) |
| **3. `assistant_ui`** | KPI, tableau, 5 moteurs de rendu, grille, `WidgetFrame`, panneau « Modifier », aperçus et goldens ; branchement dans `features/assistant` | Tableau de bord composé à la main dans l'app, sans LLM |
| **4. Orchestrateur et confidentialité** | `ChatModel`, `OllamaChatModel` (fusion avec `review/`), boucle, filtre, journal, limite par heure, chat avec blocs épinglables | Tests de la boucle avec un faux `ChatModel` ; test « aucune valeur sensible dans les requêtes sortantes » |
| **5. Finitions** | Mentions et autocomplétion, filtres du tableau de bord, drilldown, `live`, `evals/` (`dart test -t eval --run-skipped`, hors suite normale) | Évals passées sur deux modèles, avec tokens et durées notés |
| **6. Bonus** | `analyze_game` | — |

Chaque lot se termine par la check-list d'`AGENTS.md` (analyse, formatage, migration, tests, logs) et une mise à jour du backlog (E16).

#### État au 9 octobre 2026 : lots 0 à 6 faits

| Lot | Commit | Tests |
|---|---|---|
| 0 | `542ff85` | spikes (supprimés), résultats ci-dessus |
| 1 | `9003bcd` | `assistant_contracts` (19), sources et `DataEndpoint` (12, base embarquée) |
| 2 | `cb8a2f4` | outils via client MCP en mémoire (9), serveur MCP de dev avec vrai JWT (3), `DashboardEndpoint` (6) |
| 3 | `f1a8c27` | `assistant_ui` (23 : séries, widgets, chat, panneau « Modifier », 8 goldens, transposabilité) |
| 4 | `ca1e051` | filtre de confidentialité (10), orchestrateur avec faux LLM (8) |
| 5 et 6 | ce lot | évals sur le vrai modèle (10 cas) |

Écarts par rapport à la spec :

- **Le modèle de domaine est dans `assistant_contracts`** (définitions, données, règles, arguments à plat, placement), en pur Dart, et pas dans `assistant_ui`. Le serveur et l'app partagent ainsi le même code de validation, comme `puissance4_rules` pour les règles du jeu.
- **Le catalogue des sources est dans le prompt système**, qui reste constant (voir les évals ci-dessous). `list_data_sources` reste disponible.
- **Outil `propose_widget`** : en plus des 10 outils d'origine, il montre un widget dans le chat sans l'ajouter (`block`), et le joueur l'épingle.
- **Événement `started`** : premier événement du stream, il porte l'id de la conversation créée.

#### Évals sur `gpt-oss:120b` (`dart test -t eval --run-skipped`)

| Passage | Réussite | Tokens d'entrée (demande simple) | Durée |
|---|---|---|---|
| Catalogue derrière `list_data_sources` | 7/9 (2 attentes trop étroites) | ~10 600 | 1,3 à 9,5 s |
| Catalogue dans le prompt système | 9/9 | ~7 600 | 1,6 à 3,3 s |
| Plus : description de `limit` précisée | 9/9, + `analyze_game` | ~7 900 | 1,6 à 3,6 s |

- **La confidentialité tient** sur tous les passages : « Kevin42 » et « kevin 42 » n'apparaissent dans aucune requête envoyée au modèle.
- **Le modèle se corrige en un tour** quand un outil refuse ses arguments (`type` manquant, paramètre absent de la source, `range` hors liste).
- **Pour comparer un autre modèle** : `ASSISTANT_EVAL_MODEL=<modèle> dart test -t eval --run-skipped`.

### 14. Outils utiles

- Serveur MCP Dart et Flutter : déjà configuré (`dart`).
- Serveur MCP du jeu, en développement, dans `.mcp.json` :

  ```json
  {
    "mcpServers": {
      "p4": {
        "type": "http",
        "url": "http://127.0.0.1:8095/mcp",
        "headersHelper": "dart run puissance4_server/tool/mcp_token.dart"
      }
    }
  }
  ```

  Ou MCP Inspector, avec un jeton collé à la main.

### Références

- mcp_dart 2.4.2 : https://pub.dev/packages/mcp_dart, `doc/transports.md` (StreamableHTTPServerTransport sans état, IOStreamTransport), `doc/tools.md`
- Appels d'outils Ollama : https://docs.ollama.com/capabilities/tool-calling
- Ollama Cloud : https://docs.ollama.com/cloud
- `headersHelper` de Claude Code : https://code.claude.com/docs/en/mcp
- Document d'origine : `doc/puissance4-assistant-mcp.md`
