import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../multiplayer/view/multiplayer_screen.dart';
import '../viewmodel/friends_viewmodel.dart';
import 'friend_tile.dart';
import 'friends_screen.dart';

/// Sous-onglet « Mes amis » (US15.3) : amis triés par Elo.
class FriendsListTab extends ConsumerWidget {
  const FriendsListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(friendsOverviewProvider);

    return overview.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => FriendsMessage(
        text: context.l10n.friendsLoadError,
        color: AppColors.yellow,
      ),
      data: (overview) {
        final friends = overview?.friends ?? const <FriendshipDto>[];
        if (friends.isEmpty) {
          return FriendsMessage(
            text: context.l10n.friendsEmpty,
            actionLabel: context.l10n.friendsEmptyAction,
            onAction: () => ref
                .read(friendsTabRequestProvider.notifier)
                .open(FriendsScreen.addTabIndex),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: friends.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _FriendRow(friends[index]),
        );
      },
    );
  }
}

class _FriendRow extends ConsumerWidget {
  const _FriendRow(this.friendship);

  final FriendshipDto friendship;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friend = friendship.other;
    final busy = ref.watch(friendActionsProvider).contains(friend.userId);
    final presence = friendship.presence ?? EnumFriendPresence.offline;

    return FriendTile(
      player: friend,
      presence: presence,
      subtitle: _presenceText(context, friendship),
      subtitleColor: presence == EnumFriendPresence.offline
          ? Colors.white54
          : presenceColor(presence),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: context.l10n.friendChallenge,
            // Seul un ami en ligne (et pas déjà en partie) voit le défi.
            onPressed: presence == EnumFriendPresence.online && !busy
                ? () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MultiplayerScreen(challenge: friend),
                    ),
                  )
                : null,
            color: AppColors.green,
            disabledColor: Colors.white24,
            icon: const Icon(Icons.sports_esports),
          ),
          PopupMenuButton<void>(
            enabled: !busy,
            iconColor: Colors.white54,
            color: AppColors.card,
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => _confirmRemove(context, ref, friend),
                child: Text(
                  context.l10n.friendRemove,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// « En ligne », « En partie · Classé », « Vu il y a 3 h », sinon depuis
  /// quand on est amis.
  static String _presenceText(BuildContext context, FriendshipDto friendship) {
    final l10n = context.l10n;
    switch (friendship.presence) {
      case EnumFriendPresence.online:
        return l10n.presenceOnline;
      case EnumFriendPresence.playing:
        return l10n.presencePlaying(
          friendship.playing == EnumType.classe
              ? l10n.modeRanked
              : l10n.modeMulti,
        );
      case EnumFriendPresence.offline || null:
        final seen = friendship.lastSeenAt;
        if (seen != null) {
          final ago = DateTime.now().difference(seen.toLocal());
          if (ago.inMinutes < 1) return l10n.presenceSeenJustNow;
          if (ago.inHours < 1) return l10n.presenceSeenMinutes(ago.inMinutes);
          if (ago.inDays < 1) return l10n.presenceSeenHours(ago.inHours);
          return l10n.presenceSeenDays(ago.inDays);
        }
        final locale = Localizations.localeOf(context).toLanguageTag();
        final since = friendship.respondedAt ?? friendship.createdAt;
        return l10n.friendsSince(
          DateFormat.yMMMd(locale).format(since.toLocal()),
        );
    }
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    FriendUserDto friend,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.friendRemoveTitle(friend.username)),
        content: Text(context.l10n.friendRemoveMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.friendRemove),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final message = await ref
        .read(friendActionsProvider.notifier)
        .remove(friend);
    if (context.mounted) showFriendsSnackBar(context, message);
  }
}
