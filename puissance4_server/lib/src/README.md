# Architecture — Serverpod backend

Un dossier par domaine fonctionnel, chacun avec ses endpoints et modèles
(`*.spy.yaml`) :

- `auth/` — pont Firebase -> compte de jeu (scaffold Serverpod par défaut à
  adapter, cf. ticket T1.2.1).
- `profile/`, `bot/`, `ranked/`, `multiplayer/`, `leaderboard/`, `history/`,
  `offline/` — un endpoint par epic du backlog (cf.
  `doc/03-Backlog-Epics-UserStories.md`).
- `generated/` — ne jamais éditer à la main (régénéré par `serverpod generate`).

`greetings/` est l'exemple par défaut de Serverpod, à supprimer une fois le
premier vrai endpoint en place.
