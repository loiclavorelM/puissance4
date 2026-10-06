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
import '../../../core/l10n/l10n.dart';

/// Multijoueur (E7) : créer une salle (publique ou privée) et partager son
/// code, rejoindre celle d'un ami par son code, ou une salle publique du
/// lobby (US7.4). Dès que la partie commence, l'écran de partie commun
/// (`GameScreen`) prend le relais. Quitter la salle d'attente la ferme.
///
/// Depuis les Amis (E15) : [challenge] ouvre aussitôt un défi à cet ami,
/// [joinCode] rejoint aussitôt la salle d'un défi reçu.
class MultiplayerScreen extends ConsumerStatefulWidget {
  const MultiplayerScreen({super.key, this.challenge, this.joinCode});

  final FriendUserDto? challenge;
  final String? joinCode;

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
    final challenge = widget.challenge;
    final joinCode = widget.joinCode;
    if (challenge != null || joinCode != null) {
      // Pas pendant `initState` : Riverpod refuse qu'on modifie un provider
      // pendant la construction des widgets.
      Future.microtask(() {
        if (!mounted) return;
        final viewModel = ref.read(multiplayerViewModelProvider.notifier);
        if (challenge != null) {
          viewModel.challenge(challenge);
        } else {
          viewModel.join(joinCode!);
        }
      });
    }
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
        title: Text(context.l10n.modeMultiplayer),
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
            text: context.l10n.gameInProgressBanner,
            actionLabel: context.l10n.resume,
            onAction: () => viewModel.resume(resumable),
          ),
          const SizedBox(height: 20),
        ],
        Text(context.l10n.createRoomSection, style: _sectionTitleStyle),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeThumbColor: AppColors.green,
          title: Text(
            context.l10n.publicRoom,
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            _isPublic ? context.l10n.publicRoomOn : context.l10n.publicRoomOff,
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
          label: Text(context.l10n.createRoom),
        ),
        const SizedBox(height: 32),
        Text(context.l10n.openRoomsSection, style: _sectionTitleStyle),
        const SizedBox(height: 12),
        const _OpenRooms(),
        const SizedBox(height: 32),
        Text(context.l10n.joinFriendSection, style: _sectionTitleStyle),
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
            hintText: context.l10n.codeHint,
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
          child: Text(context.l10n.join),
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
      AsyncData(value: final rooms) when rooms.isEmpty => _Hint(
        context.l10n.noOpenRooms,
      ),
      AsyncData(value: final rooms) => Column(
        children: [
          for (final room in rooms) ...[
            _OpenRoomTile(room: room),
            const SizedBox(height: 8),
          ],
        ],
      ),
      AsyncError() => _Hint(context.l10n.openRoomsUnavailable),
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
                  context.l10n.roomHostInfo(
                    room.hostElo,
                    formatDuration(remaining),
                  ),
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
          child: Text(context.l10n.join),
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
    final challenged = state.challenged;
    if (challenged != null) return _ChallengeWaiting(state, challenged);
    final code = state.code ?? '';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.shareCode,
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
              ).showSnackBar(SnackBar(content: Text(context.l10n.codeCopied)));
            }
          },
          icon: const Icon(Icons.copy, color: AppColors.green),
          label: Text(
            context.l10n.copy,
            style: TextStyle(color: AppColors.green),
          ),
        ),
        const SizedBox(height: 32),
        const Center(child: CircularProgressIndicator(color: AppColors.green)),
        const SizedBox(height: 16),
        Text(
          context.l10n.waitingOpponent,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
        if (state.roomExpiresAt != null) ...[
          const SizedBox(height: 4),
          Countdown(
            deadline: state.roomExpiresAt!,
            builder: (remaining) => Text(
              context.l10n.roomClosesIn(formatDuration(remaining)),
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
          child: Text(context.l10n.cancel),
        ),
      ],
    );
  }
}

/// Salle d'attente d'un défi (E15) : pas de code à partager, l'ami a été
/// prévenu.
class _ChallengeWaiting extends ConsumerWidget {
  const _ChallengeWaiting(this.state, this.friend);

  final LobbyState state;
  final FriendUserDto friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.green,
            ),
            child: ProfileAvatar(
              username: friend.username,
              thumbnailUrl: friend.thumbnailUrl,
              radius: 44,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.challengeWaiting(friend.username),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (state.roomExpiresAt != null) ...[
          const SizedBox(height: 8),
          Countdown(
            deadline: state.roomExpiresAt!,
            builder: (remaining) => Text(
              context.l10n.roomClosesIn(formatDuration(remaining)),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        ],
        const SizedBox(height: 32),
        const Center(child: CircularProgressIndicator(color: AppColors.green)),
        const SizedBox(height: 32),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white24),
          ),
          onPressed: ref.read(multiplayerViewModelProvider.notifier).leaveRoom,
          child: Text(context.l10n.cancel),
        ),
      ],
    );
  }
}
