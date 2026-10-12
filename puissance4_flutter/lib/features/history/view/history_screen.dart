import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_palette.dart';
import '../../game/view/game_screen.dart';
import '../../game/viewmodel/game_home_viewmodel.dart';
import '../model/history_item.dart';
import '../viewmodel/history_viewmodel.dart';
import '../../bot/view/bot_labels.dart';

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
          Text(
            context.l10n.historyTitle,
            style: TextStyle(
              color: context.colors.text,
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
                    context.l10n.historyLoadError,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.colors.yellow,
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
    final selected = ref.watch(historyFilterProvider);
    final l10n = context.l10n;
    final options = <String, EnumType?>{
      l10n.filterAll: null,
      l10n.modeNormal: EnumType.normal,
      l10n.modeRanked: EnumType.classe,
      l10n.modeMulti: EnumType.multi,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final entry in options.entries) ...[
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
              color: selected ? context.colors.primary : context.colors.outline,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? context.colors.primary
                  : context.colors.textSecondary,
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
      return Center(
        child: Text(
          context.l10n.historyEmpty,
          style: TextStyle(color: context.colors.textMuted, fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => HistoryTile(item: items[index]),
    );
  }
}

/// Une partie terminée : résultat, adversaire, mode, date — un tap la
/// rejoue. Aussi utilisée par le tête-à-tête des Amis (E15).
class HistoryTile extends ConsumerWidget {
  const HistoryTile({super.key, required this.item});

  final HistoryItem item;

  Future<void> _openReplay(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = context.l10n;
    try {
      final launch = await ref
          .read(historyReplayRepositoryProvider)
          .launchFor(
            item,
            myUsername: ref.read(gameHomeViewModelProvider).username,
          );
      if (launch == null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.replayNoMoves)));
        return;
      }
      await navigator.push(
        MaterialPageRoute(builder: (_) => GameScreen(launch: launch)),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.replayUnavailable)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adversaire = item.mode == EnumType.multi
        ? '@${item.adversaire}'
        : context.l10n.botDisplayName(
            localizedBotName(context.l10n, item.adversaire),
          );

    return Material(
      color: context.colors.card,
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
                      '${_resultLabel(context, item.resultat)} · $adversaire',
                      style: TextStyle(
                        color: context.colors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_modeLabel(context, item.mode)} · '
                      '${formatRelativeDate(context, item.date)}',
                      style: TextStyle(
                        color: context.colors.textMuted,
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
      EnumMatchResult.win => (context.colors.green, Icons.check),
      EnumMatchResult.loss => (context.colors.primary, Icons.close),
      EnumMatchResult.draw => (context.colors.textFaint, Icons.circle_outlined),
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
          color: positive ? context.colors.green : context.colors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }
    final dotColor = item.playedAs == EnumColor.rouge
        ? context.colors.primary
        : context.colors.yellow;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
    );
  }
}

String _resultLabel(BuildContext context, EnumMatchResult resultat) =>
    switch (resultat) {
      EnumMatchResult.win => context.l10n.resultWin,
      EnumMatchResult.loss => context.l10n.resultLoss,
      EnumMatchResult.draw => context.l10n.resultDraw,
    };

String _modeLabel(BuildContext context, EnumType mode) => switch (mode) {
  EnumType.normal => context.l10n.modeNormal,
  EnumType.classe => context.l10n.modeRanked,
  EnumType.multi => context.l10n.modeMultiplayer,
};

/// « Aujourd'hui, 14:05 », « Hier, … », jour de la semaine sous 7 jours,
/// sinon la date — mois et jours dans la langue de l'app.
String formatRelativeDate(BuildContext context, DateTime date) {
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  final local = date.toLocal();
  final now = DateTime.now();
  final day = DateTime(local.year, local.month, local.day);
  final today = DateTime(now.year, now.month, now.day);
  final diffDays = today.difference(day).inDays;
  final time = DateFormat.Hm(locale).format(local);

  if (diffDays == 0) return l10n.dateToday(time);
  if (diffDays == 1) return l10n.dateYesterday(time);
  if (diffDays < 7) {
    return '${DateFormat.MMMEd(locale).format(local)}, $time';
  }
  return '${DateFormat.yMMMd(locale).format(local)}, $time';
}
