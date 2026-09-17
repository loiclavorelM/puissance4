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
- Aucun appel réseau au tout premier lancement (pas même Firebase Auth anonyme).
- Génération d'un identifiant local (UUID) et stockage local des stats/historique.
- Un modèle de bot par défaut est embarqué dans les assets (pas de téléchargement requis).
- Pas d'accès au classement global, à la Ligue/Classé ni au Multijoueur sans réseau.

Tickets :
- [ ] T0.1.1 — Génération et persistance d'un UUID local (sans réseau) — `owner:A`
- [ ] T0.1.2 — Stockage local des stats/historique (SQLite/Hive) — `owner:A`
- [ ] T0.1.3 — Embarquer un modèle de bot par défaut dans les assets de l'app — `owner:B` `area:rl`
- [ ] T0.1.4 — UI : indicateur "mode invité / hors-ligne", désactivation Classé/Multijoueur — `owner:A`

### US0.2 — En tant que joueur invité qui se connecte pour la première fois, je veux que mon historique et mes stats locaux soient migrés vers mon compte, afin de ne pas perdre ma progression.
Critères d'acceptation :
- Au premier login/inscription réussi, les données locales sont envoyées au serveur et fusionnées au compte.
- Après migration, le serveur devient la source de vérité (le stockage local ne sert plus que de cache).

Tickets :
- [ ] T0.2.1 — Endpoint Serverpod `migrateLocalData` (fusion des stats/historique) — `owner:B` `area:backend`
- [ ] T0.2.2 — Appel client de migration juste après le premier login réussi — `owner:A`
- [ ] T0.2.3 — Gestion du cas où le compte a déjà des données côté serveur (fusion vs conflit) — `owner:B` `area:backend`

### US0.3 — En tant que joueur déjà connecté qui perd sa connexion en cours d'utilisation, je veux que le résultat de ma partie (Normale ou Classée) ne soit pas perdu, afin que mes stats/Elo restent cohérents une fois reconnecté.
Critères d'acceptation :
- Réutilise la même queue locale que US0.1/US0.2 (pas de mécanisme séparé), pour Normal comme pour Classé.
- Chaque résultat en queue porte un UUID client (idempotence) et un horodatage.
- Au retour du réseau, la queue est envoyée à `syncPendingResults` **dans l'ordre chronologique** (obligatoire pour recalculer l'Elo pas à pas si plusieurs parties classées se sont enchaînées hors-ligne).
- Le serveur déduplique via l'UUID et renvoie le profil à jour (Elo, stats).
- Le lancement d'une **nouvelle** partie Classée est bloqué si l'absence de réseau est déjà détectée (le matchmaking a besoin de l'Elo serveur à jour).

Tickets :
- [ ] T0.3.1 — Détection de connectivité + file d'attente générique des résultats non synchronisés (UUID + horodatage) — `owner:A`
- [ ] T0.3.2 — Endpoint `syncPendingResults` (traitement séquentiel, recalcul Elo, dédup par UUID) — `owner:B` `area:backend`
- [ ] T0.3.3 — Synchronisation automatique de la queue au retour du réseau (écouteur de connectivité + retry) — `owner:A`
- [ ] T0.3.4 — Désactiver le lancement d'une partie Classée si hors-ligne détecté — `owner:A`

---

## E1 — Authentification & compte joueur
`area:backend` `area:frontend`

### US1.1 — En tant que joueur, je veux créer un compte et me connecter, afin d'accéder à mon profil et à mes stats.
Critères d'acceptation :
- Écran login/inscription (email + mot de passe) fonctionnel.
- Session persistante entre relances de l'app.

Tickets :
- [ ] T1.1.1 — UI écrans Login / Sign up (Flutter) — `owner:A`
- [ ] T1.1.2 — Intégration Firebase Auth (email/password) côté client — `owner:A`
- [ ] T1.1.3 — Persistance de session (auto-login au démarrage) — `owner:A`

### US1.2 — En tant que backend, je veux lier un utilisateur Firebase à un compte de jeu Serverpod, afin de stocker Elo/historique/profil côté serveur.
Critères d'acceptation :
- Endpoint Serverpod qui vérifie un jeton Firebase et crée/retrouve le compte de jeu.
- Le client appelle cet endpoint juste après le login Firebase.

Tickets :
- [ ] T1.2.1 — Endpoint `authenticateWithFirebase` (vérification JWT Firebase côté serveur) — `owner:B` `area:backend`
- [ ] T1.2.2 — Modèle `PlayerProfile` (schéma Postgres généré par Serverpod) — `owner:B` `area:backend`
- [ ] T1.2.3 — Appel client post-login vers cet endpoint + stockage local de la session Serverpod — `owner:A`

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
- [ ] T4.1.1 — UI du plateau + placement des pions — `owner:B`
- [ ] T4.1.2 — Logique de jeu (règles, détection victoire/égalité) — `owner:B`
- [ ] T4.1.3 — Écran de fin de partie (victoire/défaite/nul) — `owner:B`

### US4.2 — En tant que menu principal, je veux lancer l'écran de jeu avec des paramètres typés, afin que jeu et menu se développent indépendamment.
Critères d'acceptation :
- `GameLaunchParams` (cf. cahier des charges §6.1) implémenté et respecté par les deux côtés.

Tickets :
- [ ] T4.2.1 — Implémentation des classes `GameLaunchParams` / `PlayerInfo` / enums — `owner:B`
- [ ] T4.2.2 — Câblage du menu principal vers l'écran de jeu selon ce contrat — `owner:A`

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

## E6 — Mode Ligue / Classé & Système Elo
`area:backend` `area:frontend`

### US6.1 — En tant que joueur, je veux qu'un bot adapté à mon Elo me soit proposé en mode Ligue, afin d'avoir un adversaire de mon niveau.
Critères d'acceptation :
- Seuils Elo → niveau de bot appliqués (cf. cahier des charges §5).
- L'Elo est mis à jour après chaque partie classée.

Tickets :
- [ ] T6.1.1 — Écran "Mode Ligue" (matchmaking auto, sans choix manuel) — `owner:A`
- [ ] T6.1.2 — Calcul Elo (formule + K-factor) côté serveur — `owner:B` `area:backend`
- [ ] T6.1.3 — Endpoint `reportBotMatchResult` (calcule et persiste le nouvel Elo) — `owner:B` `area:backend`

---

## E7 — Multijoueur en ligne `[optionnel]`
`area:backend` `area:frontend` `priority:optional`

### US7.1 — En tant que joueur, je veux créer une partie et partager un code, afin qu'un ami me rejoigne.
Critères d'acceptation :
- Génération d'un code unique, écran "en attente d'un adversaire".

Tickets :
- [ ] T7.1.1 — Endpoint `createOnlineMatch` (génération du code, session en attente) — `owner:B` `area:backend`
- [ ] T7.1.2 — UI "Créer une partie" (affichage code, copier, statut) — `owner:A`/`owner:B`

### US7.2 — En tant que joueur, je veux rejoindre une partie avec un code, afin de jouer contre mon ami en temps réel.
Critères d'acceptation :
- Rejoindre via code → connexion au stream de la partie.
- Les coups des deux joueurs sont synchronisés en direct.

Tickets :
- [ ] T7.2.1 — Endpoint/stream `joinOnlineMatch` (Serverpod streams) — `owner:B` `area:backend`
- [ ] T7.2.2 — UI "Rejoindre une partie" + branchement du plateau sur le stream — `owner:B`
- [ ] T7.2.3 — Gestion déconnexion/abandon d'un joueur (y compris perte de connexion de son propre côté — pas de pause possible en Multijoueur, cf. E10) — `owner:B` `area:backend`

---

## E8 — Leaderboard
`area:frontend` `area:backend`

### US8.1 — En tant que joueur, je veux voir un classement global, afin de me situer par rapport aux autres.
Critères d'acceptation :
- Classement par Elo, avec photo de profil, position du joueur courant mise en évidence.

Tickets :
- [ ] T8.1.1 — Endpoint `getLeaderboard` (pagination) — `owner:B` `area:backend`
- [ ] T8.1.2 — UI écran Classement (podium + liste) — `owner:A`

---

## E9 — Historique des parties
`area:frontend` `area:backend`

### US9.1 — En tant que joueur, je veux consulter l'historique de mes parties, afin de suivre ma progression.
Critères d'acceptation :
- Liste triée (plus récent en premier), filtrable par mode (Normal/Classé/Multi).

Tickets :
- [ ] T9.1.1 — Enregistrement systématique du résultat en fin de partie (tous modes) — `owner:B` `area:backend`
- [ ] T9.1.2 — Endpoint `getMatchHistory` (pagination + filtre par mode) — `owner:B` `area:backend`
- [ ] T9.1.3 — UI écran Historique (filtres, liste) — `owner:A`

---

## E10 — Capteurs contextuels
`area:frontend`

### US10.1 — En tant que joueur, je veux pouvoir secouer le téléphone pour reset une partie non classée, afin de recommencer rapidement.
Critères d'acceptation :
- Secousse détectée (accéléromètre) → reset, uniquement en mode Normal.
- Désactivé en Ligue et Multijoueur.

Tickets :
- [ ] T10.1.1 — Intégration capteur accéléromètre + détection de secousse — `owner:B`
- [ ] T10.1.2 — Câblage reset conditionnel selon le mode de jeu — `owner:B`

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

## Récapitulatif
14 epics, 23 user stories, 64 tickets. E0 (mode invité local) et E7 (multijoueur en
ligne) sont marqués `[optionnel]` : socle du cours d'abord (E1-E6, E8-E9, E11-E13),
extensions ensuite pour la candidature au Serverpod Hackathon. Chaque ticket
ci-dessus sera créé comme une issue GitHub individuelle (titre = ID + résumé,
description = critère d'acceptation correspondant, labels = area/type/owner/priority
indiqués).
