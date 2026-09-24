import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/theme/app_colors.dart';
import '../model/color_mapping.dart';
import '../model/game_engine.dart';
import '../model/game_launch.dart';
import '../model/game_snapshot.dart';
import '../viewmodel/game_viewmodel.dart';
import 'widgets/connect4_board_view.dart';
import 'widgets/game_status.dart';
import 'widgets/player_tile.dart';
import 'widgets/replay_bar.dart';

/// Écran de partie unique — Normal, Classé, Multi et replay. Il n'affiche
/// que le `GameSnapshot` du moteur fourni par [launch] et lui transmet les
/// colonnes touchées : ce qui diffère d'un mode à l'autre (qui choisit la
/// colonne adverse, chrono, contrôles de replay) vient du moteur.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.launch});

  final GameLaunch launch;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  StreamSubscription<String>? _notices;

  GameViewModel get _viewModel =>
      ref.read(gameViewModelProvider(widget.launch).notifier);

  @override
  void initState() {
    super.initState();
    _notices = _viewModel.notices.listen((message) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  @override
  void dispose() {
    unawaited(_notices?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(gameViewModelProvider(widget.launch));
    final replayControls = _viewModel.replay;
    final myColor = snapshot.myColor ?? EnumColor.rouge;

    return PopScope(
      canPop: !snapshot.isLive,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await confirmAbandon(context) && context.mounted) {
          await _viewModel.abandon();
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: Colors.white,
          title: Text(widget.launch.title),
        ),
        body: SafeArea(
          // Largeur plafonnée : sur un écran large (web, tablette), le plateau
          // resterait sinon aussi large que la fenêtre.
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        for (final (index, color) in [
                          myColor,
                          myColor.other,
                        ].indexed) ...[
                          if (index == 1) const SizedBox(width: 12),
                          Expanded(
                            child: PlayerTile(
                              participant: snapshot.participant(color),
                              color: color,
                              label: _labelFor(snapshot, color),
                              isActive:
                                  !snapshot.isOver &&
                                  !snapshot.isConnecting &&
                                  snapshot.colorToPlay == color,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    GameStatus(snapshot: snapshot),
                    const SizedBox(height: 16),
                    // Le plateau prend la place restante (sans jamais déborder :
                    // `AspectRatio` choisit la plus grande taille 7:6 qui tient).
                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Connect4BoardView(
                              moves: snapshot.moves,
                              highlighted: snapshot.winningCells,
                              onColumnTap: snapshot.acceptsInput
                                  ? _viewModel.play
                                  : null,
                            ),
                            if (snapshot.isConnecting)
                              const CircularProgressIndicator(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._bottom(context, snapshot, replayControls),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _bottom(
    BuildContext context,
    GameSnapshot snapshot,
    ReplayControls? replayControls,
  ) {
    final replay = snapshot.replay;
    if (replay != null && replayControls != null) {
      return [ReplayBar(controls: replayControls, position: replay)];
    }
    if (snapshot.isOver) {
      final replayLaunch = _viewModel.replayOfFinishedGame();
      return [
        if (replayLaunch != null && snapshot.moves.isNotEmpty)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => GameScreen(launch: replayLaunch),
              ),
            ),
            icon: const Icon(Icons.replay),
            label: const Text('Revoir la partie'),
          ),
        const SizedBox(height: 12),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: AppColors.background,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Retour'),
        ),
      ];
    }
    if (!snapshot.isLive) return const [];
    return [
      TextButton(
        onPressed: () async {
          if (await confirmAbandon(context)) await _viewModel.abandon();
        },
        child: const Text(
          'Abandonner',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    ];
  }

  static String _labelFor(GameSnapshot snapshot, EnumColor color) {
    if (snapshot.myColor == null) {
      return color == EnumColor.rouge ? 'Joueur 1' : 'Joueur 2';
    }
    if (color == snapshot.myColor) return 'Toi';
    return snapshot.opponentConnected ? 'Adversaire' : 'Déconnecté';
  }

  static Future<bool> confirmAbandon(BuildContext context) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Abandonner la partie ?'),
          content: const Text(
            'Quitter compte comme une défaite (ou une partie annulée si tu '
            "n'as joué aucun coup).",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Continuer'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Abandonner'),
            ),
          ],
        ),
      ) ??
      false;
}
