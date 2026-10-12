import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_palette.dart';
import '../../game/view/widgets/countdown.dart';
import '../../multiplayer/view/multiplayer_screen.dart';
import '../../profile/view/profile_avatar.dart';
import '../viewmodel/friends_viewmodel.dart';
import 'friend_tile.dart';

/// Bandeau « X te défie ! » en haut de la coquille principale (E15,
/// US15.5), quel que soit l'onglet : le défi le plus récent, avec Refuser
/// et Accepter (qui rejoint la salle de l'ami).
class ChallengeBanner extends ConsumerWidget {
  const ChallengeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(friendChallengesProvider).valueOrNull;
    if (challenges == null || challenges.isEmpty) return const SizedBox();
    final challenge = challenges.first;
    final busy = ref
        .watch(friendActionsProvider)
        .contains(challenge.from.userId);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.green.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            ProfileAvatar(
              username: challenge.from.username,
              thumbnailUrl: challenge.from.thumbnailUrl,
              radius: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.challengeReceived(challenge.from.username),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Countdown(
                    deadline: challenge.expiresAt,
                    builder: (remaining) => Text(
                      formatDuration(remaining),
                      style: TextStyle(
                        color: context.colors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: context.l10n.friendDecline,
              onPressed: busy
                  ? null
                  : () async {
                      final message = await ref
                          .read(friendActionsProvider.notifier)
                          .declineChallenge(challenge);
                      if (context.mounted) {
                        showFriendsSnackBar(context, message);
                      }
                    },
              icon: Icon(Icons.close, color: context.colors.textMuted),
            ),
            FilledButton(
              onPressed: busy ? null : () => _accept(context, ref, challenge),
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.green,
              ),
              child: Text(context.l10n.friendAccept),
            ),
          ],
        ),
      ),
    );
  }

  void _accept(
    BuildContext context,
    WidgetRef ref,
    FriendChallengeDto challenge,
  ) {
    // La salle sort des défis dès qu'on la rejoint (`challengesChanged`).
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiplayerScreen(joinCode: challenge.code),
      ),
    );
  }
}
