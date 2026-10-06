import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../bot/view/bot_labels.dart';
import '../../history/view/history_screen.dart';
import '../../profile/view/profile_avatar.dart';
import '../../profile/viewmodel/profile_provider.dart';
import '../viewmodel/friends_viewmodel.dart';
import 'friend_tile.dart';
import 'friends_screen.dart';
import 'rivalry_screen.dart';

/// Sous-onglet « Rivalités » (US15.7) : ce que font tes amis cette semaine,
/// puis ton bilan tête-à-tête avec chacun.
class RivalriesTab extends ConsumerWidget {
  const RivalriesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rivalries = ref.watch(rivalriesProvider);
    final activity = ref.watch(friendsActivityProvider).valueOrNull ?? [];

    return rivalries.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => FriendsMessage(
        text: context.l10n.friendsLoadError,
        color: AppColors.yellow,
      ),
      data: (rivalries) {
        if (rivalries.isEmpty) {
          return FriendsMessage(
            text: context.l10n.rivalriesEmpty,
            actionLabel: context.l10n.friendsEmptyAction,
            onAction: () => ref
                .read(friendsTabRequestProvider.notifier)
                .open(FriendsScreen.addTabIndex),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(rivalriesProvider)
              ..invalidate(friendsActivityProvider);
            await ref.read(rivalriesProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              _SectionTitle(context.l10n.rivalriesActivity),
              if (activity.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    context.l10n.activityEmpty,
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                )
              else
                for (final event in activity.take(8)) ...[
                  _ActivityRow(event),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: 16),
              _SectionTitle(context.l10n.rivalriesHeadToHead),
              for (final rivalry in rivalries) ...[
                _RivalryRow(rivalry),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white38,
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 1,
      ),
    ),
  );
}

/// « Léa a gagné en Classé contre Bot Expert · +24 ».
class _ActivityRow extends ConsumerWidget {
  const _ActivityRow(this.event);

  final FriendActivityDto event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final me = ref.watch(myProfileProvider).valueOrNull?.username;
    final opponent = event.typePartie == EnumType.classe
        ? l10n.botDisplayName(localizedBotName(l10n, event.opponent))
        : event.opponent == me
        ? l10n.activityYou
        : event.opponent;
    final mode = event.typePartie == EnumType.classe
        ? l10n.modeRanked
        : l10n.modeMulti;
    final name = event.friend.username;
    final text = switch (event.result) {
      EnumMatchResult.win => l10n.activityWon(name, mode, opponent),
      EnumMatchResult.loss => l10n.activityLost(name, mode, opponent),
      EnumMatchResult.draw => l10n.activityDraw(name, mode, opponent),
    };
    final variation = event.eloVariation;

    return Row(
      children: [
        ProfileAvatar(
          username: event.friend.username,
          thumbnailUrl: event.friend.thumbnailUrl,
          radius: 14,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              Text(
                formatRelativeDate(context, event.at),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
        if (variation != null)
          Text(
            variation >= 0 ? '+$variation' : '$variation',
            style: TextStyle(
              color: variation >= 0 ? AppColors.green : AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
      ],
    );
  }
}

class _RivalryRow extends StatelessWidget {
  const _RivalryRow(this.rivalry);

  final RivalryDto rivalry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final played = rivalry.partieIds.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => RivalryScreen(friendUserId: rivalry.friend.userId),
        ),
      ),
      child: FriendTile(
        player: rivalry.friend,
        subtitle: played
            ? l10n.rivalryRecord(rivalry.wins, rivalry.losses, rivalry.draws)
            : l10n.rivalryNoGames,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rivalryStreakLabel(rivalry.streak) case final streak?)
              Text(
                streak,
                style: TextStyle(
                  color: rivalry.streak > 0 ? AppColors.yellow : Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

/// « 🔥 3 » à partir de deux victoires d'affilée, « ❄️ 2 » pour deux
/// défaites ; rien sinon.
String? rivalryStreakLabel(int streak) {
  if (streak >= 2) return '🔥 $streak';
  if (streak <= -2) return '❄️ ${-streak}';
  return null;
}
