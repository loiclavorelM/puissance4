import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_palette.dart';
import '../../sensors/viewmodel/motion_sensors_provider.dart';
import '../../sensors/viewmodel/shake_provider.dart';
import '../../review/view/move_review_card.dart';
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
/// colonne adverse, chrono, contrôles de replay) vient du moteur. Une partie
/// recommençable (`GameLaunch.restart` : Normal) réagit à la secousse du
/// téléphone (E10) : en cours de partie, elle propose de l'arrêter (puis
/// l'écran de fin laisse le choix : nouvelle partie, revoir, retour) ; une
/// fois la partie finie, elle en lance une nouvelle.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.launch});

  final GameLaunch launch;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  StreamSubscription<GameNotice>? _notices;
  var _restarting = false;
  var _stopping = false;

  GameViewModel get _viewModel =>
      ref.read(gameViewModelProvider(widget.launch).notifier);

  @override
  void initState() {
    super.initState();
    _notices = _viewModel.notices.listen((notice) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(_noticeText(context.l10n, notice))),
      );
    });
  }

  @override
  void dispose() {
    unawaited(_notices?.cancel());
    super.dispose();
  }

  void _onShake() {
    final snapshot = ref.read(gameViewModelProvider(widget.launch));
    if (snapshot.isLive) {
      unawaited(_stop());
    } else if (snapshot.isOver) {
      unawaited(_restart());
    }
  }

  /// Arrête la partie en cours après confirmation — une secousse
  /// involontaire ne doit pas la clore. Elle se termine comme avec
  /// « Abandonner » et l'écran de fin propose la suite.
  Future<void> _stop() async {
    if (_stopping) return;
    _stopping = true;
    try {
      final snapshot = ref.read(gameViewModelProvider(widget.launch));
      final l10n = context.l10n;
      final message = snapshot.myColor == null
          // Deux joueurs sur l'appareil : c'est le joueur au trait qui
          // abandonne (cf. `LocalGameEngine.abandon`).
          ? l10n.stopLoserIsPlayerToMove
          : _viewModel.stopForfeits
          ? l10n.stopCountsAsLoss
          : l10n.stopCancels;
      if (await _confirmStop(context, message: message) &&
          mounted &&
          ref.read(gameViewModelProvider(widget.launch)).isLive) {
        // Sans attendre l'enregistrement (synchro réseau en Normal) :
        // l'écran de fin s'affiche tout de suite.
        unawaited(_viewModel.abandon());
      }
    } finally {
      _stopping = false;
    }
  }

  /// Nouvelle partie (bouton de fin de partie, ou secousse une fois la
  /// partie finie).
  Future<void> _restart() async {
    if (_restarting) return;
    _restarting = true;
    try {
      final GameLaunch next;
      try {
        next = await _viewModel.restart();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.newGameFailed)),
          );
        }
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.newGameStarted)));
      unawaited(
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => GameScreen(launch: next)),
        ),
      );
    } finally {
      _restarting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(gameViewModelProvider(widget.launch));
    final replayControls = _viewModel.replay;
    // Le capteur n'est écouté que pour une partie recommençable, sur un
    // téléphone.
    final shakeEnabled =
        _viewModel.canRestart && ref.watch(motionSensorsProvider);
    if (shakeEnabled) {
      ref.listen(shakeProvider, (_, shake) {
        if (shake is AsyncData) _onShake();
      });
    }
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
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.background,
          foregroundColor: context.colors.text,
          title: Text(widget.launch.title(context.l10n)),
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
                              label: _labelFor(context.l10n, snapshot, color),
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
                              hint: recommendedCell(snapshot),
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
      return [
        MoveReviewCard(snapshot: snapshot),
        const SizedBox(height: 8),
        ReplayBar(controls: replayControls, position: replay),
      ];
    }
    if (snapshot.isOver) {
      final replayLaunch = _viewModel.replayOfFinishedGame();
      return [
        if (_viewModel.canRestart) ...[
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _restart,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.newGame),
          ),
          const SizedBox(height: 12),
        ],
        if (replayLaunch != null && snapshot.moves.isNotEmpty)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.text,
              side: BorderSide(color: context.colors.outline),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => GameScreen(launch: replayLaunch),
              ),
            ),
            icon: const Icon(Icons.replay),
            label: Text(context.l10n.replayTitle),
          ),
        const SizedBox(height: 12),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.colors.green,
            foregroundColor: context.colors.background,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.back),
        ),
      ];
    }
    if (!snapshot.isLive) return const [];
    return [
      // Indication de secousse : seulement là où on lit l'accéléromètre.
      if (_viewModel.canRestart && ref.watch(motionSensorsProvider))
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.vibration, color: context.colors.textFaint, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                context.l10n.shakeToStop,
                style: TextStyle(color: context.colors.textFaint, fontSize: 12),
              ),
            ),
          ],
        ),
      TextButton(
        onPressed: () async {
          if (await confirmAbandon(context)) await _viewModel.abandon();
        },
        child: Text(
          context.l10n.abandon,
          style: TextStyle(color: context.colors.textMuted),
        ),
      ),
    ];
  }

  static String _noticeText(AppLocalizations l10n, GameNotice notice) =>
      switch (notice) {
        GameNotice.saveFailed => l10n.noticeSaveFailed,
        GameNotice.moveRefused => l10n.noticeMoveRefused,
        GameNotice.notYourTurn => l10n.noticeNotYourTurn,
        GameNotice.columnFull => l10n.noticeColumnFull,
        GameNotice.gameOver => l10n.noticeGameOver,
        GameNotice.moveUnconfirmed => l10n.noticeMoveUnconfirmed,
        GameNotice.gameNotFound => l10n.noticeGameNotFound,
        GameNotice.connectionLost => l10n.noticeConnectionLost,
      };

  static String _labelFor(
    AppLocalizations l10n,
    GameSnapshot snapshot,
    EnumColor color,
  ) {
    if (snapshot.myColor == null) {
      return color == EnumColor.rouge ? l10n.player1 : l10n.player2;
    }
    if (color == snapshot.myColor) return l10n.you;
    return snapshot.opponentConnected ? l10n.opponent : l10n.disconnected;
  }

  static Future<bool> _confirmStop(
    BuildContext context, {
    required String message,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.stopGameTitle),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.continueAction),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.stop),
            ),
          ],
        ),
      ) ??
      false;

  static Future<bool> confirmAbandon(BuildContext context) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.abandonTitle),
          content: Text(context.l10n.abandonMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.continueAction),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.abandon),
            ),
          ],
        ),
      ) ??
      false;
}
