import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../friends/viewmodel/friends_viewmodel.dart';
import '../../profile/view/profile_avatar.dart';
import '../viewmodel/leaderboard_viewmodel.dart';
import '../../../core/l10n/l10n.dart';

/// Onglet Classement (E8) — reprend `maquette-5.png` : toggle Global/Amis,
/// podium top 3, liste des rangs 4+, et la ligne du joueur courant épinglée
/// séparément quand son rang est hors de la page chargée (voir
/// `leaderboard_viewmodel.dart` et le plan Classement). « Amis » classe le
/// joueur parmi ses amis (E15, `friendsLeaderboardProvider`).
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key, this.onAddFriends});

  /// Ouvre Amis › Ajouter (classement entre amis vide).
  final VoidCallback? onAddFriends;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(leaderboardFilterProvider);
    final asyncState = switch (filter) {
      LeaderboardFilter.global => ref.watch(leaderboardProvider),
      LeaderboardFilter.friends => ref.watch(friendsLeaderboardProvider),
    };
    final access = ref.watch(friendsAccessProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.tabLeaderboard,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 16),
          const _FilterRow(),
          const SizedBox(height: 20),
          Expanded(
            child: asyncState.when(
              data: (state) => switch ((filter, access, state)) {
                (LeaderboardFilter.friends, FriendsAccess.loading, _) =>
                  const Center(child: CircularProgressIndicator()),
                (LeaderboardFilter.friends, FriendsAccess.localGuest, _) =>
                  _CenteredMessage(context.l10n.friendsLocalGuestMessage),
                (LeaderboardFilter.friends, FriendsAccess.guest, _) =>
                  _CenteredMessage(context.l10n.friendsGuestMessage),
                (_, _, null) => _CenteredMessage(
                  context.l10n.leaderboardSignIn,
                ),
                // Seul dans son classement entre amis.
                (LeaderboardFilter.friends, _, final LeaderboardState state)
                    when state.entries.length <= 1 =>
                  _CenteredMessage(
                    context.l10n.leaderboardNoFriends,
                    actionLabel: context.l10n.friendsEmptyAction,
                    onAction: onAddFriends,
                  ),
                (_, _, final LeaderboardState state) => _LeaderboardBody(
                  state: state,
                ),
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    context.l10n.leaderboardLoadError,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.yellow,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends ConsumerWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(leaderboardFilterProvider);
    final viewModel = ref.read(leaderboardFilterProvider.notifier);
    return Row(
      children: [
        _FilterChip(
          label: context.l10n.leaderboardGlobal,
          selected: filter == LeaderboardFilter.global,
          onTap: () => viewModel.select(LeaderboardFilter.global),
        ),
        const SizedBox(width: 10),
        _FilterChip(
          label: context.l10n.leaderboardFriends,
          selected: filter == LeaderboardFilter.friends,
          onTap: () => viewModel.select(LeaderboardFilter.friends),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.white24,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage(this.text, {this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LeaderboardBody extends StatelessWidget {
  const _LeaderboardBody({required this.state});

  final LeaderboardState state;

  @override
  Widget build(BuildContext context) {
    final entries = state.entries;
    final podium = entries.take(3).toList();
    final rest = entries.length > 3
        ? entries.sublist(3)
        : const <LeaderboardEntryDto>[];
    final myRank = state.myRank;
    final isPinned = myRank.rank > entries.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (podium.isNotEmpty) _Podium(entries: podium, myId: myRank.id),
        const SizedBox(height: 20),
        Expanded(
          child: rest.isEmpty && !isPinned
              ? Center(
                  child: Text(
                    context.l10n.leaderboardAlone,
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    for (final entry in rest) ...[
                      _LeaderboardTile(
                        entry: entry,
                        isMe: entry.id == myRank.id,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (isPinned) ...[
                      const _PinnedSeparator(),
                      const SizedBox(height: 12),
                      _LeaderboardTile(entry: myRank, isMe: true),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.entries, required this.myId});

  final List<LeaderboardEntryDto> entries;

  /// `User.id` du joueur courant, mis en évidence s'il est sur le podium.
  final UuidValue myId;

  @override
  Widget build(BuildContext context) {
    final first = entries.isNotEmpty ? entries[0] : null;
    final second = entries.length > 1 ? entries[1] : null;
    final third = entries.length > 2 ? entries[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: second == null
              ? const SizedBox()
              : _PodiumSlot(
                  entry: second,
                  size: 60,
                  isMe: second.id == myId,
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: first == null
              ? const SizedBox()
              : _PodiumSlot(
                  entry: first,
                  size: 80,
                  isFirst: true,
                  isMe: first.id == myId,
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: third == null
              ? const SizedBox()
              : _PodiumSlot(
                  entry: third,
                  size: 60,
                  isMe: third.id == myId,
                ),
        ),
      ],
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.entry,
    required this.size,
    this.isFirst = false,
    this.isMe = false,
  });

  final LeaderboardEntryDto entry;
  final double size;
  final bool isFirst;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final accent = isMe
        ? AppColors.primary
        : isFirst
        ? AppColors.yellow
        : Colors.white24;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst) ...[
          const Icon(Icons.emoji_events, color: AppColors.yellow, size: 26),
          const SizedBox(height: 4),
        ],
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accent, width: isFirst || isMe ? 3 : 2),
          ),
          child: ProfileAvatar(
            username: entry.username,
            thumbnailUrl: entry.thumbnailUrl,
            radius: size / 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isMe ? context.l10n.youAnd(entry.username) : entry.username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isMe ? AppColors.primary : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        Text(
          '${entry.elo}',
          style: const TextStyle(
            color: AppColors.yellow,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.entry, this.isMe = false});

  final LeaderboardEntryDto entry;

  /// Ligne du joueur courant : encadrée et marquée « Toi », qu'elle soit
  /// dans la liste ou épinglée sous la page chargée.
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: isMe ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${entry.rank}',
              style: TextStyle(
                color: isMe ? AppColors.primary : Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ProfileAvatar(
            username: entry.username,
            thumbnailUrl: entry.thumbnailUrl,
            radius: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isMe ? context.l10n.youAnd(entry.username) : entry.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isMe ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            '${entry.elo}',
            style: TextStyle(
              color: isMe ? AppColors.primary : AppColors.yellow,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PinnedSeparator extends StatelessWidget {
  const _PinnedSeparator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '···',
        style: TextStyle(
          color: Colors.white24,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
    );
  }
}
