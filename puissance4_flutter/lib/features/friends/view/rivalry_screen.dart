import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_palette.dart';
import '../../history/view/history_screen.dart';
import '../../history/viewmodel/history_viewmodel.dart';
import '../../multiplayer/view/multiplayer_screen.dart';
import '../../profile/view/profile_avatar.dart';
import '../../profile/viewmodel/profile_provider.dart';
import '../viewmodel/friends_viewmodel.dart';
import 'rivalries_tab.dart';

/// Tête-à-tête avec un ami (US15.7) : le score, la série en cours, un
/// bouton pour le défier, et vos parties communes — rejouables comme dans
/// l'Historique.
class RivalryScreen extends ConsumerWidget {
  const RivalryScreen({super.key, required this.friendUserId});

  final UuidValue friendUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final rivalry = ref
        .watch(rivalriesProvider)
        .valueOrNull
        ?.where((r) => r.friend.userId == friendUserId)
        .firstOrNull;
    final presence = ref
        .watch(friendsOverviewProvider)
        .valueOrNull
        ?.friends
        .where((f) => f.other.userId == friendUserId)
        .firstOrNull
        ?.presence;
    final history = ref.watch(serverHistoryProvider).valueOrNull ?? [];
    final ids = {for (final id in rivalry?.partieIds ?? []) id.toString()};
    final games = [
      for (final item in history)
        if (ids.contains(item.id)) item,
    ];

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.text,
        title: Text(rivalry?.friend.username ?? ''),
      ),
      body: rivalry == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                _Scoreboard(rivalry),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: presence == EnumFriendPresence.online
                      ? () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                MultiplayerScreen(challenge: rivalry.friend),
                          ),
                        )
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.sports_esports),
                  label: Text(
                    presence == EnumFriendPresence.online
                        ? l10n.friendChallenge
                        : l10n.rivalryChallengeOffline,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.rivalryGames,
                  style: TextStyle(
                    color: context.colors.textFaint,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                if (games.isEmpty)
                  Text(
                    l10n.rivalryGamesEmpty,
                    style: TextStyle(
                      color: context.colors.textFaint,
                      fontSize: 13,
                    ),
                  )
                else
                  for (final item in games) ...[
                    HistoryTile(item: item),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
    );
  }
}

/// « Toi 3 – 1 Léa », nuls et série en dessous.
class _Scoreboard extends ConsumerWidget {
  const _Scoreboard(this.rivalry);

  final RivalryDto rivalry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final me = ref.watch(myProfileProvider).valueOrNull;
    final streak = rivalryStreakLabel(rivalry.streak);

    Widget side(String username, String? thumbnailUrl, String label) => Column(
      children: [
        ProfileAvatar(
          username: username,
          thumbnailUrl: thumbnailUrl,
          radius: 28,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: side(me?.username ?? '', me?.thumbnailUrl, l10n.you),
              ),
              Text(
                '${rivalry.wins} – ${rivalry.losses}',
                style: TextStyle(
                  color: context.colors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
              Expanded(
                child: side(
                  rivalry.friend.username,
                  rivalry.friend.thumbnailUrl,
                  rivalry.friend.username,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            [
              l10n.rivalryDraws(rivalry.draws),
              ?streak,
            ].join(' · '),
            style: TextStyle(color: context.colors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
