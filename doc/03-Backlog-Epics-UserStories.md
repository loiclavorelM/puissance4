# Backlog — Epics / User Stories / Tickets

Organisation retenue pour GitHub : **un seul repo** (monorepo Serverpod :
`puissance4_server`, `puissance4_client`, `puissance4_flutter`, + `rl_training/`
pour les notebooks Colab), **un seul GitHub Project** (kanban), et des **labels**
pour distinguer les zones :

- `area:backend` (Serverpod/Postgres)
- `area:frontend` (Flutter)
- `area:rl` (entraînement/export du modèle)
- `area:infra` (CI/CD, déploiement)
- `type:epic`, `type:story`, `type:task`
- `owner:A`, `owner:B` (cf. répartition des tâches du cahier des charges)

Chaque **Epic** devient un label GitHub (ou un Milestone) regroupant ses User Stories
et Tickets. Chaque **Ticket** ci-dessous deviendra une issue GitHub individuelle.

---

## E0 — Mode invité local & migration `[optionnel]`
`area:frontend` `area:backend` `priority:optional`

### US0.1 — En tant que nouveau joueur sans réseau, je veux pouvoir jouer immédiatement contre un bot par défaut, afin d'utiliser l'app dès l'installation, sans connexion ni compte.
Critères d'acceptation :
- Aucun appel réseau au tout premier lancement (pas même une tentative de connexion au module d'auth Serverpod).
- Les stats/historique du joueur invité sont stockés localement via le mécanisme **natif** Serverpod 4.0 `database: sync` (module `serverpod_offline_sync`) : un modèle `.spy.yaml` annoté `sync` génère automatiquement une base SQLite locale côté client, sans queue ni endpoint fait main.
- Un modèle de bot par défaut est embarqué dans les assets (pas de téléchargement requis).
- Pas d'accès au classement global, à la Ligue/Classé ni au Multijoueur sans réseau.
- Cette fonctionnalité étant **expérimentale** en Serverpod 4.0, elle doit être validée par un spike avant adoption complète (cf. T0.1.1).

Tickets :
- [ ] T0.1.1 — (spike) Valider `database: sync` / `serverpod_offline_sync` sur un modèle simple (PoC isolé) avant adoption sur les modèles réels — `owner:B` `area:backend`
- [ ] T0.1.2 — Modèle `.spy.yaml` annoté `database: sync` pour les stats/historique invité (SQLite locale générée automatiquement côté client) — `owner:B` `area:backend`
- [ ] T0.1.3 — Embarquer un modèle de bot par défaut dans les assets de l'app — `owner:B` `area:rl`
- [ ] T0.1.4 — UI : indicateur "mode invité / hors-ligne", désactivation Classé/Multijoueur — `owner:A`

### US0.2 — En tant que joueur invité qui se connecte pour la première fois, je veux que mon historique et mes stats locaux soient migrés vers mon compte, afin de ne pas perdre ma progression.
Critères d'acceptation :
- Au premier login/inscription réussi, les enregistrements locaux synchronisés (`database: sync`) sont ré-associés au compte Serverpod authentifié (userId) — pas d'endpoint `migrateLocalData` fait main.
- La synchronisation bidirectionnelle CRDT (conflict-free replicated data types) envoie automatiquement les données locales vers PostgreSQL dès que la connexion est disponible.
- Après la première synchronisation réussie, le serveur reste la source de vérité.

Tickets :
- [ ] T0.2.1 — Association du userId invité au compte authentifié dans le(s) modèle(s) `sync` (stratégie de ré-attribution des enregistrements locaux) — `owner:B` `area:backend`
- [ ] T0.2.2 — Déclenchement/contrôle de la synchronisation `serverpod_offline_sync` juste après le premier login réussi — `owner:A`
- [ ] T0.2.3 — Gestion du cas où le compte a déjà un `User` côté serveur (l'index unique sur `authUserId` empêche un second lien direct) : **fusion de l'historique des deux comptes** (parties/stats du `User` invité rattachées au `User` déjà existant du compte, puis suppression du `User` invité devenu orphelin) — `owner:B` `area:backend`

### US0.3 — En tant que joueur déjà connecté qui perd sa connexion en cours d'utilisation, je veux que le résultat de ma partie (Normale ou Classée) ne soit pas perdu, afin que mes stats/Elo restent cohérents une fois reconnecté.
Critères d'acceptation :
- Les résultats de partie sont persistés localement via un modèle `.spy.yaml` `database: sync` (pas de queue applicative faite main), pour Normal comme pour Classé.
- La réplication CRDT ne garantissant pas d'ordre applicatif, le recalcul d'Elo reste un traitement **serveur séquentiel** : à la réception de résultats synchronisés, ils sont triés par horodatage avant recalcul pas à pas (nécessaire si plusieurs parties classées se sont enchaînées hors-ligne).
- Le client est notifié (stream Serverpod) une fois la synchronisation et le recalcul d'Elo terminés.
- Le lancement d'une **nouvelle** partie Classée est bloqué si l'absence de réseau est déjà détectée (le matchmaking a besoin de l'Elo serveur à jour).

Tickets :
- [ ] T0.3.1 — Modèle `.spy.yaml` `database: sync` pour les résultats de partie (Normale/Classée) — `owner:B` `area:backend`
- [ ] T0.3.2 — Traitement serveur déclenché à la synchronisation : tri chronologique des résultats reçus + recalcul Elo séquentiel — `owner:B` `area:backend`
- [ ] T0.3.3 — Notification client (stream) une fois le recalcul Elo terminé après reconnexion — `owner:A`
- [ ] T0.3.4 — Désactiver le lancement d'une partie Classée si hors-ligne détecté — `owner:A`

---

## E1 — Authentification & compte joueur
`area:backend` `area:frontend`

### US1.1 — En tant que joueur, je veux créer un compte et me connecter, afin d'accéder à mon profil et à mes stats.
Critères d'acceptation :
- Écran login/inscription fonctionnel, construit avec le `SignInWidget` fourni par le module d'auth natif Serverpod (`serverpod_auth_idp_flutter`) — pas d'écran custom à coder de zéro.
- Session persistante entre relances de l'app (gérée par `client.auth`, déjà fourni par le module).

Tickets :
- [ ] T1.1.1 — Intégration de `SignInWidget` dans l'écran login/inscription (Flutter) — `owner:A`
- [ ] T1.1.2 — Vérifier/adapter la configuration du provider email déjà présente dans `server.dart` (`ServerpodCloudEmailIdpConfig`) — `owner:B` `area:backend`
- [ ] T1.1.3 — Écoute de `client.auth.authInfoListenable` pour réagir à l'état connecté/déconnecté (navigation, auto-login au démarrage) — `owner:A`

### US1.2 — En tant que backend, je veux associer un profil de jeu (username, photo, Elo) à chaque utilisateur authentifié, afin de stocker Elo/historique/profil côté serveur sans dupliquer ce que le module d'auth gère déjà (email, mot de passe).
Critères d'acceptation :
- Modèle `User` (`.spy.yaml`) avec un champ `authUser: module:serverpod_auth_core:AuthUser?, relation(onDelete=Cascade)` **nullable** (nullable pour permettre un profil créé localement en mode invité avant toute authentification, cf. E0).
- Le profil de jeu (`User`) est créé/complété au premier appel authentifié qui en a besoin (pas d'endpoint `authenticateWithFirebase` : le module d'auth gère déjà la vérification de session).
- Aucune donnée déjà fournie par le module d'auth (email, mot de passe) n'est dupliquée dans `User`.

Tickets :
- [ ] T1.2.1 — Modèle `User` (`.spy.yaml`) lié à `AuthUser` par relation nullable (schéma Postgres généré par Serverpod) — `owner:B` `area:backend`
- [ ] T1.2.2 — Création paresseuse du profil `User` au premier appel authentifié sans profil existant (ex. dans `getMyProfile`) — `owner:B` `area:backend`
- [ ] T1.2.3 — Écran de complétion de profil (choix du username) juste après la première inscription réussie — `owner:A`

---

## E2 — Profil utilisateur
`area:frontend` `area:backend`

### US2.1 — En tant que joueur, je veux prendre une photo de profil, afin qu'elle apparaisse dans mon profil et le classement.
Critères d'acceptation :
- Prise de photo via la caméra (permission gérée).
- Photo affichée dans le profil et le leaderboard.

Tickets :
- [ ] T2.1.1 — Écran profil + bouton "changer la photo" — `owner:A`
- [ ] T2.1.2 — Intégration caméra (`camera`/`image_picker`) + gestion permissions — `owner:A`
- [ ] T2.1.3 — Endpoint Serverpod `updateProfilePhoto` (upload + stockage fichier) — `owner:B` `area:backend`

---

## E3 — Backend Serverpod : infra & données
`area:backend` `area:infra`

### US3.1 — En tant qu'équipe, on veut un projet Serverpod fonctionnel dès le début, afin que le frontend puisse coder contre un client généré sans attendre la logique complète.
Critères d'acceptation :
- Projet Serverpod créé (`serverpod create`), lancé en local avec Postgres.
- Endpoints du contrat (cf. cahier des charges §6.2) déclarés, même avec une implémentation mockée.
- Client généré committé dans le repo.

Tickets :
- [ ] T3.1.1 — `serverpod create` + structure du monorepo (`_server`, `_client`, `_flutter`) — `owner:B`
- [ ] T3.1.2 — Déclaration des endpoints du contrat (signatures vides/mock) — `owner:B`
- [ ] T3.1.3 — Setup Postgres local (docker-compose fourni par Serverpod) — `owner:B`
- [ ] T3.1.4 — README "comment lancer le backend en local" — `owner:B`

### US3.2 — En tant qu'équipe, on veut déployer le serveur Serverpod quelque part d'accessible, afin de tester le multijoueur/l'auth réellement en réseau.
Critères d'acceptation :
- Serveur accessible depuis un appareil de test hors réseau local.

Tickets :
- [ ] T3.2.1 — Choix d'un hébergement (Serverpod Cloud / VPS / autre) — `owner:A` `area:infra`
- [ ] T3.2.2 — Déploiement + configuration des variables d'environnement — `owner:A` `area:infra`

---

## E4 — Moteur de jeu Puissance 4
`area:frontend`

### US4.1 — En tant que joueur, je veux voir un plateau de Puissance 4 et jouer un coup, afin de dérouler une partie.
Critères d'acceptation :
- Plateau 7x6 affiché, animation de chute du pion.
- Détection victoire (4 alignés), égalité (plateau plein).

Tickets :
- [x] T4.1.1 — UI du plateau + placement des pions — `owner:B`
- [x] T4.1.2 — Logique de jeu (règles, détection victoire/égalité) — `owner:B`
- [x] T4.1.3 — Écran de fin de partie (victoire/défaite/nul) — `owner:B`

### US4.2 — En tant que menu principal, je veux lancer l'écran de jeu avec des paramètres typés, afin que jeu et menu se développent indépendamment.
Critères d'acceptation :
- `GameLaunchParams` (cf. cahier des charges §6.1) implémenté et respecté par les deux côtés.

Tickets :
- [x] T4.2.1 — Implémentation des classes `GameLaunchParams` / `PlayerInfo` / enums — `owner:B`
- [x] T4.2.2 — Câblage du menu principal vers l'écran de jeu selon ce contrat — `owner:A`

---

## E5 — Mode Bot / IA par renforcement
`area:rl` `area:frontend` `area:backend`

### US5.1 — En tant que joueur, je veux affronter un bot avec un niveau choisi, afin de jouer à mon niveau.
Critères d'acceptation :
- Écran de choix du niveau (Débutant/Medium/Expert).
- Le coup du bot est calculé localement (hors-ligne).

Tickets :
- [ ] T5.1.1 — Écran "Mode Normal — choix du niveau" (aligné sur 3 niveaux RL, cf. maquettes à ajuster) — `owner:A`/`owner:B`
- [ ] T5.1.2 — Intégration `tflite_flutter`/`onnxruntime` dans le client Flutter — `owner:B`
- [ ] T5.1.3 — Appel du modèle local pour déterminer le coup du bot — `owner:B`

### US5.2 — En tant qu'équipe IA, on veut entraîner 3 modèles RL (Débutant/Medium/Expert), afin d'alimenter les 3 niveaux de bot.
Critères d'acceptation :
- Notebook Colab d'entraînement par self-play.
- Export des 3 modèles en `.tflite` ou `.onnx`.

Tickets :
- [ ] T5.2.1 — Environnement Puissance 4 pour l'entraînement (Python) — `owner:B` `area:rl`
- [ ] T5.2.2 — Entraînement self-play (Q-learning/DQN), 3 niveaux — `owner:B` `area:rl`
- [ ] T5.2.3 — Export SavedModel → TFLite/ONNX + validation de l'inférence — `owner:B` `area:rl`

### US5.3 — En tant que backend, je veux héberger et versionner les modèles entraînés, afin que le client puisse les télécharger et les mettre à jour sans publier l'app.
Critères d'acceptation :
- Endpoint `getLatestModel(level)` renvoyant l'URL/version du modèle courant.
- Client capable de télécharger et mettre en cache le modèle.

Tickets :
- [ ] T5.3.1 — Stockage des fichiers modèles + endpoint de manifest côté Serverpod — `owner:B` `area:backend`
- [ ] T5.3.2 — Téléchargement + cache local côté client (au premier lancement / si nouvelle version) — `owner:B`

---

## E6 — Mode Classé vs bot serveur *(réintroduit)*
`area:backend` `area:frontend`

D'abord retiré (l'Elo n'aurait de sens qu'entre humains), puis réintroduit
sous une autre forme : le bot est joué **par le serveur**, qui valide chaque
coup — l'Elo gagné contre lui ne peut donc pas être truqué côté client, ce qui
n'était pas le cas du "Ligue" joué en local puis remonté. Le mode Normal reste
le mode solo hors-ligne, sans Elo.

### US6.1 — En tant que joueur, je veux affronter un bot adapté à mon Elo, afin de faire progresser mon classement.
Critères d'acceptation :
- Bot choisi par le serveur selon l'Elo (< 1000 Débutant, < 1400 Medium, sinon Expert).
- Elo recalculé en fin de partie (K = 32) avec une entrée `EloHistory` ; partie annulée sans effet si aucun coup n'a été joué.
- Mêmes garanties anti-parties fantômes que le Multi (délai par coup, délai de grâce).

Tickets :
- [x] T6.1.1 — `RankedEndpoint.startRanked` + bot serveur (`HeuristicBot` partagé) — `area:backend`
- [x] T6.1.2 — Calcul Elo + `EloHistory` dans la transaction de fin de partie — `area:backend`
- [x] T6.1.3 — Écran Classé (Elo, adversaire annoncé, reprise d'une partie en cours) — `area:frontend`

---

## E7 — Multijoueur en ligne `[optionnel]`
`area:backend` `area:frontend` `priority:optional`

### US7.1 — En tant que joueur, je veux créer une partie et partager un code, afin qu'un ami me rejoigne.
Critères d'acceptation :
- Génération d'un code unique, écran "en attente d'un adversaire".

Tickets :
- [x] T7.1.1 — Endpoint `createOnlineMatch` (génération du code, session en attente) — `owner:B` `area:backend`
- [x] T7.1.2 — UI "Créer une partie" (affichage code, copier, statut) — `owner:A`/`owner:B`

### US7.2 — En tant que joueur, je veux rejoindre une partie avec un code, afin de jouer contre mon ami en temps réel.
Critères d'acceptation :
- Rejoindre via code → connexion au stream de la partie.
- Les coups des deux joueurs sont synchronisés en direct.

Tickets :
- [x] T7.2.1 — Endpoint/stream `joinOnlineMatch` (Serverpod streams) — `owner:B` `area:backend`
- [x] T7.2.2 — UI "Rejoindre une partie" + branchement du plateau sur le stream — `owner:B`
- [x] T7.2.3 — Gestion déconnexion/abandon d'un joueur (y compris perte de connexion de son propre côté — pas de pause possible en Multijoueur, cf. E10) — `owner:B` `area:backend`

### US7.3 — En tant que joueur, je veux que mon Elo soit mis à jour après une partie multijoueur, afin que mon classement reflète mon niveau face à d'autres humains. *(abandonnée)*

**Abandonnée** : le Multijoueur ne modifie pas l'Elo (cahier des charges,
§ Multijoueur et § Système Elo). Entre deux humains, l'Elo se truque
facilement — deux amis, ou un joueur avec deux comptes, se font gagner des
points en perdant exprès. L'Elo est porté par le mode Classé (E6), joué
contre un bot **par le serveur**, qui ne peut pas être truqué. Critères
d'origine, conservés pour l'historique :
- L'Elo des deux joueurs est recalculé à la fin de chaque partie multijoueur (victoire/défaite/nul).
- Reprend le principe de `US0.3` : si un résultat multijoueur a été enregistré hors-ligne (perte de connexion en cours de partie), le recalcul reste un traitement serveur séquentiel, trié par horodatage.

Tickets :
- [x] T7.3.1 — Calcul Elo (formule + K-factor) côté serveur — `owner:B` `area:backend` *(sert au Classé, E6 — `ranked/elo.dart`)*
- [ ] ~~T7.3.2 — Câblage du recalcul Elo à la fin d'une partie multijoueur (`joinOnlineMatch`/fin de stream)~~ — **abandonné** (cf. ci-dessus) — `owner:B` `area:backend`

### US7.4 — En tant que joueur, je veux voir dans l'écran Multijoueur un lobby listant les salles ouvertes, afin de rejoindre une partie sans avoir reçu de code.
Critères d'acceptation :
- À la création, l'hôte choisit si sa salle est **publique** (visible dans le lobby) ou **privée** (code seulement, comportement actuel par défaut) : une salle créée pour un ami n'est jamais exposée.
- Section « Salles ouvertes » dans l'écran Multijoueur : pseudo, Elo et avatar de l'hôte, temps restant ; sa propre salle n'y figure pas ; état vide explicite.
- Liste mise à jour en temps réel (création, départ de l'hôte, salle prise, expiration) sans recharger l'écran.
- Rejoindre depuis le lobby réutilise `joinRoom(code)` : la réservation atomique de `RoomStore.claim` tranche si deux joueurs choisissent la même salle (le perdant voit « Salle déjà prise »).
- Aucune donnée en base : le lobby est une vue des salles en mémoire, comme les salles elles-mêmes (pas de partie fantôme).

Tickets :
- [x] T7.4.1 — `RoomStore` : drapeau `isPublic` + infos d'affichage de l'hôte dans `Room`, méthode `listPublic()` ; modèle `.spy.yaml` sans table `LobbyRoom` — `owner:B` `area:backend`
- [x] T7.4.2 — Stream `MultiplayerEndpoint.watchLobby` (liste initiale puis mises à jour via `session.messages`, canal `multi.lobby`) ; paramètre `isPublic` sur `hostRoom` — `owner:B` `area:backend`
- [x] T7.4.3 — UI : interrupteur « Salle publique » + section « Salles ouvertes » (provider de stream dédié, bouton Rejoindre) — `owner:A`
- [x] T7.4.4 — Tests : `listPublic`/expiration côté `RoomStore`, stream `watchLobby`, course de deux invités sur la même salle — `owner:B` `area:backend`

---

## E8 — Leaderboard
`area:frontend` `area:backend`

### US8.1 — En tant que joueur, je veux voir un classement global, afin de me situer par rapport aux autres.
Critères d'acceptation :
- Classement par Elo, avec photo de profil, position du joueur courant mise en évidence.

Tickets :
- [x] T8.1.1 — Endpoint `getLeaderboard` (pagination) — `owner:B` `area:backend`
- [x] T8.1.2 — UI écran Classement (podium + liste) — `owner:A`

---

## E9 — Historique des parties
`area:frontend` `area:backend`

### US9.1 — En tant que joueur, je veux consulter l'historique de mes parties, afin de suivre ma progression.
Critères d'acceptation :
- Liste triée (plus récent en premier), filtrable par mode (Normal/Classé/Multi).

Tickets :
- [x] T9.1.1 — Enregistrement systématique du résultat en fin de partie (tous modes) — `owner:B` `area:backend`
- [x] T9.1.2 — Endpoint `getMatchHistory` (pagination + filtre par mode) — `owner:B` `area:backend` *(réalisé sous le nom `HistoryEndpoint.getListHistories` ; Multi/Classé seulement, les parties Normales sont lues côté client depuis la base synchronisée)*
- [x] T9.1.3 — UI écran Historique (filtres, liste) — `owner:A`

---

## E10 — Capteurs contextuels
`area:frontend`

### US10.1 — En tant que joueur, je veux pouvoir secouer le téléphone pour reset une partie non classée, afin de recommencer rapidement.
Critères d'acceptation :
- Secousse détectée (accéléromètre) → reset, uniquement en mode Normal.
- Désactivé en Ligue et Multijoueur.

Tickets :
- [x] T10.1.1 — Intégration capteur accéléromètre + détection de secousse — `owner:B`
- [x] T10.1.2 — Câblage reset conditionnel selon le mode de jeu — `owner:B`

### US10.2 — En tant que joueur, je veux que la partie se mette en pause automatiquement si je pose le téléphone à plat, afin de ne pas perdre le fil si je suis interrompu.
Critères d'acceptation :
- Détection "posé à plat" → pause automatique.
- Actif uniquement en mode Normal et Ligue (contre un bot) — **pas de pause en
  Multijoueur** (partie en direct, pas de mécanisme de pause côté serveur).

Tickets :
- [ ] T10.2.1 — Détection "posé à plat" (accéléromètre/gyroscope) — `owner:A`
- [ ] T10.2.2 — Câblage pause automatique, désactivé en mode Multijoueur — `owner:B`

---

## E11 — Internationalisation (l10n)
`area:frontend`

### US11.1 — En tant qu'utilisateur, je veux utiliser l'app en français ou en anglais, afin de la comprendre dans ma langue.
Critères d'acceptation :
- Toutes les chaînes de l'UI passent par l10n Flutter (`.arb`), FR + EN.

Tickets :
- [ ] T11.1.1 — Setup `flutter_localizations` + fichiers `.arb` FR/EN — `owner:A`
- [ ] T11.1.2 — Extraction de toutes les chaînes en dur vers l10n — `owner:A`/`owner:B`

---

## E12 — CI/CD & Qualité
`area:infra`

### US12.1 — En tant qu'équipe, on veut une CI qui lint/teste/build automatiquement, afin d'éviter les régressions.
Critères d'acceptation :
- Pipeline GitHub Actions : `flutter analyze`, `flutter test`, build APK sur chaque PR.

Tickets :
- [ ] T12.1.1 — Workflow GitHub Actions (analyze + test) — `owner:A`
- [ ] T12.1.2 — Build APK automatique (artifact sur chaque PR/merge sur main) — `owner:A`
- [ ] T12.1.3 — (optionnel) Distribution Firebase App Distribution — `owner:A`

---

## E13 — Préparation soumission Hackathon
`area:infra`

### US13.1 — En tant qu'équipe, on veut un dossier de soumission clair pour le Serverpod Hackathon, afin de maximiser le score sur les 4 critères (fonctionnement, usage de Serverpod, craft, usefulness).
Critères d'acceptation :
- README avec pitch (problème/utilisateur), captures d'écran, lien démo.
- Courte vidéo de démo montrant le flux complet (login → partie → Elo mis à jour → multijoueur).

Tickets :
- [ ] T13.1.1 — README principal (pitch EN, stack, instructions de lancement) — `owner:A`
- [ ] T13.1.2 — Vidéo de démo (flux complet) — `owner:A`/`owner:B`
- [ ] T13.1.3 — Soumission sur builderbase.com — `owner:A`

---

## E14 — Revue de partie post-match avec IA `[optionnel]`
`area:frontend` `area:backend` `area:rl` `priority:optional`

### US14.1 — En tant que joueur, je veux que la séquence complète des coups de mes parties soit enregistrée, afin de pouvoir les rejouer coup par coup lors d'une revue post-match.
Critères d'acceptation :
- La séquence ordonnée des coups (colonne jouée à chaque coup) est stockée pour toute partie terminée, en complément du résultat déjà enregistré par T9.1.1 — **dépend de E9/T9.1.1** sans le modifier. Pas d'horodatage par coup : l'ordre de la liste suffit pour rejouer la partie, et la couleur qui a joué se déduit de la parité de l'index (les couleurs alternent).
- Aucune régression sur l'enregistrement existant du résultat final (E9) : cette extension ajoute une donnée, elle ne remplace rien.
- Fonctionnalité de revue avec IA non disponible en mode invité local hors-ligne (E0) : elle nécessite une connexion réseau (cf. US14.3).

Tickets :
- [x] T14.1.1 — Étendre le modèle de partie (`.spy.yaml`, dépend de E9/T9.1.1) pour stocker la séquence ordonnée des coups — `owner:B` `area:backend`
- [x] T14.1.2 — Adapter l'enregistrement en fin de partie pour capturer chaque coup au fil de la partie (pas seulement le résultat final) — `owner:B` `area:backend`

### US14.2 — En tant que joueur, je veux revoir une partie terminée coup par coup et voir le coup que le modèle Expert aurait recommandé à chaque position, afin de comprendre mes erreurs.
Critères d'acceptation :
- Écran "Revue de partie" accessible depuis l'Historique (E9), navigation coup par coup sur un plateau reconstruit à partir de la séquence enregistrée (US14.1).
- Pour chaque position, le modèle Expert (TFLite/ONNX, déjà embarqué localement pour le bot, cf. E5/T5.1.3) est **réexécuté localement** sur l'appareil pour déterminer le coup recommandé — pas de nouvel endpoint serveur pour cette étape.
- Le coup recommandé est mis en évidence visuellement sur le plateau.
- Fonctionnalité masquée/désactivée si le modèle Expert n'est pas disponible localement.

Tickets :
- [x] T14.2.1 — UI écran "Revue de partie" (navigation coup par coup, reconstruction du plateau) — `owner:A`
- [x] T14.2.2 — Réexécution du modèle Expert local sur chaque position historique pour obtenir le coup recommandé (réutilise T5.1.3) — `owner:B`
- [x] T14.2.3 — Endpoint Serverpod pour récupérer la séquence de coups d'une partie donnée (extension de `getMatchHistory`) — `owner:B` `area:backend`

### US14.3 — En tant que joueur, je veux obtenir une explication en langage naturel de pourquoi le coup recommandé était préférable, afin de mieux comprendre la stratégie du jeu.
Critères d'acceptation :
- Depuis l'écran de revue, un bouton "Expliquer" déclenche un appel serveur vers un LLM via **Ollama cloud** (clé API stockée côté serveur uniquement, jamais côté client), avec en contexte la position, le coup joué et le coup recommandé.
- L'explication reçue est affichée sous forme de texte dans l'écran de revue.
- L'explication déjà générée pour un coup donné (clé : id de partie + index du coup) est mise en cache/persistée côté serveur pour éviter un nouvel appel Ollama lors d'une consultation ultérieure (maîtrise des coûts).
- Fonctionnalité indisponible en mode invité local/hors-ligne (E0) : nécessite une connexion réseau et un compte synchronisé.
- Message d'erreur clair si le service Ollama est indisponible/en timeout (pas de blocage de l'écran de revue).

Tickets :
- [x] T14.3.1 — Endpoint Serverpod `explainMove` (appel Ollama cloud côté serveur) — `owner:B` `area:backend`
- [x] T14.3.2 — Modèle `.spy.yaml` de cache des explications (clé : idPartie + index coup) + logique "cache hit avant appel LLM" — `owner:B` `area:backend`
- [x] T14.3.3 — UI bouton "Expliquer ce coup" + affichage du texte + gestion des erreurs/timeout — `owner:A`
- [x] T14.3.4 — Configuration sécurisée de la clé API Ollama (variable d'environnement serveur, jamais commitée) — `owner:A` `area:infra`

---

## Récapitulatif
15 epics, 28 user stories (dont US7.3 abandonnée), 79 tickets. Tout le
système d'Elo est porté par E6 (mode Classé contre un bot joué par le
serveur) ; le Multijoueur (E7) ne modifie pas l'Elo. E0 (mode invité local),
E7 (multijoueur en ligne) et E14 (revue de partie post-match avec IA) sont
marqués `[optionnel]` : socle du cours
d'abord (E1-E5, E8-E9, E11-E13), extensions ensuite (E0, E7, E14) pour la
candidature au Serverpod Hackathon. Chaque ticket ci-dessus sera créé comme
une issue GitHub individuelle (titre = ID + résumé, description = critère
d'acceptation correspondant, labels = area/type/owner/priority indiqués).
