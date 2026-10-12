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
- `uploadProfilePhoto(photo: ByteData) -> UserProfileDto` (US2.1)
  Miniature envoyée par l'app (carré 256×256). Le serveur la vérifie (JPEG ou
  PNG, 512 Ko et 1024 px au plus), la réencode (carré 256 px, JPEG, sans
  métadonnées), la stocke dans le stockage `public` sous
  `avatars/<userId>/<horodatage>.jpg` (nom neuf à chaque envoi : pas de cache
  périmé), remplit `User.thumbnailPath` et supprime l'ancienne. Lève
  `ProfileUpdateException(reason: photoTooLarge | invalidPhoto)`. Notifie
  profil et classement.
- `removeProfilePhoto() -> UserProfileDto`
  Supprime la photo (retour aux initiales).

Les DTO (`UserProfileDto`, `LeaderboardEntryDto`, `LobbyRoom`) exposent
`thumbnailUrl`, l'URL publique du fichier (`ProfilePhoto.url`), jamais le
chemin ; `null` si le fichier a disparu du stockage.

### Bot — pas d'endpoint
Les 5 niveaux de bot (`BotLevel`, paquet `puissance4_rules`) et leurs modèles
RL (`.tflite`) sont embarqués dans l'app (`puissance4_flutter/assets/models/`)
et dans le serveur (`puissance4_server/assets/models/`) : la liste des bots ne
vient pas du serveur, pour que le mode Normal se joue entièrement hors ligne.
Le serveur sème ces niveaux dans la table `Bot` sous les mêmes identifiants
(`lib/src/bot/bot_seed.dart`) pour le Classé et l'historique.

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
- `hostRoom(isPublic: bool, {challengeUserId: Guid?}) -> Stream<GameEvent>`
  `roomCreated` (code, expiration 10 min), puis `gameStarted` et la suite de la
  partie sur le même stream. Fermer le stream ferme la salle ; à expiration :
  `roomClosed`. Ouvrir une 2ᵉ salle ferme la 1ʳᵉ. Une salle `isPublic` apparaît
  dans le lobby (pseudo, Elo et avatar de l'hôte lus à l'ouverture) ; une salle
  privée ne se rejoint que par son code.
  Avec `challengeUserId` (E15) : défi à un ami — salle privée réservée à lui
  seul, 2 min, visible dans ses `FriendsEndpoint.getChallenges` ; s'il refuse,
  `challengeDeclined` termine le stream. Lève `GameException(friendUnavailable)`
  si ce n'est pas un ami ou s'il est déjà en partie.
- `watchLobby() -> Stream<LobbySnapshot>` (US7.4)
  Salles publiques ouvertes, sauf la sienne : la liste au départ, puis une
  nouvelle à chaque ouverture, fermeture, prise ou expiration d'une salle
  publique (signal `LiveEvent(lobbyChanged)` sur le canal `multi.lobby`, local
  tant que les salles sont en mémoire). Pas de table : vue de `RoomStore`.
  On rejoint une salle du lobby par `joinRoom(code)` ; si elle a été prise
  entre-temps, `roomNotFound` (affiché « Salle déjà prise »).
- `joinRoom(code: String) -> Stream<GameEvent>`
  Réserve la salle (atomique : un seul invité l'obtient), crée les 2 `Player` +
  la `Partie`, couleurs tirées au sort, puis suit la partie.
  Si l'invité est refusé parce qu'il est déjà en partie, la salle est rendue à
  l'hôte, qui continue d'attendre.

Le Multi ne change pas l'Elo.

### Classé — `RankedEndpoint` (`client.ranked`), `lib/src/ranked/`
- `startRanked() -> Guid`
  Crée une partie `classe` contre le niveau de bot dont l'Elo est le plus
  proche de celui du joueur (`BotLevel.forElo`),
  couleurs tirées au sort. Se suit ensuite par `GameEndpoint.watchPartie`.
  En fin de partie (`finished`), l'Elo du joueur est recalculé contre l'Elo
  virtuel du bot (K = 32, `ranked/elo.dart`) dans la même transaction, avec une
  ligne `EloHistory` ; `GameEvent.eloVariation` la renvoie au joueur.

Tous les bots jouent avec les réseaux RL. En Classé, le serveur les recalcule
en Dart pur (`ConnectFourNet`, poids lus dans le `.tflite`, `BotNetworks`) ; en
Normal, l'app passe par TFLite sur Android/iOS et par le même réseau en Dart
ailleurs (web, bureau). La revue de partie garde une recherche exacte
(`MoveAnalysis`), seule capable d'affirmer qu'une victoire est forcée.

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
  `LiveEvent(type: profileChanged | historyChanged | leaderboardChanged |
  friendsChanged | challengesChanged)` —
  sans payload : le client recharge la donnée concernée (cache local puis
  réseau). Alimenté par `session.messages` via `live_notifier.dart` : canal
  `live.user.<authUserId>` (profil/historique) et `live.leaderboard` (tous).

### Amis `[hors cahier des charges]` — `FriendsEndpoint` (`client.friends`), `lib/src/friends/`
Réservé aux comptes email : un invité reçoit `FriendsException(guestNotAllowed)`
et n'apparaît jamais dans les recherches. Chaque changement envoie
`LiveEvent(friendsChanged)` aux deux joueurs.
- `getOverview() -> FriendsOverviewDto`
  Code ami (attribué au premier appel), amis avec leur présence
  (`online | playing | offline`, type de partie, `lastSeenAt` ; en ligne
  d'abord, puis en partie, puis par Elo), demandes reçues et envoyées.
- `searchPlayers(query: String) -> List<PlayerSearchResultDto>`
  Pseudos commençant par `query` (3 caractères min., 20 résultats), précédés du
  joueur dont c'est le code ami (`P4-XXXXXX`, préfixe et casse libres) ; chaque
  résultat porte la relation (`none | friend | requestSent | requestReceived`).
- `sendRequest(userId: Guid) -> FriendshipDto`
  Accepte directement si l'autre avait déjà envoyé une demande.
- `recentOpponents() -> List<PlayerSearchResultDto>`
  10 derniers adversaires Multi (une fois chacun), avec leur relation.
- `getRivalries() -> List<RivalryDto>`
  Tête-à-tête avec chaque ami : victoires, défaites, nuls (Multi), série en
  cours, parties communes (ids, plus récentes d'abord).
- `getFriendsActivity() -> List<FriendActivityDto>`
  Parties Multi et Classé des amis sur 7 jours (20 au plus), avec la
  variation d'Elo.
- `shakeToAdd() -> PlayerSearchResultDto?`
  « Secouer pour s'ajouter » : attend au plus 2 s une secousse d'un autre
  joueur (`ShakeMatcher`, en mémoire) et le renvoie avec sa relation, sinon
  `null`. N'envoie aucune demande.
- `getChallenges() -> List<FriendChallengeDto>`
  Défis reçus encore ouverts : salles privées réservées au joueur, ouvertes
  par `MultiplayerEndpoint.hostRoom(challengeUserId:)`, à rejoindre par
  `joinRoom(code)`.
- `declineChallenge(code: String)`
  Ferme la salle ; le stream de l'hôte émet `challengeDeclined`. Lève
  `FriendsException(challengeNotFound)` si elle n'existe plus.
- `acceptRequest(friendshipId)`, `declineRequest(friendshipId)`,
  `cancelRequest(friendshipId)`, `removeFriend(userId)`
  Lèvent `FriendsException(reason: userNotFound | cannotAddSelf |
  alreadyFriends | requestAlreadySent | requestNotFound | notFriends |
  tooManyFriends)` — 200 amis au plus.

### Revue de partie IA `[optionnel]` — `ReviewEndpoint` (`client.review`), `lib/src/review/`
- `explainMove(moves: List<int>, moveIndex: int, language: String) -> String`
  Explication en `language` (`fr` | `en`) du coup d'indice `moveIndex`, générée
  par Ollama cloud depuis le serveur (clé `ollamaApiKey` dans les mots de passe
  Serverpod, jamais côté client) ; indisponible hors-ligne (cf. E14/US14.3).
  Prend les coups plutôt qu'un id de partie : marche pour tous les modes, y
  compris une partie Normale pas encore synchronisée. Le serveur recalcule le
  coup recommandé avec le même `MoveAnalysis` (`puissance4_rules`) que l'app —
  sur l'appareil, il sert à afficher la recommandation sans réseau — et
  fournit au LLM les faits vérifiés (victoires/menaces immédiates). Cache
  `MoveExplanation` par position (coups jusqu'au coup expliqué) + langue ;
  au plus 30 générations (hors cache) par joueur et par heure.
  Lève `ReviewException(reason: invalidMove | notConfigured | unavailable |
  rateLimited)`.

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

LobbySnapshot
  List<LobbyRoom> rooms

LobbyRoom
  string code
  string hostUsername
  int hostElo
  string? hostThumbnailUrl
  DateTime expiresAt

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

```

Enums `EnumPlayer` / `EnumStatut` / `EnumType` : voir `doc/04-entities.md` (pas
dupliqués ici, pour éviter les divergences entre les deux fichiers).

## Endpoints retirés / fusionnés lors de l'uniformisation

- `login` / `logout` / `createaccount` → gérés par le module d'auth natif Serverpod
  (`SignInWidget` + `client.auth.*`) côté client, pas des méthodes custom, et pas
  Firebase (cf. Auth ci-dessus).
- `ListeBotDispo` / `GetListBot` / `GetBot` / `DownloadBot` → d'abord fusionnés
  en `getBotLevels` + `getLatestModel`, puis supprimés (`getBots` compris) :
  les modèles sont embarqués dans l'app pour jouer hors ligne.
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
