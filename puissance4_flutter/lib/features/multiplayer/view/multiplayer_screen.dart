import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/action_banner.dart';
import '../../game/view/game_screen.dart';
import '../../game/view/widgets/countdown.dart';
import '../viewmodel/multiplayer_viewmodel.dart';

/// Multijoueur (E7) : créer une salle et partager son code, ou rejoindre
/// celle d'un ami. Dès que la partie commence, l'écran de partie commun
/// (`GameScreen`) prend le relais. Quitter la salle d'attente la ferme.
class MultiplayerScreen extends ConsumerStatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  ConsumerState<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends ConsumerState<MultiplayerScreen> {
  StreamSubscription<Object>? _launches;

  @override
  void initState() {
    super.initState();
    _launches = ref.read(multiplayerViewModelProvider.notifier).launches.listen(
      (launch) {
        if (!mounted) return;
        unawaited(
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => GameScreen(launch: launch)),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    unawaited(_launches?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(multiplayerViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: const Text('Multijoueur'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: switch (state.phase) {
            LobbyPhase.idle => _Lobby(state: state),
            LobbyPhase.connecting => const Center(
              child: CircularProgressIndicator(),
            ),
            LobbyPhase.hosting => _WaitingRoom(state: state),
          },
        ),
      ),
    );
  }
}

const _sectionTitleStyle = TextStyle(
  color: Colors.white54,
  fontSize: 12,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.2,
);

class _Lobby extends ConsumerStatefulWidget {
  const _Lobby({required this.state});

  final LobbyState state;

  @override
  ConsumerState<_Lobby> createState() => _LobbyState();
}

class _LobbyState extends ConsumerState<_Lobby> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final viewModel = ref.read(multiplayerViewModelProvider.notifier);
    final resumable = state.resumablePartieId;

    return ListView(
      children: [
        if (resumable != null) ...[
          ActionBanner(
            text: 'Tu as une partie en cours.',
            actionLabel: 'Reprendre',
            onAction: () => viewModel.resume(resumable),
          ),
          const SizedBox(height: 20),
        ],
        const Text('CRÉER UNE SALLE', style: _sectionTitleStyle),
        const SizedBox(height: 12),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: AppColors.background,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: viewModel.host,
          icon: const Icon(Icons.add),
          label: const Text('Créer et obtenir un code'),
        ),
        const SizedBox(height: 32),
        const Text('REJOINDRE UN AMI', style: _sectionTitleStyle),
        const SizedBox(height: 12),
        TextField(
          controller: _codeController,
          textCapitalization: TextCapitalization.characters,
          maxLength: 6,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            letterSpacing: 6,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'CODE',
            hintStyle: const TextStyle(color: Colors.white24),
            counterText: '',
            filled: true,
            fillColor: AppColors.fieldFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: viewModel.join,
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white24),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () => viewModel.join(_codeController.text),
          child: const Text('Rejoindre'),
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.yellow),
          ),
        ],
      ],
    );
  }
}

class _WaitingRoom extends ConsumerWidget {
  const _WaitingRoom({required this.state});

  final LobbyState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = state.code ?? '';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'PARTAGE CE CODE',
          textAlign: TextAlign.center,
          style: _sectionTitleStyle,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
          ),
          child: SelectableText(
            code,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 10,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: code));
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Code copié')));
            }
          },
          icon: const Icon(Icons.copy, color: AppColors.green),
          label: const Text(
            'Copier',
            style: TextStyle(color: AppColors.green),
          ),
        ),
        const SizedBox(height: 32),
        const Center(child: CircularProgressIndicator(color: AppColors.green)),
        const SizedBox(height: 16),
        const Text(
          'En attente d\'un adversaire…',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
        if (state.roomExpiresAt != null) ...[
          const SizedBox(height: 4),
          Countdown(
            deadline: state.roomExpiresAt!,
            builder: (remaining) => Text(
              'La salle se ferme dans ${formatDuration(remaining)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        ],
        const SizedBox(height: 32),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white24),
          ),
          onPressed: ref.read(multiplayerViewModelProvider.notifier).leaveRoom,
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
