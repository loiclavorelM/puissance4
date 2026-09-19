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
- `updateProfile(username: String?, photo: ByteData?) -> UserProfileDto`

### Bot — `BotEndpoint` (`client.bot`), `lib/src/bot/`
- `getBotLevels() -> List<BotDto>`
- `getLatestModel(idBot: Guid) -> BotModelManifestDto`

### Partie — `PartieEndpoint` (`client.partie`), `lib/src/game/`
(dossier `game`, comme côté Flutter — la classe reste nommée d'après la ressource
qu'elle expose, pas de contrainte que dossier et nom de classe soient identiques)
- `createPartieMulti() -> PartieDto`
  Statut `created`, génère `code`.
- `joinPartieMulti(code: String) -> Stream<PartieDto>`
  Rejoint via le code ; diffuse l'état de la partie en temps réel (les deux joueurs
  s'abonnent au même stream).
- `createPartieNormal(idBot: Guid) -> PartieDto`
- `createPartieRanked() -> PartieDto`
  Le bot est choisi côté serveur selon l'Elo courant du joueur (pas de `idBot`).
- `playMove(idPartie: Guid, colonne: int) -> Stream<PartieDto>`
  Mode Multi uniquement — le coup est validé et rediffusé aux deux joueurs abonnés.
- `reportPartieResult(idPartie: Guid, moves: List<int>, winner: EnumPlayer) -> PartieDto`
  Mode Normal/Classé — la partie contre le bot est jouée 100 % en local (inférence
  on-device), le résultat final est remonté en un seul appel. Si Classé, recalcule
  l'Elo et crée une entrée `EloHistory`.
- `abandonPartie(idPartie: Guid) -> void`
  Abandon explicite en mode Multi (déconnexion réseau détectée par le stream
  lui-même, pas besoin d'appel dédié dans ce cas).
- `getPartie(idPartie: Guid) -> PartieDto`
  Retourne aussi `moves`, réutilisé tel quel pour l'écran de revue de partie (E14) —
  pas de méthode dédiée pour récupérer la séquence de coups.

### History — `HistoryEndpoint` (`client.history`), `lib/src/history/`
- `getListHistories(typePartie: EnumType?, limit: int, offset: int) -> List<HistoryDto>`
- `getHistory(idPartie: Guid) -> HistoryDto`

### Classement — `LeaderboardEndpoint` (`client.leaderboard`), `lib/src/leaderboard/`
- `getLeaderboard(limit: int, offset: int) -> List<UserSummaryDto>`

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
  int nbParties        // classé + multi
  int nbVictoires       // classé + multi
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

PlayerDto                 // exactement un des deux champs rempli
  Guid id
  BotDto? bot
  UserSummaryDto? user

PartieDto
  Guid id
  string? code
  EnumType typePartie
  PlayerDto playerRouge
  PlayerDto playerJaune
  EnumPlayer? winner
  EnumStatut status
  List<int> moves

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

- `reportPartieResult` — sans elle, aucune partie Normale/Classée ne peut jamais
  être conclue côté serveur ni mettre à jour l'Elo (E6).
- `joinPartieMulti` — `createPartieMulti` générait un code mais rien ne permettait
  au second joueur de rejoindre (E7).
- `playMove` — aucune méthode ne permettait de jouer un coup en Multijoueur (E7).
- `abandonPartie` — gestion explicite de l'abandon (E7/T7.2.3).
- `explainMove` — feature de revue de partie IA (E14).
