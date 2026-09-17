# Projet AdMoApp — Puissance 4 IA

## Résumé

Application mobile Flutter (Android/iOS, éventuellement Web) reprenant le jeu du
**Puissance 4**, avec authentification utilisateur, photo de profil, un mode de jeu
**1 vs 1 contre un bot** dont l'IA a été entraînée par **apprentissage par renforcement
(RL)** sur Google Colab, et un mode **multijoueur en ligne** 1 vs 1 entre deux
appareils. Le backend applicatif (comptes de jeu, Elo, leaderboard, historique,
matchmaking multijoueur temps réel, distribution des modèles RL) repose sur
**Serverpod** ; **Firebase** n'est conservé que pour l'authentification (login/
inscription). L'application est *context-aware* grâce à l'utilisation de plusieurs
capteurs (caméra, accéléromètre/gyroscope).

Le projet est développé dans le cadre du cours AdMoApp (HES-SO) et sert également de
candidature au **Serverpod Hackathon** (15 sept. – 14 oct. 2026, builderbase.com) —
d'où le choix de Serverpod comme backend plutôt qu'une solution 100% Firebase.

## Fonctionnalités principales

## Socle obligatoire vs extensions optionnelles

Pour limiter le risque du projet dans le cadre du cours, deux fonctionnalités sont
traitées comme des **extensions optionnelles**, à implémenter après un socle stable
(authentification, profil, jeu contre bot avec les 3 niveaux RL, Elo, leaderboard,
historique) :
- le **mode Multijoueur en ligne** (section 3bis) ;
- le **mode invité local / fonctionnement sans connexion dès l'installation**
  (section 0).

Ces deux extensions restent visées pour la candidature au Serverpod Hackathon, mais
ne conditionnent pas la validation du cours si le temps venait à manquer.

### 0. Mode invité local (hors-ligne dès l'installation) — optionnel
- Au tout premier lancement, sans aucune connexion réseau, l'app génère un
  **identifiant local** (UUID stocké sur l'appareil) — **aucun appel réseau**, y
  compris vers Firebase Auth (même l'auth anonyme Firebase nécessite un appel
  réseau pour créer l'utilisateur).
- Le joueur peut immédiatement jouer contre le **bot par défaut** (un modèle
  embarqué directement dans les assets de l'app, cf. section 3), et voir ses
  **stats/historique en local** (stockage local type SQLite/Hive) — pas de
  classement global visible (pas de réseau pour le récupérer), pas de mode
  Classé ni Multijoueur (nécessitent le serveur).
- Dès que le joueur se connecte (login/inscription Firebase) pour la première
  fois, l'historique et les stats accumulés localement sont **migrés** vers son
  compte de jeu Serverpod (endpoint dédié). Une fois migré, le serveur devient la
  source de vérité et le stockage local ne sert plus que de cache hors-ligne.
- **Le même mécanisme de queue locale sert aussi à un joueur déjà connecté qui perd
  sa connexion en cours d'utilisation**, que la partie jouée hors-ligne soit
  **Normale ou Classée** — pas de logique séparée entre "invité" et "connecté
  hors-ligne temporairement". Mécanisme de rattrapage :
  1. Chaque résultat terminé hors-ligne est mis en queue localement avec un
     **UUID client** (idempotence) et un horodatage.
  2. Un écouteur de connectivité détecte le retour du réseau (au premier plan ou en
     fond).
  3. La queue est envoyée à un endpoint `syncPendingResults`, **dans l'ordre
     chronologique** (indispensable pour Classé : l'Elo doit être recalculé pas à
     pas si plusieurs parties classées se sont enchaînées hors-ligne).
  4. Le serveur traite chaque résultat (incrémente les compteurs de victoires pour
     Normal, recalcule l'Elo pour Classé, ajoute l'historique), déduplique via
     l'UUID, puis renvoie le profil à jour.
  - On ne propose pas de **lancer** une nouvelle partie Classée si l'absence de
    réseau est déjà détectée (le matchmaking a besoin de l'Elo serveur à jour).

### 1. Authentification — Firebase Auth
- Login / inscription via Firebase Authentication (email/mot de passe, éventuellement
  Google Sign-In).
- Session persistante entre les lancements de l'app.
- Le token Firebase est vérifié côté serveur (Serverpod) pour associer l'utilisateur
  Firebase à son compte de jeu (profil, Elo, historique) — **point technique à
  concevoir** : pont entre l'auth Firebase (client) et le modèle utilisateur
  Serverpod (backend), Serverpod n'ayant pas nativement connaissance de Firebase.

### 2. Photo de profil — Caméra
- Prise de photo via la caméra du téléphone (capteur) à l'inscription ou depuis les
  paramètres du profil.
- Stockage de l'image côté **Serverpod** (file storage), affichage dans le profil et
  le leaderboard.

### 3. Mode de jeu — 1 vs 1 contre un bot IA
- Le joueur affronte un bot dont la stratégie est un modèle de RL entraîné en amont
  sur **Google Colab** (ex. Q-learning / DQN sur le jeu Puissance 4).
- **3 niveaux de bot** : Débutant / Moyen (medium) / Expert.
- **2 sous-modes** :
  - **Mode Normal** : le joueur **choisit lui-même** l'adversaire parmi les 3 niveaux
    de bot (débutant / medium / expert).
  - **Mode Ligue / Classé** : matchmaking **automatique** — le niveau de bot proposé
    s'adapte à l'**Elo** actuel du joueur (ex. Elo bas → bot débutant, Elo élevé →
    bot expert). Une victoire/défaite fait évoluer l'Elo (calcul façon Elo classique,
    ± points selon le niveau du bot affronté et l'issue de la partie).
- **Inférence du modèle en local** dans l'app via **TensorFlow Lite** ou **ONNX
  Runtime** (le modèle entraîné sur Colab est exporté en `.tflite` ou `.onnx`) —
  choix confirmé pour que le jeu contre le bot reste **jouable hors-ligne**.
- Un modèle de bot **par défaut** (niveau Medium) est **embarqué directement dans
  les assets de l'app** (pas téléchargé), pour garantir qu'une partie soit possible
  dès l'installation, avant même le tout premier téléchargement d'un modèle via
  Serverpod (cf. mode invité local, section 0).
- **Serverpod héberge et versionne les modèles entraînés** : l'app télécharge le
  modèle courant pour chaque niveau au premier lancement (ou lors d'une mise à jour
  du modèle) et le met en cache localement — permet de mettre à jour le bot sans
  publier une nouvelle version de l'app.
- ⚠️ Point de confiance à trancher : en mode Classé, l'inférence tournant côté
  client, rien n'empêche techniquement un joueur de falsifier le résultat remonté au
  serveur pour gonfler son Elo. À accepter comme limite connue du projet, ou à
  mitiger plus tard (ex. le serveur rejoue/valide la partie).

### 3bis. Mode Multijoueur en ligne — Serverpod — optionnel
- Défie un autre joueur en 1 vs 1, à distance, via un code de partie (créer / rejoindre).
- Synchronisation de l'état de la partie en temps réel entre les deux appareils via
  les **streams temps réel de Serverpod** (pas de polling).
- Remplace le mode "2 joueurs en local sur le même appareil" prévu initialement.
- Si l'un des deux joueurs perd sa connexion réseau en cours de partie, la partie
  est considérée **abandonnée** (pas de pause possible en Multijoueur, cf. section 4)
  — l'adversaire est notifié.

### 4. Interactions capteurs
- **Reset par secousse** : secouer le téléphone (accéléromètre) réinitialise la
  partie en cours. Actif uniquement en mode **Normal** (partie non classée contre un
  bot) — désactivé en mode **Ligue** et en **Multijoueur**, pour ne pas permettre
  d'annuler une partie qui affecte l'Elo ou qui implique un autre joueur réel.
- **Détection "posé à plat"** (accéléromètre/gyroscope) : lorsque le téléphone est
  posé à plat sur une table pendant une partie, l'app **met automatiquement la
  partie en pause**. Actif uniquement contre un bot (Normal ou Ligue) — **pas de
  pause en Multijoueur** (partie en direct contre un autre joueur, pas de mécanisme
  de pause côté serveur) — c'est ce comportement, réactif au contexte physique sans
  action explicite de l'utilisateur, qui rend l'app **context-aware**.

### 5. Classement — Leaderboard (Serverpod)
- Suivi, par utilisateur, du **nombre de victoires** contre chacun des 3 niveaux de
  bot (débutant / medium / expert) — mode Normal.
- Suivi de l'**Elo** du joueur en mode Ligue/Classé.
- Données stockées et lues depuis **Serverpod (Postgres)**.
- Écran de classement global affichant les joueurs (avec photo de profil), avec un
  classement par Elo (ligue) et/ou par nombre de victoires (mode normal).

### 6. Historique des parties
- Chaque partie terminée (Multijoueur, Normal, Ligue) est enregistrée côté
  **Serverpod (Postgres)** : date, mode, adversaire (niveau de bot ou joueur
  distant), résultat (victoire/défaite/nul), et variation d'Elo le cas échéant.
- Écran dédié dans le profil listant l'historique des parties du joueur (les plus
  récentes en premier).

## Système Elo

Formule Elo classique (celle des échecs), adaptée aux bots à niveau fixe :

**Score attendu :**

    E_joueur = 1 / (1 + 10^((Elo_bot - Elo_joueur) / 400))

**Mise à jour après la partie :**

    Elo_joueur' = Elo_joueur + K * (S - E_joueur)

où `S` = 1 (victoire), 0.5 (nul), 0 (défaite).

**Paramètres retenus :**
- **K-factor = 32** (valeur standard, progression lisible et stable).
- **Elo initial** : 1000 pour tout nouveau joueur.
- **Elo virtuel fixe des bots** (ils n'apprennent pas en jouant, donc pas besoin de
  les faire évoluer) :
  - Débutant : 800
  - Medium : 1200
  - Expert : 1600

**Seuils de matchmaking en mode Ligue** (bot proposé selon l'Elo du joueur) :
- Elo < 1000 → Débutant
- 1000 ≤ Elo < 1400 → Medium
- Elo ≥ 1400 → Expert

*Exemple :* un joueur à 1000 Elo qui bat le bot Medium (1200) obtient
E ≈ 0.24 → nouvel Elo ≈ 1000 + 32×(1-0.24) ≈ **1024**. S'il perd, son Elo descend à
≈ **992**. Gagner contre plus fort rapporte beaucoup, perdre contre plus faible coûte
beaucoup — comportement Elo classique.

(Le mode Multijoueur en ligne n'affecte pas l'Elo dans cette version — à revoir si on
veut en faire un mode classé entre joueurs réels.)

## Aspects techniques à définir / préciser dans le cahier des charges

- Modèle de données Serverpod/Postgres (utilisateurs, Elo, scores par niveau de bot,
  parties, parties multijoueur en attente/en cours).
- Schéma de **migration des données locales** (mode invité) vers le compte
  Serverpod lors du premier login (fusion des stats/historique, gestion des cas
  limites si le compte a déjà des données côté serveur).
- Pont d'authentification Firebase → Serverpod (vérification du token Firebase côté
  serveur, création/liaison du compte de jeu).
- Format d'export du modèle RL (SavedModel → TFLite, ou export ONNX) et pipeline
  d'entraînement sur Colab.
- Endpoint(s) Serverpod de distribution/versioning des modèles entraînés.
- Gestion hors-ligne : le jeu contre le bot doit fonctionner sans connexion (une fois
  le modèle téléchargé) ; seule la synchronisation du score/Elo et le multijoueur
  nécessitent le réseau.
- Choix de la librairie Flutter pour l'inférence (`tflite_flutter` vs `onnxruntime`).
- Protocole temps réel Serverpod pour le multijoueur (reconnexion, abandon/timeout
  d'un joueur, gestion du code de partie).
- Gestion des permissions caméra et capteurs de mouvement.

## Répartition des tâches (groupe de 2)

### 👤 Personne A — Firebase, UX (hors-jeu) & Infra
- UI Flutter des écrans hors-jeu (home, login, profil, leaderboard, paramètres,
  navigation, l10n).
- Login/inscription (Firebase Auth) + pont vers le compte de jeu Serverpod.
- Photo de profil (caméra + stockage Serverpod).
- Leaderboard (endpoints Serverpod, affichage classement Elo + victoires).
- Écran **historique des parties** (affichage, lecture Serverpod).
- **Détection "posé à plat"** (capteur global) → déclenche la mise en pause
  automatique de la partie en cours.
- **Pipeline CI/CD** (ex. GitHub Actions) : lint (`flutter analyze`), tests
  (`flutter test`), build automatique de l'APK, déploiement du serveur Serverpod,
  éventuellement distribution (Firebase App Distribution).

### 👤 Personne B — Backend Serverpod, Jeu & IA
- **Setup initial** : structure du repo Flutter, mise en place du projet Serverpod
  (endpoints, schéma Postgres), configuration Firebase côté client.
- UI de l'écran de jeu (plateau, pions, animations, affichage tour par tour) et
  logique du jeu Puissance 4 (règles, détection victoire/égalité).
- Les 3 sous-modes de partie : Normal (vs bot, choix du niveau), Ligue/Classé (vs
  bot, matchmaking auto), Multijoueur en ligne (via Serverpod, code de partie +
  streams temps réel).
- Reset par secousse (actif seulement en mode Normal, cf. section 4).
- Entraînement du bot RL sur Colab (3 niveaux) + export, intégration de l'inférence
  locale (TFLite/ONNX), et endpoint Serverpod de distribution des modèles.
- Système Elo (calcul, persistance côté Serverpod).
- Enregistrement du résultat de chaque partie dans Serverpod (historique, cf.
  section 6) à la fin d'un match.

Les deux se rejoignent pour l'intégration finale (connecter le moteur de jeu au
signal "posé à plat" de A, et au backend Serverpod pour l'auth/Elo/historique).

## Lien avec les critères du cours

- **Context-aware / capteurs** : caméra (photo de profil) + accéléromètre (reset par
  secousse en mode Normal, et détection "téléphone posé à plat" → mise en pause
  automatique de la partie) → au moins deux capteurs utilisés, dont un véritable
  comportement adaptatif au contexte physique (pas seulement une action explicite de
  l'utilisateur).
- **Originalité** : intégration d'un modèle de RL entraîné hors-app et exécuté en
  inférence embarquée (edge AI) plutôt qu'un simple bot à règles fixes (ex. minimax),
  combinée à un backend full-stack Dart (Serverpod) gérant multijoueur temps réel,
  Elo et distribution de modèles.
- **l10n** : app prévue en anglais + français au minimum.

## Lien entre "Main menu" et le "jeu"

Nous nous sommes mis d'accord sur un envoie à la page de jeu pour bien pouvoir séparer les taches sans devoir attendre l'autre. C'est à dire qu'en appelant le jeu, la page de jeu dois savoir : 

- Mode jeu : 
  - Bot (Normal/Ligue) ou Multijoueur en ligne
- Difficulté du bot s'il y en a un
- classé ou normal
- Les infos des joueurs (id, nom, etc...)
