import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../sensors/viewmodel/motion_sensors_provider.dart';
import '../viewmodel/add_in_person_viewmodel.dart';
import '../viewmodel/friends_viewmodel.dart';
import 'friend_code_qr.dart';
import 'friend_tile.dart';
import 'shake_to_add_sheet.dart';

/// Sous-onglet « Ajouter » (US15.1, US15.6) : mon code ami (et son QR),
/// l'ajout en personne (scanner un QR, secouer ensemble), puis la recherche
/// par pseudo ou code ami.
class AddFriendTab extends ConsumerStatefulWidget {
  const AddFriendTab({super.key});

  @override
  ConsumerState<AddFriendTab> createState() => _AddFriendTabState();
}

class _AddFriendTabState extends ConsumerState<AddFriendTab> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  /// Un QR scanné remplit la recherche : son propriétaire apparaît avec
  /// le bouton Ajouter.
  Future<void> _scan() async {
    final code = await scanFriendCode(context);
    if (code == null || !mounted) return;
    _query.text = code;
    ref.read(friendSearchProvider.notifier).setQuery(code);
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(friendSearchProvider);
    final results = search.results;
    final canScan = ref.watch(qrScanSupportedProvider);
    final canShake = ref.watch(motionSensorsProvider);

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _MyFriendCode()),
        if (canScan || canShake)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  if (canScan)
                    Expanded(
                      child: _InPersonButton(
                        icon: Icons.qr_code_scanner,
                        label: context.l10n.friendScanQr,
                        onPressed: _scan,
                      ),
                    ),
                  if (canScan && canShake) const SizedBox(width: 12),
                  if (canShake)
                    Expanded(
                      child: _InPersonButton(
                        icon: Icons.vibration,
                        label: context.l10n.friendShakeToAdd,
                        onPressed: () => showShakeToAddSheet(context),
                      ),
                    ),
                ],
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: TextField(
            controller: _query,
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
        if (results == null) ...[
          SliverToBoxAdapter(
            child: Text(
              context.l10n.friendSearchTooShort,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
          ..._recentOpponents(context, ref),
        ] else
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
                  itemBuilder: (context, index) =>
                      PlayerResultRow(players[index]),
                ),
            ],
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

/// « Rencontrés récemment » (US15.5) sous la recherche vide : derniers
/// adversaires Multi, à ajouter en un tap. Toujours affichée une fois
/// chargée — vide, elle explique ce qui y apparaîtra.
List<Widget> _recentOpponents(BuildContext context, WidgetRef ref) {
  final recent = ref.watch(recentOpponentsProvider).valueOrNull;
  if (recent == null) return const [];
  return [
    const SliverToBoxAdapter(child: SizedBox(height: 24)),
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          context.l10n.recentOpponents,
          style: const TextStyle(
            color: Colors.white38,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ),
    ),
    if (recent.isEmpty)
      SliverToBoxAdapter(
        child: Text(
          context.l10n.recentOpponentsEmpty,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
      )
    else
      SliverList.separated(
        itemCount: recent.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => PlayerResultRow(recent[index]),
      ),
  ];
}

class _InPersonButton extends StatelessWidget {
  const _InPersonButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icon, color: AppColors.green),
      label: Text(label, overflow: TextOverflow.ellipsis),
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
            tooltip: context.l10n.friendShowQr,
            onPressed: code == null
                ? null
                : () => showFriendCodeQr(context, display),
            icon: const Icon(Icons.qr_code_2, color: Colors.white70),
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

/// Un joueur trouvé (recherche, rencontres récentes, secousse) avec
/// l'action qui correspond à sa relation : Ajouter, Accepter, ou son état.
class PlayerResultRow extends ConsumerWidget {
  const PlayerResultRow(this.result, {super.key, this.onSent});

  final PlayerSearchResultDto result;

  /// Après l'envoi de la demande (ex. fermer la feuille de secousse).
  final VoidCallback? onSent;

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
      onSent?.call();
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
