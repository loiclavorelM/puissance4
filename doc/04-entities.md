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
string? friendCode   // code ami E15 (6 caractères, unique), attribué au besoin
DateTime? lastSeenAt // E15 : dernière déconnexion du temps réel (« vu il y a »)
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
// Multi et Classé : présence des joueurs humains (stream ouvert / heure de
// départ) et raison de fin — cf. doc/05-endpoints.md, GameEndpoint.
Guid? rougeConnectionId, DateTime? rougeDisconnectedAt
Guid? jauneConnectionId, DateTime? jauneDisconnectedAt
EnumGameEndReason? endReason
{Champs d'audits}
```

### MoveExplanation
```
// Cache des explications LLM de la revue de partie (E14).
Guid id
string positionKey   // coups jusqu'au coup expliqué inclus, ex. "3,3,4"
string language      // "fr" | "en" — unique (positionKey, language)
string explanation
string model         // modèle Ollama utilisé
Guid requestedBy     // AuthUser qui l'a générée (limite par heure)
DateTime createdAt
```

### Friendship
```
// Amis (E15) : demande puis amitié. Refus / annulation / retrait = suppression.
Guid id
Guid requesterId FK User   // qui a envoyé la demande
Guid addresseeId FK User
string pairKey             // les deux ids triés — unique : une ligne par paire
EnumFriendshipStatus status  // pending | accepted
DateTime createdAt
DateTime? respondedAt
```

## Enum
EnumPlayer { jaune, rouge, draw }
EnumStatut { created, in_progress, finished, abandoned }  // abandoned : partie annulée, sans vainqueur (tous modes)
EnumType  {Multi, Normal, Classe}