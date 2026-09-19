# Architecture — Flutter (MVVM, feature-first)

Un dossier par feature, indépendant des autres, pour limiter les conflits git
entre Personne A et Personne B. Noms de dossiers imposés par le cours :

- `model/` — modèles et règles métier simples (ex. règles du jeu, copie locale
  du calcul Elo) **et** repositories : appels au client Serverpod généré,
  stockage local (SQLite/Hive) pour le mode invité/hors-ligne. Pas de couche
  `UseCase` séparée par action.
- `view/` — widgets (écrans, composants).
- `viewmodel/` — Riverpod Notifiers/Providers : état + logique de
  présentation, testable sans monter de widget.

Features : `auth`, `offline`, `profile`, `game`, `bot`, `ranked`, `multiplayer`,
`leaderboard`, `history`, `settings`, `review` — cf.
`doc/03-Backlog-Epics-UserStories.md` pour le détail des tickets par feature.
