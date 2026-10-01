## Endpoints

Serverpod fait du **RPC**, pas du REST : il n'y a pas de chemin d'URL ni de verbe
HTTP à choisir. Un endpoint est une **classe** `XxxEndpoint` (n'importe où sous
`lib/src/` côté serveur) ; chaque méthode dedans est appelée directement depuis le
client généré, comme une méthode Dart normale : `client.<nomClasseSansEndpoint>
.methode(...)`. En interne tout transite en POST — le préfixe `get`/`create`/
`update` utilisé ci-dessous est une convention de lisibilité, pas un mapping REST.
Méthodes en `camelCase` (comme le contrat déjà posé dans
`doc/latex/cahier-des-charges.tex`), premier paramètre implicite toujours `Session
session` (non répété ci-dessous). L'utilisateur courant est **déduit de la session
authentifiée**, jamais passé en paramètre (`idUser` explicite = faille IDOR
potentielle) — sauf pour consulter le profil public d'un *autre* joueur.

Chaque section ci-dessous correspond à une classe Endpoint précise, avec son dossier
serveur cible (suivant l'organisation feature-first déjà en place).

### Auth
Pas de classe Endpoint custom : l'inscription, la connexion et la déconnexion
utilisent les endpoints déjà générés par le **module natif Serverpod**
(`serverpod_auth_idp`, déjà scaffoldé et configuré dans `server.dart` — provider
email + JWT) : côté client, `SignInWidget` et `client.auth.*`. `session.authenticated
?.authUserId` donne l'identité du joueur pour tous les endpoints ci-dessous (cf.
AGENTS.md).

### User / Profil — `ProfileEndpoint` (`client.profile`), `lib/src/profile/`
- `getMyProfile() -> UserProfileDto`
  Crée le `User` de jeu (username/photo/Elo) au premier appel si celui-ci n'existe
  pas encore pour cet `authUserId` (pas de méthode de création séparée).
- `getUserSummary(idUser: Guid) -> UserSummaryDto`
- `updateUsername(username: String) -> UserProfileDto`
  3 à 20 caractères `[A-Za-z0-9_-]`, unique (insensible à la casse). Lève
  `ProfileUpdateException(reason: invalidUsername | usernameTaken)`.
- `updateProfilePhoto(...)` — *à venir* (US2.1/T2.1.3) : upload Serverpod
  séparé qui remplit `User.thumbnailPath`.

### Bot — `BotEndpoint` (`client.bot`), `lib/src/bot/`
- `getBotLevels() -> List<BotDto>`
- `getLatestModel(idBot: Guid) -> BotModelManifestDto`

### Partie serveur — `GameEndpoint` (`client.game`), `lib/src/game/`
Commun aux deux modes joués **sur le serveur**, seul juge de chaque coup :
Multi (deux humains) et Classé (un humain contre un bot serveur). Le mode
Normal, lui, se joue entièrement sur le téléphone (règles et IA locales,
résultat dans `OfflineMatchResult`) : pas d'endpoint.

Principe anti-parties fantômes : une `Partie` serveur ne naît que complète
(ses deux camps connus), directement `inProgress`, et a toujours une fin
programmée — délai par coup (60 s), délai de grâce après déconnexion (15 s).
Tous les streams émettent des `GameEvent` portant l'état complet.
- `watchPartie(partieId: Guid) -> Stream<GameEvent>`
  `gameStarted` (photo complète) puis `moveApplied` / `opponentDisconnected` /
  `opponentReconnected` / `gameOver`. Sert aussi à revenir après une coupure.
- `getActivePartie() -> Guid?` — partie serveur en cours à reprendre (une seule
  par joueur, tous modes confondus).
- `playMove(partieId: Guid, column: int) -> void`
  Coup validé (tour, colonne, victoire), rediffusé en `moveApplied` ou
  `gameOver`. En Classé, le bot serveur répond ~0,6 s plus tard.
- `abandon(partieId: Guid) -> void`
  L'adversaire gagne ; partie annulée (`abandoned`) si l'appelant n'a joué aucun
  coup.

Fins de partie (`GameEvent.endReason`) : `connectFour`, `boardFull`, `forfeit`,
`disconnect` (absent > 15 s), `timeout` (> 60 s pour jouer), `cancelled` (statut
`abandoned`, hors historique/stats/Elo). Règle unique pour les trois façons de
quitter (abandon, déconnexion, temps) : la partie est annulée si le joueur qui
quitte n'a encore joué aucun coup, sinon son adversaire gagne. En Multi, elle
est aussi annulée si les deux joueurs sont partis ; en Classé, le joueur au
trait perd au temps même s'il a fermé l'app.
Une seule partie serveur par joueur, garantie sous verrou consultatif
PostgreSQL à la création (deux lancements simultanés n'en créent qu'une).
Au redémarrage (`ServerGameConfig.singleServer`), tout humain déjà passé par
une partie en cours repart « parti maintenant » avec un délai de grâce
complet, et le joueur au trait retrouve un tour complet ; les streams qui
arrivent pendant cette remise à zéro attendent sa fin. Erreurs : `GameException(reason: EnumGameError)` —
`roomNotFound`, `ownRoom`, `alreadyInGame` (+ `partieId`), `notYourTurn`,
`invalidMove`, `gameOver`, `noBotAvailable`…

Prêt pour Redis/cluster : état des parties en base (verrou `FOR UPDATE`),
événements via `session.messages` (portée `auto`), rappels idempotents. Seuls
`GameScheduler` (`server_game_config.dart`) et `RoomStore`
(`multiplayer_config.dart`) sont à remplacer par des implémentations partagées.

### Multijoueur — `MultiplayerEndpoint` (`client.multiplayer`), `lib/src/multiplayer/`
La **salle** (code d'attente) n'est jamais en base et ne vit que tant que le
stream de l'hôte est ouvert ; la `Partie` n'est créée qu'à l'arrivée de
l'adversaire.
- `hostRoom() -> Stream<GameEvent>`
  `roomCreated` (code, expiration 10 min), puis `gameStarted` et la suite de la
  partie sur le même stream. Fermer le stream ferme la salle ; à expiration :
  `roomClosed`. Ouvrir une 2ᵉ salle ferme la 1ʳᵉ.
- `joinRoom(code: String) -> Stream<GameEvent>`
  Réserve la salle (atomique : un seul invité l'obtient), crée les 2 `Player` +
  la `Partie`, couleurs tirées au sort, puis suit la partie.
  Si l'invité est refusé parce qu'il est déjà en partie, la salle est rendue à
  l'hôte, qui continue d'attendre.

Le Multi ne change pas l'Elo.

### Classé — `RankedEndpoint` (`client.ranked`), `lib/src/ranked/`
- `startRanked() -> Guid`
  Crée une partie `classe` contre le bot choisi d'après l'Elo du joueur
  (< 1000 Débutant, < 1400 Medium, sinon Expert — `BotStrength.fromElo`),
  couleurs tirées au sort. Se suit ensuite par `GameEndpoint.watchPartie`.
  En fin de partie (`finished`), l'Elo du joueur est recalculé contre l'Elo
  virtuel du bot (K = 32, `ranked/elo.dart`) dans la même transaction, avec une
  ligne `EloHistory` ; `GameEvent.eloVariation` la renvoie au joueur.

L'IA des bots (`HeuristicBot`, paquet partagé `puissance4_rules`) est la même
sur le téléphone (Normal) et sur le serveur (Classé), en attendant les modèles
RL (E5).

### History — `HistoryEndpoint` (`client.history`), `lib/src/history/`
- `getListHistories(typePartie: EnumType?, limit: int, offset: int) -> List<HistoryDto>`
- `getHistory(idPartie: Guid) -> HistoryDto`
- `getReplay(idPartie: Guid) -> ReplayDto`
  Coups + joueurs d'une partie Multi/Classé pour la rejouer (E14) ; réservé aux
  joueurs de la partie (`GameException(notAPlayer)` sinon). Les parties Normal
  se rejouent depuis `OfflineMatchResult.moves`, en local.

### Classement — `LeaderboardEndpoint` (`client.leaderboard`), `lib/src/leaderboard/`
- `getLeaderboard(limit: int, offset: int) -> List<LeaderboardEntryDto>`
  Page mise en cache côté serveur (`session.caches.local`, groupe
  `leaderboard`), vidée à chaque changement d'Elo/pseudo.
- `getMyRank() -> LeaderboardEntryDto`

### Temps réel — `LiveEndpoint` (`client.live`), `lib/src/live/`
- `watchUpdates() -> Stream<LiveEvent>`
  Stream (WebSocket) ouvert par le client tant qu'il est connecté. Émet
  `LiveEvent(type: profileChanged | historyChanged | leaderboardChanged)` —
  sans payload : le client recharge la donnée concernée (cache local puis
  réseau). Alimenté par `session.messages` via `live_notifier.dart` : canal
  `live.user.<authUserId>` (profil/historique) et `live.leaderboard` (tous).

### Revue de partie IA `[optionnel]` — `ReviewEndpoint` (`client.review`), `lib/src/review/`
- `explainMove(idPartie: Guid, moveIndex: int) -> ExplainMoveResultDto`
  Appelle Ollama cloud côté serveur ; indisponible hors-ligne (cf. E14/US14.3).
  Le coup recommandé par le modèle Expert n'est **pas** calculé ici : il est
  réexécuté localement sur l'appareil (modèle déjà embarqué pour le bot).

## DTO

```
UserSummaryDto
  Guid id
  string username
  string? thumbnailUrl
  int elo

UserProfileDto
  Guid id
  string username
  string? thumbnailUrl
  int elo
  int nbParties  
  int nbVictoires    
  // pas d'email ici : géré par le module d'auth natif (AuthUser), pas dupliqué

BotDto
  Guid id
  string botName
  int elo
  string description

BotModelManifestDto
  Guid idBot
  string version
  string downloadUrl

GamePlayerInfo            // un camp d'une partie serveur
  string username         // nom du bot si isBot
  int elo
  bool isBot

GameEvent                 // streams de partie serveur, état complet à chaque fois
  EnumGameEventType type  // roomCreated, roomClosed, gameStarted, moveApplied,
                          // opponentDisconnected, opponentReconnected, gameOver
  string? code
  DateTime? roomExpiresAt
  Guid? partieId
  EnumType? typePartie
  EnumColor? yourColor    // renseigné par le stream du destinataire
  GamePlayerInfo? rouge
  GamePlayerInfo? jaune
  List<int>? moves
  DateTime? turnDeadline
  EnumOutcome? winner
  EnumGameEndReason? endReason
  EnumColor? aboutColor   // joueur concerné par (dé)connexion
  bool? opponentConnected // sur gameStarted : adversaire présent ?
  int? eloVariation       // Classé, sur gameOver

ReplayDto
  Guid id
  EnumType typePartie
  DateTime date
  List<int> moves
  GamePlayerInfo rouge
  GamePlayerInfo jaune
  EnumColor playedAs
  EnumOutcome? winner
  EnumGameEndReason? endReason

HistoryDto
  Guid id
  DateTime date
  EnumType typePartie
  string adversaire
  EnumPlayer resultat
  int? eloVariation

ExplainMoveResultDto
  string explanation
```

Enums `EnumPlayer` / `EnumStatut` / `EnumType` : voir `doc/04-entities.md` (pas
dupliqués ici, pour éviter les divergences entre les deux fichiers).

## Endpoints retirés / fusionnés lors de l'uniformisation

- `login` / `logout` / `createaccount` → gérés par le module d'auth natif Serverpod
  (`SignInWidget` + `client.auth.*`) côté client, pas des méthodes custom, et pas
  Firebase (cf. Auth ci-dessus).
- `ListeBotDispo` / `GetListBot` / `GetBot` / `DownloadBot` → fusionnés en
  `getBotLevels` + `getLatestModel`, alignés sur le contrat déjà posé dans le
  cahier des charges.
- `GetListClassement` → renommé `getLeaderboard` (même nom que le cahier des
  charges).

## Endpoints ajoutés (manquants dans le brouillon initial)

- `GameEndpoint` + `MultiplayerEndpoint` (E7) — remplacent `createPartieMulti`/
  `joinPartieMulti`/`playMove`/`abandonPartie` : la partie n'est plus créée à
  l'ouverture de la salle mais à l'arrivée de l'adversaire, pour éviter les
  parties fantômes.
- `RankedEndpoint.startRanked` — remplace `createPartieRanked` +
  `reportPartieResult` : le Classé est joué coup par coup sur le serveur (bot
  serveur) au lieu d'être joué en local puis remonté, pour que l'Elo ne puisse
  pas être truqué.
- `HistoryEndpoint.getReplay` — remplace `getPartie` pour la revue (E14).
- `explainMove` — feature de revue de partie IA (E14).
