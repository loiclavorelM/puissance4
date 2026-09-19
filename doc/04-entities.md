## Entities

Tous les `Guid id` sont des **GUIDv7**. La génération côté client est **optionnelle**
: nécessaire uniquement pour créer un enregistrement hors-ligne (ex. mode invité E0)
avant tout contact avec le serveur — sinon le serveur génère l'id lui-même à la
création. Avantage secondaire du GUIDv7 : triable chronologiquement, utile pour
l'ordre de synchronisation des résultats hors-ligne, cf. E0/US0.3.

L'authentification utilise le module natif Serverpod (`serverpod_auth_idp`), pas
Firebase (cf. AGENTS.md). Il gère déjà email/mot de passe et son propre profil
(`AuthUser`) — `User` ci-dessous ne stocke que les données **spécifiques au jeu**
(username affiché, photo, Elo), reliées à l'`AuthUser` par une relation nullable
(nullable pour permettre un `User` créé localement en mode invité, avant toute
authentification).

### User
```
Guid id
authUser: module:serverpod_auth_core:AuthUser?, relation(onDelete=Cascade)
string username
string thumbnail_path
int elo = 1000
{Champs d'audits}
```
### Bot
```
Guid id
string botName
int elo
string path_model
string description
{Champs d'audits}
```

### EloHistory
```
Guid id
Guid idUser FK
Guid idPartie FK
int eloVariation
int newElo
{Champs d'audits}
```

### Player
```
Guid id
Guid? botId FK
Guid? userId FK
```

### Partie
```
Guid id
string? code
EnumType typePartie
Guid playerRouge FK
Guid playerJaune FK
EnumPlayer winner
EnumStatut status
moves: List<int>
{Champs d'audits}
```

## Enum
EnumPlayer { jaune, rouge, draw }
EnumStatut { created, in_progress, finished }
EnumType  {Multi, Normal, Classe}