import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/friends_viewmodel.dart';
import 'friend_tile.dart';

/// Sous-onglet « Ajouter » (US15.1) : mon code ami, puis recherche par
/// pseudo ou code ami.
class AddFriendTab extends ConsumerWidget {
  const AddFriendTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(friendSearchProvider);
    final results = search.results;

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _MyFriendCode()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: TextField(
            onChanged: ref.read(friendSearchProvider.notifier).setQuery,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.search,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: context.l10n.friendSearchHint,
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white38),
              filled: true,
              fillColor: AppColors.fieldFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        if (results == null)
          SliverToBoxAdapter(
            child: Text(
              context.l10n.friendSearchTooShort,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          )
        else
          ...results.when(
            loading: () => [
              const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (_, _) => [
              SliverToBoxAdapter(
                child: Text(
                  context.l10n.serverUnreachableLater,
                  style: const TextStyle(color: AppColors.yellow, fontSize: 13),
                ),
              ),
            ],
            data: (players) => [
              if (players.isEmpty)
                SliverToBoxAdapter(
                  child: Text(
                    context.l10n.friendSearchNoResult,
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                )
              else
                SliverList.separated(
                  itemCount: players.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _ResultRow(players[index]),
                ),
            ],
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

class _MyFriendCode extends ConsumerWidget {
  const _MyFriendCode();

  /// Même préfixe que `FriendCode.prefix` côté serveur.
  static const _prefix = 'P4-';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(friendsOverviewProvider).valueOrNull?.friendCode;
    final display = code == null ? '…' : '$_prefix$code';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.myFriendCode,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  display,
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.friendCodeHint,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.friendCodeCopy,
            onPressed: code == null
                ? null
                : () async {
                    await Clipboard.setData(ClipboardData(text: display));
                    if (context.mounted) {
                      showFriendsSnackBar(
                        context,
                        context.l10n.friendCodeCopied,
                      );
                    }
                  },
            icon: const Icon(Icons.copy, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends ConsumerWidget {
  const _ResultRow(this.result);

  final PlayerSearchResultDto result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = result.player;
    final busy = ref.watch(friendActionsProvider).contains(player.userId);

    Future<void> send() async {
      // Accepte aussi une demande reçue : le serveur la valide directement.
      final message = await ref
          .read(friendActionsProvider.notifier)
          .sendRequest(player);
      await ref.read(friendSearchProvider.notifier).refresh();
      if (context.mounted) showFriendsSnackBar(context, message);
    }

    return FriendTile(
      player: player,
      trailing: switch (result.relation) {
        EnumFriendRelation.none => FilledButton(
          onPressed: busy ? null : send,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text(context.l10n.friendAdd),
        ),
        EnumFriendRelation.requestReceived => FilledButton(
          onPressed: busy ? null : send,
          style: FilledButton.styleFrom(backgroundColor: AppColors.green),
          child: Text(context.l10n.friendAccept),
        ),
        EnumFriendRelation.requestSent => _RelationLabel(
          context.l10n.friendRelationSent,
        ),
        EnumFriendRelation.friend => _RelationLabel(
          context.l10n.friendRelationFriend,
        ),
      },
    );
  }
}

class _RelationLabel extends StatelessWidget {
  const _RelationLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
    );
  }
}
