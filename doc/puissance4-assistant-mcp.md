# Puissance 4 : assistant, serveur MCP et tableau de bord modulable

> Contexte préparé pour Claude Code. Projet perso : un prototype pour tester une technique.
>
> **Pour Claude Code :** lis le code existant du jeu avant de proposer quoi que ce soit. Adapte les sources de données aux modèles réels. Respecte la séparation entre `packages/assistant_ui` et Serverpod. Vérifie dans la documentation les points marqués « à vérifier » avant d'écrire le code qui en dépend.

## 1. Objectif

- Tester dans mon jeu Puissance 4 (Flutter + Serverpod) un **assistant LLM qui pilote un tableau de bord modulable** via un **serveur MCP**, avec un LLM d'**Ollama Cloud**.
- Tester aussi la **pseudonymisation des données sensibles** avant tout envoi au LLM.
- Tout ce qui peut l'être doit être **transposable** dans un projet pro : backend .NET (C#), front Flutter, API REST + SignalR. Le projet pro ne dépendra jamais de ce dépôt. On y recopiera ou réécrira les morceaux.
- Ce dépôt ne contient aucun code ni aucune donnée du projet pro.

## 2. La fonctionnalité

Le joueur compose son tableau de bord en parlant à l'assistant :

> « Ajoute mon taux de victoire, et à côté la carte des cases où je joue sur mes 30 dernières parties. »

L'assistant ajoute les deux widgets. L'app les affiche et charge elle-même leurs données : le LLM ne voit jamais la liste des coups.

- L'assistant répond aussi en texte, par exemple à « Combien de parties j'ai gagnées cette semaine ? ».
- Il peut proposer un graphique dans le chat, que le joueur épingle au tableau de bord.
- Les graphiques sont **dynamiques** : données en direct, interactions, et modification par le joueur lui-même.
- Les noms des adversaires n'atteignent jamais le LLM : ils sont remplacés par des jetons, puis rétablis dans la réponse affichée.

## 3. Architecture

```
App Flutter ──question──▶ AssistantEndpoint (Serverpod) ──messages + outils──▶ Ollama Cloud
     ▲                          │ ◀──── texte ou appel d'outil ────
     │ événements (stream)      │ appel d'outil (+ id du joueur)
     │                          ▼
     │                   Serveur MCP (mcp_dart, 127.0.0.1:8090/mcp, même process)
     │                          │
     │                          ▼
     │                   Base Serverpod (tableaux de bord, parties, coups)
     │
     └── données des widgets : DataEndpoint.query(source, params), sans LLM
```

Le filtre de confidentialité de l'orchestrateur s'applique à tout ce qui part vers Ollama et à tout ce qui en revient (section 11).

Le déroulé d'une demande :

1. L'app envoie la question à `AssistantEndpoint`, une méthode en stream : le texte, plus les mentions choisies dans l'autocomplétion.
2. L'orchestrateur pseudonymise la question, puis envoie à Ollama le prompt système, l'historique et la liste des outils MCP.
3. Le LLM répond par du texte ou par un appel d'outil.
4. L'orchestrateur rétablit les vraies valeurs dans les arguments, exécute l'appel sur le serveur MCP en ajoutant l'id du joueur, protège le résultat, le renvoie au LLM, et recommence (6 tours au maximum).
5. Pendant ce temps, il envoie des événements à l'app : statut des outils, tableau de bord modifié, texte avec les vraies valeurs, fin.
6. Quand le tableau de bord change, l'app recharge les définitions, et chaque widget charge ses données via `DataEndpoint`.

## 4. Règles de conception

1. **Le LLM décide, le backend exécute.** Le LLM n'accède ni à la base ni au serveur MCP : il demande des appels d'outils.
2. **L'identité vient du backend.** L'orchestrateur ajoute l'id du joueur à chaque appel. Le paramètre `userId` existe côté MCP, mais il est retiré du schéma envoyé au LLM.
3. **Écritures :** les modifications du tableau de bord du joueur s'appliquent tout de suite et sont annulables (versions). Toute autre écriture serait une proposition, que le joueur confirme dans l'app.
4. **Les données lourdes contournent le LLM.** Un widget est une définition, et l'app charge ses données. Les résultats d'outils restent petits : id, version, chiffres agrégés, 20 lignes au maximum.
5. **Un bloc du chat est une définition de widget.** Le chat l'affiche avec le même registre, et « Épingler » l'ajoute au tableau de bord.
6. **Rien ne sort par la réponse.** Le chat n'affiche ni image ni lien externe venant du LLM.
7. **Validation stricte, erreurs lisibles.** Un outil refuse une définition invalide avec un message qui dit quoi corriger. Le LLM se corrige au tour suivant.
8. **Chaque appel est tracé :** modèle, tokens, outils appelés, durée, erreurs.
9. **Le serveur MCP n'écoute que sur 127.0.0.1.** Seul le backend l'appelle, plus mes outils de test.
10. **Les données sensibles sont pseudonymisées ou masquées** avant tout envoi au LLM, selon `contracts/ai-exposure.json`.

Pourquoi MCP, même en interne : le catalogue d'outils se décrit lui-même, l'orchestrateur ne dépend pas du fournisseur de LLM, et les outils se testent sans LLM (MCP Inspector, Claude Code).

## 5. Organisation du dépôt

```
puissance4/
  contracts/                        # transposable tel quel
    widget-definition.schema.json   # dont la spec de graphique
    data.schema.json                # chiffre clé et lignes typées
    chart-rules.json                # règles de validité des graphiques
    assistant-events.schema.json
    ai-exposure.json                # niveau d'exposition de chaque champ
    tools/*.json                    # nom, description et schéma d'entrée de chaque outil
    prompts/system.md
    evals/requests.yaml
    fixtures/                       # définitions et données d'exemple (Widgetbook, tests)
  packages/assistant_ui/            # transposable : aucune dépendance à Serverpod
  puissance4_server/                # Serverpod : sources, serveur MCP, orchestrateur
  puissance4_client/                # généré par Serverpod
  puissance4_flutter/               # l'app : branche assistant_ui sur le client Serverpod
```

Règle vérifiable : `packages/assistant_ui/pubspec.yaml` ne dépend pas de Serverpod. S'il compile sans, il est transposable.

## 6. Contrats

### Définition de widget

Trois types : `kpi` (chiffre clé), `table` et `chart`. Un graphique est décrit par une **spec** : l'assistant (ou le joueur) dit quoi montrer et comment, l'app le dessine, et les données viennent de la source.

```json
{
  "id": "w_2b71",
  "type": "chart",
  "title": "Mes parties par jour",
  "query": { "source": "games.byDay", "params": { "range": "$dashboard.range" } },
  "chart": {
    "mark": "bar",
    "x": { "field": "day", "type": "temporal", "unit": "day" },
    "y": { "field": "count", "aggregate": "sum" },
    "color": { "field": "result", "limit": 3 },
    "stack": true
  },
  "refresh": { "mode": "live", "minIntervalSeconds": 5 },
  "drilldown": { "to": "list", "source": "games.recent", "filterField": "day" },
  "layout": { "x": 0, "y": 0, "w": 8, "h": 4 }
}
```

La carte de chaleur du plateau, avec la même spec :

```json
"query": { "source": "moves.byCell", "params": { "lastGames": 30, "who": "me" } },
"chart": {
  "mark": "heatmap",
  "x": { "field": "column", "type": "category" },
  "y": { "field": "row", "type": "category" },
  "value": { "field": "count", "aggregate": "sum" }
},
"display": { "cell": "circle", "color": "accent" }
```

- `id` : attribué par le serveur, jamais par le LLM.
- `query` : une source déclarée par `list_data_sources`, avec ses paramètres. Le serveur refuse les autres.
- `params` : des plages relatives (`"range": "last:7d"`) ou un nombre de parties (`"lastGames": 30`), jamais de dates absolues. Une valeur `$dashboard.xxx` reprend un filtre du tableau de bord.
- `chart.mark` : `bar` (vertical ou `horizontal`, groupé ou `stack`), `line`, `area`, `donut` ou `heatmap`.
- `chart.x`, `chart.y`, `chart.color`, `chart.value` : quelle colonne va où. `color` découpe en séries, avec un top N (`limit`) et une catégorie « Autres » (`others`).
- `refresh` : `live` (avec un intervalle minimal), `interval` ou `manual`.
- `drilldown` : ce qui s'ouvre au clic sur une barre ou un point.
- `display` : des jetons du thème (`accent`, `success`, `warn`, `danger`, `neutral`), jamais de couleur en dur. `cell: circle` dessine les cases en ronds, comme le plateau.
- `layout` : une grille de 12 colonnes (`x` de 0 à 11, `w` de 1 à 12, `h` de 1 à 8). Sans `layout`, le serveur place le widget dans la première place libre.

### Données

Les sources renvoient soit un chiffre clé, soit des **lignes typées**. Les tableaux et les graphiques reçoivent des lignes, et l'app les répartit en séries selon la spec. N'importe quelle source tabulaire peut ainsi donner n'importe quel graphique.

```json
{ "kind": "kpi", "value": 62, "unit": "%", "delta": 4, "label": "Taux de victoire" }

{
  "kind": "rows",
  "fields": [
    { "name": "day", "type": "temporal", "label": "Jour" },
    { "name": "result", "type": "category", "label": "Résultat" },
    { "name": "count", "type": "number", "label": "Parties" }
  ],
  "rows": [["2026-10-10", "win", 3], ["2026-10-10", "loss", 1]]
}
```

Plafond : 2 000 lignes par source. Au-delà, la source doit agréger davantage.

### Règles de validité des graphiques (`chart-rules.json`)

Lues par le serveur (validation des outils) et par l'app (panneau « Modifier »), pour que les deux appliquent les mêmes règles.

```json
{
  "bar":     { "x": ["temporal", "category"], "y": ["number"], "maxCategories": 30 },
  "line":    { "x": ["temporal"], "y": ["number"] },
  "area":    { "x": ["temporal"], "y": ["number"] },
  "donut":   { "x": ["category"], "y": ["number"], "maxCategories": 6 },
  "heatmap": { "x": ["category"], "y": ["category"], "value": ["number"] }
}
```

### Événements de l'assistant (stream vers l'app)

```json
{ "event": "toolStatus", "tool": "add_widget", "state": "started" }
{ "event": "dashboardChanged", "version": 12 }
{ "event": "block", "block": { "kind": "widget", "definition": { } } }
{ "event": "text", "text": "C'est fait : ..." }
{ "event": "done", "usage": { "inputTokens": 5400, "outputTokens": 180 } }
{ "event": "error", "message": "..." }
```

## 7. Outils MCP

| Outil | Rôle | Retour |
|---|---|---|
| `list_data_sources` | sources, champs (nom, type, libellé), paramètres | catalogue |
| `get_dashboard` | widgets, disposition et filtres du joueur | version et définitions |
| `add_widget` | ajoute un widget (sans `id`) | `id`, `version` et des statistiques sur les données |
| `update_widget` | modifie le titre, la requête, la spec, le display ou le layout | `version` et statistiques |
| `remove_widget` | supprime un widget | `version` |
| `arrange_widgets` | déplace et redimensionne plusieurs widgets | `version` |
| `undo_dashboard` | revient à la version précédente | `version` |
| `set_dashboard_filters` | période, adversaire, mode de jeu, repris par les widgets liés | `version` |
| `query_data` | interroge une source pour répondre en texte, résultat tronqué (31 points, 20 lignes) | données |
| `analyze_game` (bonus) | passe une partie dans l'évaluation de l'IA du jeu et repère les coups qui l'ont fait basculer | liste courte de coups |

- **Statistiques au lieu des données :** `add_widget` et `update_widget` renvoient le nombre de lignes et le nombre de valeurs distinctes par champ, jamais les lignes. Par exemple : « `opponent` a 47 valeurs ». Le LLM ajuste alors la spec (top 10, barres horizontales).
- **Erreurs actionnables :** « une courbe demande un axe x temporel », « le donut accepte 6 parts au maximum : utilise des barres ou un top 5 ».
- **Règles de choix**, dans la description de `add_widget` :
  - le temps se montre en courbe ou en barres ;
  - une comparaison de catégories se montre en barres horizontales triées ;
  - une part d'un tout se montre en donut, s'il y a 6 parts au plus ;
  - deux dimensions se montrent en carte de chaleur.

## 8. Sources de données

À adapter aux modèles existants du jeu.

| Clé | Renvoie | Paramètres |
|---|---|---|
| `games.summary` | kpi | `range` ou `lastGames`, `opponent` |
| `games.byDay` | lignes : `day`, `result`, `count` | `range` |
| `games.length` | lignes : `moves`, `count` (histogramme du nombre de coups) | `range` ou `lastGames` |
| `moves.firstColumn` | lignes : `column`, `count` | `lastGames`, `who` |
| `moves.byCell` | lignes : `row`, `column`, `count` (6×7) | `lastGames`, `who` (`me`, `opponent`), `only` (`all`, `winning`) |
| `results.byOpponent` | lignes : `opponent`, `result`, `count` | `range` |
| `games.recent` | lignes (tableau) | `limit` (20 au maximum) |
| `streaks` | kpi | aucun |

Hypothèse : les parties et les coups sont stockés en base. Si ce n'est pas le cas, proposer d'abord d'ajouter le stockage des coups.

## 9. Backend Serverpod

### Endpoints

- `DataEndpoint.query(source, params)` : renvoie les données en JSON (chaîne). Utilisé par les widgets, avec les vraies valeurs : ces données ne passent pas par le LLM.
- `DashboardEndpoint` : `get`, `saveWidget` (panneau « Modifier »), `undo`, `setFilters`, et une méthode en stream qui signale les nouvelles versions (messages Serverpod sur un canal par joueur).
- `DataEndpoint.watch()` : méthode en stream qui signale les sources dont les données ont changé (par exemple à la fin d'une partie), au plus une fois toutes les quelques secondes par source.
- `AssistantEndpoint.chat(conversationId, input)` : méthode en stream qui renvoie les événements de la section 6. `input` contient le texte et les mentions.

Stockage : le tableau de bord en JSON (chaîne) avec un numéro de version, et les versions précédentes pour l'annulation. Garder le JSON des contrats plutôt que des classes Serverpod, pour rester transposable.

### Serveur MCP (mcp_dart)

- Package `mcp_dart` (2.4.x), côté serveur : `McpServer`, `registerTool`, `StreamableHTTPServerTransport`.
- Le transport prend une `HttpRequest` de `dart:io` (`transport.handleRequest(request)`). On ouvre donc un `HttpServer` à côté de Serverpod, dans le même process, sur `127.0.0.1:8090`, chemin `/mcp`.
- Dans les outils, l'accès à la base passe par `pod.createSession()`. Penser à fermer la session.
- Les noms, descriptions et schémas d'entrée viennent de `contracts/tools/*.json`.

Esquisse, avec des noms tirés de la doc mcp_dart 2.4.2 (à vérifier) :

```dart
final mcp = McpServer(
  const Implementation(name: 'puissance4', version: '0.1.0'),
  options: const McpServerOptions(
    capabilities: ServerCapabilities(tools: ServerCapabilitiesTools()),
  ),
);

mcp.registerTool(
  'add_widget',
  description: '...', // depuis contracts/tools/add_widget.json
  inputSchema: JsonSchema.object(properties: {/* ... */}),
  callback: (args, extra) async {
    final session = await pod.createSession();
    try {
      // valider avec chart-rules.json, enregistrer la nouvelle version, publier dashboardChanged
      return CallToolResult(content: [TextContent(text: '{"id":"w_2b71","version":12}')]);
    } finally {
      await session.close();
    }
  },
);

final transport = StreamableHTTPServerTransport(
  options: StreamableHTTPServerTransportOptions(sessionIdGenerator: () => generateUUID()),
);
await mcp.connect(transport);

final http = await HttpServer.bind(InternetAddress.loopbackIPv4, 8090);
http.listen((request) async {
  if (request.uri.path == '/mcp') {
    await transport.handleRequest(request);
  } else {
    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
  }
});
```

À vérifier : si plusieurs clients se connectent (orchestrateur et MCP Inspector), il faut peut-être une instance de transport par session MCP. Voir le guide des transports de mcp_dart.

### Orchestrateur

Une interface `ChatModel` calquée sur `IChatClient` (Microsoft.Extensions.AI), pour que la boucle se traduise ligne à ligne en C# :

```dart
abstract interface class ChatModel {
  Future<ChatResponse> getResponse(List<ChatMessage> messages, ChatOptions options);
  Stream<ChatResponseUpdate> getStreamingResponse(List<ChatMessage> messages, ChatOptions options);
}
```

Implémentation `OllamaChatModel` :

- `POST https://ollama.com/api/chat`, avec l'en-tête `Authorization: Bearer $OLLAMA_API_KEY`.
- Les outils passent dans le champ `tools`, au format `{ "type": "function", "function": { "name", "description", "parameters" } }`.
- Les appels arrivent dans `message.tool_calls`, avec des arguments en objet JSON. Les résultats repartent dans des messages `role: tool`.
- Si Ollama ne fournit pas d'id d'appel, en générer un.
- Tokens : `prompt_eval_count` (entrée) et `eval_count` (sortie).
- À vérifier : le format exact des messages `tool` dans la doc de l'API Ollama.

Client MCP : `McpClient` de mcp_dart avec `StreamableHttpClientTransport` vers `http://127.0.0.1:8090/mcp`. La liste des outils est chargée une fois par conversation.

La boucle, avec le filtre de confidentialité (`privacy`, section 11) :

```dart
Stream<AssistantEvent> chat(int userId, String conversationId, ChatInput input) async* {
  final tokens = await tokenMaps.forConversation(conversationId); // jetons de la conversation
  final tools = await toolsForLlm(); // outils MCP, sans le paramètre userId
  final messages = [
    ChatMessage.system(systemPrompt),
    ...await history(conversationId), // déjà pseudonymisé
    ChatMessage.user(privacy.pseudonymizeInput(input, tokens)), // mentions, dictionnaire, formats
  ];
  for (var turn = 0; turn < 6; turn++) {
    final response = await model.getResponse(
      privacy.guardEgress(messages, tokens), // dernier contrôle avant l'envoi
      ChatOptions(model: modelId, tools: tools),
    );
    messages.add(response.message);
    if (response.toolCalls.isEmpty) {
      yield TextEvent(privacy.restoreText(response.text, tokens));
      yield DoneEvent(response.usage);
      return;
    }
    for (final call in response.toolCalls) {
      yield ToolStatusEvent(call.name, ToolState.started);
      final args = privacy.restoreArguments(call.arguments, tokens); // jetons → vraies valeurs
      final result = await mcpCall(call.name, {...args, 'userId': userId});
      messages.add(ChatMessage.toolResult(call.id, privacy.protectResult(call.name, result.text, tokens)));
      yield ToolStatusEvent(call.name, result.isError ? ToolState.failed : ToolState.done);
      if (result.dashboardVersion case final version?) yield DashboardChangedEvent(version);
    }
  }
  yield ErrorEvent("Trop d'étapes : reformule la demande.");
}
```

- Le prompt système reste stable, sans date ni donnée variable. La date du jour et le contexte vont dans le message utilisateur. Chez les fournisseurs pro, c'est ce qui permet le cache de prompt.
- Journal par demande : conversation, joueur, modèle, tokens, outils appelés, durée, erreurs. Le journal garde la version avec jetons.
- La clé Ollama reste côté serveur (variable d'environnement ou `config/passwords.yaml`), jamais dans l'app.

## 10. Flutter : packages/assistant_ui

```
lib/
  domain/    WidgetDefinition, ChartSpec, Dashboard, DashboardFilters,
             KpiData, DataSet (champs typés + lignes), AssistantEvent, ChatBlock, ChatInput, Mention
  ports/     DashboardRepository, DataSourceClient, AssistantClient
  registry/  WidgetRegistry : type → builder
  widgets/   KpiCard, TableWidget, ChartWidget
  charts/    BarRenderer, LineRenderer (line, area), DonutRenderer, HeatmapRenderer,
             répartition en séries, top N et « Autres »
  view/      DashboardGrid, DashboardFilterBar, WidgetFrame, ChartEditor (panneau « Modifier »),
             ChatPanel (saisie avec mentions), BlockRenderer
  theme/     DashboardTokens (ThemeExtension) : accent, success, warn, danger, neutral
```

Les ports :

```dart
abstract interface class DashboardRepository {
  Future<Dashboard> load();
  Stream<int> versions(); // une nouvelle version est disponible
  Future<void> saveWidget(WidgetDefinition definition); // panneau « Modifier » et « Épingler »
  Future<void> setFilters(DashboardFilters filters);
  Future<void> undo();
}

abstract interface class DataSourceClient {
  Future<Object> query(String source, Map<String, Object?> params); // KpiData ou DataSet
  Stream<String> staleSources(); // sources dont les données ont changé
  Future<List<Mention>> searchMentions(String text); // autocomplétion du chat
}

abstract interface class AssistantClient {
  Stream<AssistantEvent> send(String conversationId, ChatInput input);
}
```

Règles générales :

- Les modèles Dart sont écrits à partir des schémas de `contracts/`, à la main ou avec json_serializable. Jamais les classes générées par Serverpod.
- `DashboardGrid` : 12 colonnes, placement en x/y/w/h (par exemple avec `flutter_layout_grid`). Sur un écran étroit, les widgets s'empilent dans l'ordre (y, x).
- `WidgetFrame` : chargement, erreur avec réessai, état vide, menu (modifier, retirer, renommer).
- Chat : Markdown limité (gras, listes), sans image ni lien externe. Les blocs `widget` passent par le registre, avec un bouton « Épingler ».
- Widgetbook : un cas d'usage par type de widget et par moteur de rendu, alimenté par `contracts/fixtures`, plus des tests golden.
- Gestionnaire d'état : pas encore aligné sur le front pro, que je ne connais pas encore. Le domaine, les ports, le registre et les widgets n'en dépendent pas. Seuls les contrôleurs, minces, l'utilisent.

Graphiques :

- **Un seul `ChartWidget`** aiguille vers les moteurs de rendu selon `mark` : barres, courbes et donut avec `fl_chart`, carte de chaleur maison. La répartition en séries, le top N, les couleurs du thème, les infobulles et la légende sont communs.
- **La spec enregistrée et l'état temporaire sont séparés** (`ChartController`). Une série masquée, un survol ou un détail ouvert ne modifient pas la spec. Seul le panneau « Modifier » l'enregistre, comme une nouvelle version annulable.

Graphiques dynamiques, à trois niveaux :

1. **Données en direct.** En mode `live`, `staleSources()` marque une source comme périmée, et le widget recharge au plus une fois toutes les `minIntervalSeconds`. Les plages relatives sont recalculées à chaque rafraîchissement, donc la fenêtre glisse toute seule.
2. **Interactions.** Infobulles, clic sur la légende pour masquer une série, sélecteur de période (1 h, 24 h, 7 j, 30 j), clic sur une barre pour ouvrir le `drilldown`. Les filtres du tableau de bord (`DashboardFilterBar`) forment un état commun : les paramètres en `$dashboard.xxx` les reprennent, et un clic sur un adversaire dans un widget peut filtrer tous les autres.
3. **Modification par le joueur, comme un graphique croisé dynamique.** Le panneau « Modifier » propose le type, l'axe X, la mesure et l'agrégation, le découpage en séries, le top N, la période. Il ne montre que les choix valides, d'après `chart-rules.json` et les types des champs. L'assistant et le joueur modifient le même objet.

Implémentations dans `puissance4_flutter` : `ServerpodDashboardRepository`, `ServerpodDataSourceClient`, `ServerpodAssistantClient`.

## 11. Données sensibles et pseudonymisation

Pour le LLM, on ne chiffre pas : on **remplace** les valeurs sensibles par des jetons, par exemple `[Player:1]`, et la correspondance reste sur le serveur. Le LLM peut toujours compter, filtrer et regrouper sur un jeton.

### Déclarer, sans code dans chaque outil

Chaque champ a un niveau d'exposition : **visible**, **pseudonymisé** ou **masqué** (le LLM ne sait même pas que le champ existe). Pour le puissance 4, à adapter aux vrais modèles :

```json
{
  "Player.displayName": { "exposure": "pseudonymized", "kind": "Player" },
  "Player.email": { "exposure": "hidden" },
  "Game.chatMessages": { "exposure": "hidden" }
}
```

### Un seul filtre, dans l'orchestrateur

Il intervient à cinq endroits, et les outils n'en savent rien :

1. **la question de l'utilisateur**, dont les noms connus sont remplacés par leurs jetons ;
2. **les arguments des outils**, où les jetons redeviennent les vraies valeurs ou les vrais id avant l'exécution ;
3. **les résultats des outils**, où les valeurs sont pseudonymisées ou retirées selon `ai-exposure.json` ;
4. **la réponse affichée**, où les jetons redeviennent les vrais noms ;
5. **le journal**, qui ne garde que la version avec jetons.

Tout ce qui est enregistré (spec de widget, proposition) est remis avec les vraies valeurs ou les vrais id avant d'être sauvegardé. Les widgets et les données de `DataEndpoint` ne passent pas par le LLM : ils affichent les vrais noms, sans traitement.

### Repérer les noms dans la question

On connaît déjà les valeurs sensibles, puisqu'elles sont en base : pas besoin d'IA pour les repérer, un dictionnaire suffit.

1. **Les mentions dans la saisie (le plus fiable).** Pendant la frappe, le chat propose une autocomplétion (`searchMentions`). Si le joueur choisit « Kevin42 », l'app insère une pastille qui porte `{ type: "Player", id: 17 }`. Le message part avec le texte et la liste des mentions, et le backend attribue les jetons sans rien deviner.
2. **Le dictionnaire, pour les noms tapés à la main.**
   - Un index des valeurs pseudonymisées, avec l'algorithme d'Aho-Corasick : son temps de recherche dépend de la longueur du message, pas du nombre de noms. L'index est en cache, et il est reconstruit quand une valeur change.
   - Normalisation : minuscules, sans accents, apostrophes et tirets unifiés. Chaque nom est aussi indexé sans espaces, pour que « kevin 42 » trouve « Kevin42 ».
   - Mot entier seulement, et la correspondance la plus longue gagne.
   - Une longueur minimale et une liste de mots courants : un joueur nommé « Max » ne doit pas remplacer chaque « max » du texte. Pour ces noms-là, on compte sur les mentions.
3. **Les formats**, pour les identifiants absents du dictionnaire : une expression régulière par format, si le jeu en a (codes de partie, par exemple).

Exemple :

> « Est-ce que j'ai déjà battu kevin 42 ce mois-ci ? »

devient, pour le LLM :

> « Est-ce que j'ai déjà battu [Player:1] ce mois-ci ? »

### La table de correspondance

- Par conversation, côté serveur.
- Une valeur garde le même jeton pendant toute la conversation, pour que le LLM suive de quoi on parle.
- Le jeton pointe vers la valeur, et vers l'id quand il est connu (mention). Si deux joueurs ont le même nom, l'outil filtre par nom.

### Le dernier contrôle

Juste avant chaque envoi à Ollama (`guardEgress`), on repasse le même dictionnaire sur toute la requête : historique, résultats d'outils et texte libre compris. Si une valeur sensible a échappé aux étapes précédentes, elle est remplacée à ce moment-là.

### Les limites

- **Le LLM perd le sens des noms.** Si une information utile se cache dans un nom, il faut l'exposer dans un autre champ, non sensible.
- **Les fautes de frappe** (« Kevn42 ») passent au travers. Avant l'envoi, l'app peut souligner un mot proche d'un nom connu et proposer « Vouliez-vous dire Kevin42 ? », ce qui le transforme en mention.
- **Le texte libre** peut contenir les noms n'importe où : on le passe au dictionnaire, ou on le masque.
- **L'asymétrie des erreurs :** remplacer un mot ordinaire par erreur gêne un peu le LLM, alors que rater un nom fait fuiter une donnée. Il vaut donc mieux régler les seuils pour remplacer un peu trop que pas assez.

## 12. Correspondance avec le projet pro

| Ici | Projet pro |
|---|---|
| `contracts/` | recopié tel quel |
| `packages/assistant_ui` | recopié, adapté au gestionnaire d'état et au thème du front pro |
| Endpoints Serverpod | contrôleurs ASP.NET Core, queries et commandes |
| `query_data` et sources nommées | OData sur des entités choisies (DTO projetés, agrégats) |
| `mcp_dart` | SDK MCP officiel pour C# (`ModelContextProtocol`) |
| `ChatModel` et `OllamaChatModel` | `IChatClient` (Microsoft.Extensions.AI) et le fournisseur choisi |
| Méthodes en stream Serverpod | SignalR |
| Implémentations Serverpod des ports | clients REST et SignalR |
| `userId` injecté par l'orchestrateur | identité de l'utilisateur via son JWT |
| `ai-exposure.json` | valeurs par défaut en attributs sur les DTO, surcharge par client dans un écran d'administration, niveau d'exposition sur les champs personnalisés |
| Filtre de confidentialité en Dart | même filtre en C#, dans l'orchestrateur |
| `evals/requests.yaml` | même format, avec les demandes du domaine pro |

Reste ici : Serverpod, le client Ollama et les sources du puissance 4.

## 13. Choix techniques et précautions

- **Licences :** uniquement MIT, BSD ou Apache, pour pouvoir reprendre le code au travail. `fl_chart` est en MIT. Vérifier les autres (`flutter_layout_grid`, `widgetbook`, un éventuel package Aho-Corasick ; sinon, l'écrire, c'est quelques dizaines de lignes). Pas de Syncfusion, dont la licence gratuite dépend de la taille de l'entreprise.
- **Ollama Cloud :** la clé se crée sur ollama.com/settings/keys. Les modèles disponibles sont listés par `https://ollama.com/api/tags`, et la consommation se suit sur ollama.com/settings/usage (l'offre gratuite a des plafonds). Le support des outils dépend du modèle : tester d'abord avec un outil bidon, par exemple sur `gpt-oss:120b` s'il est listé, puis comparer deux modèles avec `evals/`.
- **Jeu de tests** (`evals/requests.yaml`) : comparer les arguments partiellement, mesurer les tokens et la durée par modèle, et vérifier qu'aucune valeur sensible n'apparaît dans les requêtes envoyées à Ollama.

```yaml
- request: "Ajoute mon taux de victoire en haut à gauche"
  expect:
    - tool: add_widget
      args: { type: kpi, query: { source: games.summary } }
- request: "Montre mes parties par jour sur 10 jours, empilées par résultat"
  expect:
    - tool: add_widget
      args: { type: chart, query: { source: games.byDay }, chart: { mark: bar, stack: true } }
- request: "Mets la carte des cases où je joue à droite, sur mes 30 dernières parties"
  expect:
    - tool: add_widget
      args: { type: chart, query: { source: moves.byCell, params: { lastGames: 30, who: me } }, chart: { mark: heatmap } }
- request: "Combien de parties j'ai gagnées cette semaine ?"
  expect:
    - tool: query_data
      args: { source: games.summary, params: { range: "last:7d" } }
- request: "Est-ce que j'ai déjà battu kevin 42 ce mois-ci ?"
  llm_input_must_not_contain: ["Kevin42", "kevin 42"]
  expect:
    - tool: query_data
      args: { source: results.byOpponent }
```

## 14. Outils utiles pour Claude Code

- Le serveur MCP Dart et Flutter (Dart 3.9 ou plus, encore expérimental) : `claude mcp add --transport stdio dart -- dart mcp-server`.
- Le serveur MCP du jeu, pour tester les outils sans LLM : `claude mcp add --transport http p4 http://localhost:8090/mcp`, ou MCP Inspector.
- `serverpod_mcp` : la documentation Serverpod pour l'assistant (voir sa page pub.dev).

## 15. Points ouverts

- Gestionnaire d'état et librairie de graphiques : à aligner sur le front pro quand j'y aurai accès.
- Modèle de données du jeu : vérifier ce qui est stocké (parties, coups, adversaires, IA et niveaux) et quels champs sont sensibles.
- Modèle Ollama : à choisir après les tests.
- mcp_dart : vérifier les noms exacts de l'API et la gestion de plusieurs sessions.

## Références

- Ollama Cloud : https://docs.ollama.com/cloud
- mcp_dart : https://pub.dev/packages/mcp_dart
- Transports mcp_dart : https://github.com/leehack/mcp_dart/blob/v2.4.2/doc/transports.md
- Serveur MCP Dart et Flutter : https://docs.flutter.dev/ai/mcp-server
