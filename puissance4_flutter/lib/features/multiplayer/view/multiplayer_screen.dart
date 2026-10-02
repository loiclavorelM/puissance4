import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/action_banner.dart';
import '../../game/view/game_screen.dart';
import '../../game/view/widgets/countdown.dart';
import '../../profile/view/profile_avatar.dart';
import '../viewmodel/multiplayer_viewmodel.dart';

/// Multijoueur (E7) : créer une salle (publique ou privée) et partager son
/// code, rejoindre celle d'un ami par son code, ou une salle publique du
/// lobby (US7.4). Dès que la partie commence, l'écran de partie commun
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

  /// Privée par défaut : une salle créée pour un ami n'est jamais exposée.
  var _isPublic = false;

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
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeThumbColor: AppColors.green,
          title: const Text(
            'Salle publique',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            _isPublic
                ? 'Visible par tous dans les salles ouvertes'
                : 'Seuls ceux qui ont le code peuvent rejoindre',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          value: _isPublic,
          onChanged: (value) => setState(() => _isPublic = value),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: AppColors.background,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () => viewModel.host(isPublic: _isPublic),
          icon: const Icon(Icons.add),
          label: const Text('Créer et obtenir un code'),
        ),
        const SizedBox(height: 32),
        const Text('SALLES OUVERTES', style: _sectionTitleStyle),
        const SizedBox(height: 12),
        const _OpenRooms(),
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

/// Salles publiques des autres joueurs, à jour en temps réel.
class _OpenRooms extends ConsumerWidget {
  const _OpenRooms();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(lobbyRoomsProvider);
    return switch (rooms) {
      AsyncData(value: final rooms) when rooms.isEmpty => const _Hint(
        'Aucune salle publique pour le moment. Crée la tienne !',
      ),
      AsyncData(value: final rooms) => Column(
        children: [
          for (final room in rooms) ...[
            _OpenRoomTile(room: room),
            const SizedBox(height: 8),
          ],
        ],
      ),
      AsyncError() => const _Hint('Liste des salles indisponible.'),
      _ => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

class _OpenRoomTile extends ConsumerWidget {
  const _OpenRoomTile({required this.room});

  final LobbyRoom room;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white10),
    ),
    child: Row(
      children: [
        ProfileAvatar(
          username: room.hostUsername,
          thumbnailUrl: room.hostThumbnailUrl,
          radius: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room.hostUsername,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Countdown(
                deadline: room.expiresAt,
                builder: (remaining) => Text(
                  '${room.hostElo} Elo · ${formatDuration(remaining)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.green),
          onPressed: () => ref
              .read(multiplayerViewModelProvider.notifier)
              .join(room.code, fromLobby: true),
          child: const Text('Rejoindre'),
        ),
      ],
    ),
  );
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white38),
    ),
  );
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
