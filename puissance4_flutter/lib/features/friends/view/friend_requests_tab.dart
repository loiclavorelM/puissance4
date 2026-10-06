import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_palette.dart';
import '../viewmodel/friends_viewmodel.dart';
import 'friend_tile.dart';

/// Sous-onglet « Demandes » (US15.2) : reçues (Accepter / Refuser) puis
/// envoyées (Annuler).
class FriendRequestsTab extends ConsumerWidget {
  const FriendRequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(friendsOverviewProvider);

    return overview.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => FriendsMessage(
        text: context.l10n.friendsLoadError,
        color: context.colors.yellow,
      ),
      data: (overview) {
        final incoming = overview?.incoming ?? const <FriendshipDto>[];
        final outgoing = overview?.outgoing ?? const <FriendshipDto>[];
        if (incoming.isEmpty && outgoing.isEmpty) {
          return FriendsMessage(text: context.l10n.friendRequestsEmpty);
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            if (incoming.isNotEmpty) ...[
              _SectionTitle(context.l10n.friendRequestsReceived),
              for (final request in incoming) ...[
                _RequestRow(request),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
            ],
            if (outgoing.isNotEmpty) ...[
              _SectionTitle(context.l10n.friendRequestsSent),
              for (final request in outgoing) ...[
                _RequestRow(request),
                const SizedBox(height: 12),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: context.colors.textFaint,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _RequestRow extends ConsumerWidget {
  const _RequestRow(this.request);

  final FriendshipDto request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.read(friendActionsProvider.notifier);
    final busy = ref.watch(friendActionsProvider).contains(request.id);
    final days = DateTime.now().difference(request.createdAt.toLocal()).inDays;

    Future<void> run(Future<String?> Function() action) async {
      final message = await action();
      if (context.mounted) showFriendsSnackBar(context, message);
    }

    return FriendTile(
      player: request.other,
      subtitle: switch (days) {
        <= 0 => context.l10n.friendRequestToday,
        1 => context.l10n.friendRequestYesterday,
        _ => context.l10n.friendRequestDaysAgo(days),
      },
      trailing: request.incoming
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: context.l10n.friendDecline,
                  onPressed: busy
                      ? null
                      : () => run(() => actions.decline(request)),
                  icon: Icon(Icons.close, color: context.colors.textMuted),
                ),
                IconButton.filled(
                  tooltip: context.l10n.friendAccept,
                  onPressed: busy
                      ? null
                      : () => run(() => actions.accept(request)),
                  style: IconButton.styleFrom(
                    backgroundColor: context.colors.green,
                  ),
                  icon: Icon(Icons.check, color: context.colors.background),
                ),
              ],
            )
          : TextButton(
              onPressed: busy
                  ? null
                  : () => run(() => actions.cancel(request.id)),
              style: TextButton.styleFrom(
                foregroundColor: context.colors.textSecondary,
              ),
              child: Text(context.l10n.cancel),
            ),
    );
  }
}
