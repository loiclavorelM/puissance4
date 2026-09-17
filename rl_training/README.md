# RL training — Puissance 4

- `notebooks/` — notebooks Google Colab d'entraînement par self-play (3 niveaux :
  Débutant / Medium / Expert).
- `export/` — scripts d'export SavedModel -> TFLite/ONNX.
- `env/` — environnement Puissance 4 pour l'entraînement (Python).

Les modèles entraînés (fichiers `.tflite`/`.onnx`) ne sont **pas commités** ici :
ils sont hébergés et versionnés par le backend Serverpod (endpoint
`getLatestModel`, cf. cahier des charges section Architecture technique),
à l'exception du modèle par défaut embarqué dans les assets Flutter (mode
invité local, epic E0).
