import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/initials.dart';
import '../../../core/widgets/coming_soon_tab.dart';
import '../viewmodel/leaderboard_viewmodel.dart';

/// Onglet "Classement" (E8) — reprend `maquette-5.png` : toggle
/// Global/Amis, podium top 3, liste des rangs 4+, et la ligne du joueur
/// courant épinglée séparément quand son rang est hors de la page chargée
/// (voir `leaderboard_viewmodel.dart` et le plan Classement). "Amis" n'a
/// aucune base dans le backlog : visible mais non fonctionnel, comme les
/// modes de `GameHomeScreen`.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(leaderboardProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Classement',
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
              data: (state) => state == null
                  ? const _EmptyLeaderboard()
                  : _LeaderboardBody(state: state),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Impossible de charger le classement.',
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

class _FilterRow extends StatelessWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(label: 'Global', selected: true, onTap: () {}),
        const SizedBox(width: 10),
        _FilterChip(
          label: 'Amis',
          selected: false,
          onTap: () => showComingSoonSnackBar(context),
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

class _EmptyLeaderboard extends StatelessWidget {
  const _EmptyLeaderboard();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Connecte-toi pour voir le classement.',
        style: TextStyle(color: Colors.white54, fontSize: 13),
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
        if (podium.isNotEmpty) _Podium(entries: podium),
        const SizedBox(height: 20),
        Expanded(
          child: rest.isEmpty && !isPinned
              ? const Center(
                  child: Text(
                    "Personne d'autre pour l'instant.",
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    for (final entry in rest) ...[
                      _LeaderboardTile(entry: entry),
                      const SizedBox(height: 12),
                    ],
                    if (isPinned) ...[
                      const _PinnedSeparator(),
                      const SizedBox(height: 12),
                      _LeaderboardTile(entry: myRank, pinned: true),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.entries});

  final List<LeaderboardEntryDto> entries;

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
              : _PodiumSlot(entry: second, size: 60),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: first == null
              ? const SizedBox()
              : _PodiumSlot(entry: first, size: 80, isFirst: true),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: third == null
              ? const SizedBox()
              : _PodiumSlot(entry: third, size: 60),
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
  });

  final LeaderboardEntryDto entry;
  final double size;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final accent = isFirst ? AppColors.yellow : Colors.white24;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst) ...[
          const Icon(Icons.emoji_events, color: AppColors.yellow, size: 26),
          const SizedBox(height: 4),
        ],
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.card,
            border: Border.all(color: accent, width: isFirst ? 3 : 2),
          ),
          child: Center(
            child: Text(
              initialsOf(entry.username),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isFirst ? 20 : 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
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
  const _LeaderboardTile({required this.entry, this.pinned = false});

  final LeaderboardEntryDto entry;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: pinned ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${entry.rank}',
              style: TextStyle(
                color: pinned ? AppColors.primary : Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.fieldFill,
            child: Text(
              initialsOf(entry.username),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              pinned ? 'Toi · ${entry.username}' : entry.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: pinned ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            '${entry.elo}',
            style: TextStyle(
              color: pinned ? AppColors.primary : AppColors.yellow,
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
