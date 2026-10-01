import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../game/view/game_screen.dart';
import '../../game/viewmodel/game_home_viewmodel.dart';
import '../model/history_item.dart';
import '../viewmodel/history_viewmodel.dart';

/// Onglet "Historique" (E9) — reprend `maquette-6.png` : chips de filtre par
/// mode au-dessus d'une liste fusionnant `Partie` (Multi/Classé, serveur) et
/// `OfflineMatchResult` (Normal, local) — voir `history_viewmodel.dart`.
/// Toucher une ligne rejoue la partie coup par coup (E14) dans l'écran de
/// partie commun.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(historyListProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historique',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 16),
          const _FilterRow(),
          const SizedBox(height: 16),
          Expanded(
            child: asyncItems.when(
              data: (items) => _HistoryList(items: items),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Impossible de charger l'historique.",
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

  static const _options = <String, EnumType?>{
    'Tous': null,
    'Normal': EnumType.normal,
    'Classé': EnumType.classe,
    'Multi': EnumType.multi,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(historyFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final entry in _options.entries) ...[
            _FilterChip(
              label: entry.key,
              selected: selected == entry.value,
              onTap: () =>
                  ref.read(historyFilterProvider.notifier).select(entry.value),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
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

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.items});

  final List<HistoryItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Aucune partie pour l\'instant.',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _HistoryTile(item: items[index]),
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.item});

  final HistoryItem item;

  Future<void> _openReplay(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final launch = await ref
          .read(historyReplayRepositoryProvider)
          .launchFor(
            item,
            myUsername: ref.read(gameHomeViewModelProvider).username,
          );
      if (launch == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              "Les coups de cette partie n'ont pas été enregistrés.",
            ),
          ),
        );
        return;
      }
      await navigator.push(
        MaterialPageRoute(builder: (_) => GameScreen(launch: launch)),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Replay indisponible pour le moment (réseau ?).'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adversaire = item.mode == EnumType.multi
        ? '@${item.adversaire}'
        : item.adversaire;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openReplay(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _ResultBadge(resultat: item.resultat),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_resultLabel(item.resultat)} · $adversaire',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_modeLabel(item.mode)} · ${_formatRelativeDate(item.date)}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _Trailing(item: item),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.resultat});

  final EnumMatchResult resultat;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (resultat) {
      EnumMatchResult.win => (AppColors.green, Icons.check),
      EnumMatchResult.loss => (AppColors.primary, Icons.close),
      EnumMatchResult.draw => (Colors.white38, Icons.circle_outlined),
    };
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final eloVariation = item.eloVariation;
    if (eloVariation != null) {
      final positive = eloVariation >= 0;
      return Text(
        '${positive ? '+' : ''}$eloVariation',
        style: TextStyle(
          color: positive ? AppColors.green : AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }
    final dotColor = item.playedAs == EnumColor.rouge
        ? AppColors.primary
        : AppColors.yellow;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
    );
  }
}

String _resultLabel(EnumMatchResult resultat) => switch (resultat) {
  EnumMatchResult.win => 'Victoire',
  EnumMatchResult.loss => 'Défaite',
  EnumMatchResult.draw => 'Match nul',
};

String _modeLabel(EnumType mode) => switch (mode) {
  EnumType.normal => 'Normal',
  EnumType.classe => 'Classé',
  EnumType.multi => 'Multijoueur',
};

String _formatRelativeDate(DateTime date) {
  final local = date.toLocal();
  final now = DateTime.now();
  final day = DateTime(local.year, local.month, local.day);
  final today = DateTime(now.year, now.month, now.day);
  final diffDays = today.difference(day).inDays;
  final time =
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';

  if (diffDays == 0) return "Aujourd'hui, $time";
  if (diffDays == 1) return 'Hier, $time';

  const weekdays = ['Lun.', 'Mar.', 'Mer.', 'Jeu.', 'Ven.', 'Sam.', 'Dim.'];
  const months = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];
  final monthDay = '${local.day} ${months[local.month - 1]}';
  if (diffDays < 7) {
    return '${weekdays[local.weekday - 1]} $monthDay, $time';
  }
  return '$monthDay ${local.year}, $time';
}
