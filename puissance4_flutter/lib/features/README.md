# Architecture — Flutter (MVVM léger, feature-first)

Un dossier par feature, indépendant des autres, pour limiter les conflits git
entre Personne A et Personne B :

- `data/` — repositories : appels au client Serverpod généré, stockage local
  (SQLite/Hive) pour le mode invité/hors-ligne.
- `domain/` — modèles et règles métier simples (ex. règles du jeu, copie locale
  du calcul Elo). Pas de couche `UseCase` séparée par action.
- `presentation/` — widgets (View) + Riverpod Notifiers/Providers (ViewModel) :
  état + logique de présentation, testable sans monter de widget.

Features : `auth`, `offline`, `profile`, `game`, `bot`, `ranked`, `multiplayer`,
`leaderboard`, `history`, `settings` — cf. `doc/03-Backlog-Epics-UserStories.md`
pour le détail des tickets par feature.
