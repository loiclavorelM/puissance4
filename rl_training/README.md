# RL training — Puissance 4

Entraînement des bots par self-play façon **AlphaZero** (réseau résiduel
politique + valeur, guidé par un MCTS), dans un notebook Google Colab.

- `notebooks/puissance4_alphazero.ipynb` — tout le pipeline :
  1. environnement Puissance 4 (plateau vu par le joueur au trait) ;
  2. réseau PyTorch : 6 blocs résiduels de convolutions 3×3 à 64 canaux,
     tête politique (7 colonnes) et tête valeur (tanh) — 448 535 paramètres ;
  3. MCTS (PUCT, bruit de Dirichlet à la racine pendant l'entraînement) ;
  4. boucle self-play → replay buffer → entraînement, avec reprise sur
     Google Drive (checkpoint + buffer) et un snapshot toutes les 5 itérations ;
  5. évaluations : contre des bots aléatoire / glouton, contre l'ancien bot
     heuristique de l'app (négamax profondeur 5, porté en Python) et contre
     le snapshot précédent (écart d'Elo estimé, ouvertures aléatoires) ;
  6. niveaux de difficulté (`LEVELS`, section 7) : un snapshot, un nombre de
     simulations MCTS et une température par niveau ;
  7. export Keras → SavedModel → **TFLite**, avec vérification
     PyTorch = Keras = TFLite.
- `export/` — sorties du notebook (`.tflite`, SavedModel, `.pt`), **non
  versionnées** : ce sont des artefacts reproductibles.

## Les modèles dans l'application

Les 5 `.tflite` des niveaux sont copiés dans
`puissance4_flutter/assets/models/` (app) et `puissance4_server/assets/models/`
(serveur) — ce sont les seules copies versionnées. Ils sont embarqués :
aucun téléchargement, le mode Normal marche hors ligne dès l'installation.

| Niveau      | Snapshot | Simulations MCTS | Température |
|-------------|----------|------------------|-------------|
| Très facile | it000    | 0                | 1           |
| Facile      | it005    | 0                | 1           |
| Moyen       | it025    | 0                | 0           |
| Difficile   | it050    | 100              | 0           |
| Expert      | it100    | 800              | 0           |

Côté Dart (`puissance4_rules`) : `BotLevel` reprend ce tableau, `NetworkBot`
et `Mcts` portent `choose_move` et `run_mcts`, et `ConnectFourNet` recalcule
le réseau en Dart pur en lisant les poids directement dans le `.tflite`
(serveur, web). Sur Android/iOS, l'app passe par TFLite.

Pour livrer un nouveau modèle : exporter le `.tflite` depuis le notebook, le
copier aux deux endroits ci-dessus et ajuster `BotLevel` si besoin.
