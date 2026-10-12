import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_palette.dart';
import '../../auth/view/create_account_screen.dart';
import '../viewmodel/friends_viewmodel.dart';
import 'add_friend_tab.dart';
import 'friend_requests_tab.dart';
import 'friend_tile.dart';
import 'friends_list_tab.dart';
import 'rivalries_tab.dart';

/// Onglet « Amis » de la barre de navigation (E15) : sous-onglets Mes amis,
/// Demandes, Ajouter et Rivalités. Réservé
/// aux comptes email.
class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  static const addTabIndex = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(friendsAccessProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.tabFriends,
            style: TextStyle(
              color: context.colors.text,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: switch (access) {
              FriendsAccess.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              FriendsAccess.localGuest => FriendsMessage(
                text: context.l10n.friendsLocalGuestMessage,
              ),
              FriendsAccess.guest => FriendsMessage(
                text: context.l10n.friendsGuestMessage,
                actionLabel: context.l10n.createAccount,
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CreateAccountScreen(),
                  ),
                ),
              ),
              FriendsAccess.member => const _FriendsTabs(),
            },
          ),
        ],
      ),
    );
  }
}

class _FriendsTabs extends ConsumerStatefulWidget {
  const _FriendsTabs();

  @override
  ConsumerState<_FriendsTabs> createState() => _FriendsTabsState();
}

class _FriendsTabsState extends ConsumerState<_FriendsTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _controller = TabController(
    length: 4,
    vsync: this,
    // Demande faite avant que l'onglet n'existe (ex. depuis le Classement).
    initialIndex: _takeRequest() ?? 0,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTabChanged);
  }

  /// Ouvrir « Ajouter » recharge « Rencontrés récemment » : une partie a pu
  /// se finir depuis (le temps réel le fait aussi, s'il n'est pas coupé).
  void _onTabChanged() {
    if (!_controller.indexIsChanging &&
        _controller.index == FriendsScreen.addTabIndex) {
      ref.invalidate(recentOpponentsProvider);
    }
  }

  int? _takeRequest() {
    final request = ref.read(friendsTabRequestProvider);
    if (request != null) {
      Future.microtask(ref.read(friendsTabRequestProvider.notifier).clear);
    }
    return request;
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incoming = ref.watch(incomingFriendRequestCountProvider);
    ref.listen(friendsTabRequestProvider, (_, request) {
      if (request == null) return;
      _controller.animateTo(request);
      ref.read(friendsTabRequestProvider.notifier).clear();
    });

    return Column(
      children: [
        TabBar(
          controller: _controller,
          // Les 4 onglets restent visibles même sur un écran de 360 dp.
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          labelColor: context.colors.primary,
          unselectedLabelColor: context.colors.textMuted,
          indicatorColor: context.colors.primary,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: [
            Tab(text: context.l10n.friendsTabList),
            Tab(
              child: Badge(
                isLabelVisible: incoming > 0,
                label: Text('$incoming'),
                offset: const Offset(14, -4),
                child: Text(context.l10n.friendsTabRequests),
              ),
            ),
            Tab(text: context.l10n.friendsTabAdd),
            Tab(text: context.l10n.friendsTabRivalries),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: [
              const FriendsListTab(),
              const FriendRequestsTab(),
              const AddFriendTab(),
              const RivalriesTab(),
            ],
          ),
        ),
      ],
    );
  }
}
