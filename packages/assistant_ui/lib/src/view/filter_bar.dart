import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:flutter/material.dart';

import '../labels.dart';
import '../theme/dashboard_tokens.dart';

/// Filtres communs du tableau de bord (période, mode, adversaire), repris
/// par les widgets dont les paramètres valent `$dashboard.xxx`.
class DashboardFilterBar extends StatelessWidget {
  const DashboardFilterBar({
    super.key,
    required this.filters,
    required this.onChanged,
  });

  final DashboardFilters filters;
  final ValueChanged<DashboardFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = DashboardLabels.of(context);
    final modes = AssistantContracts.catalog.params['mode']!.values;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _MenuChip<String?>(
            icon: Icons.date_range,
            label: labels.range(filters.range),
            selected: filters.range != null && filters.range != 'all',
            values: [null, ...RelativeRange.values.where((v) => v != 'all')],
            labelOf: labels.range,
            onSelected: (range) =>
                onChanged(filters.copyWith(range: () => range)),
          ),
          const SizedBox(width: 8),
          _MenuChip<String?>(
            icon: Icons.sports_esports_outlined,
            label: filters.mode == null
                ? labels.l10n.filterAllModes
                : labels.value('mode', filters.mode),
            selected: filters.mode != null,
            values: [null, ...modes],
            labelOf: (mode) => mode == null
                ? labels.l10n.filterAllModes
                : labels.value('mode', mode),
            onSelected: (mode) => onChanged(filters.copyWith(mode: () => mode)),
          ),
          if (filters.opponent != null) ...[
            const SizedBox(width: 8),
            InputChip(
              avatar: const Icon(Icons.person_outline, size: 16),
              label: Text(filters.opponentLabel ?? '?'),
              selected: true,
              showCheckmark: false,
              tooltip: labels.l10n.filterClearOpponent,
              onDeleted: () => onChanged(
                filters.copyWith(
                  opponent: () => null,
                  opponentLabel: () => null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuChip<T> extends StatelessWidget {
  const _MenuChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.values,
    required this.labelOf,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.dashboardTokens;
    return PopupMenuButton<int>(
      onSelected: (index) => onSelected(values[index]),
      itemBuilder: (_) => [
        for (var i = 0; i < values.length; i++)
          PopupMenuItem(value: i, child: Text(labelOf(values[i]))),
      ],
      child: Chip(
        avatar: Icon(
          icon,
          size: 16,
          color: selected ? tokens.accent : tokens.textMuted,
        ),
        label: Text(label),
        side: BorderSide(color: selected ? tokens.accent : tokens.grid),
      ),
    );
  }
}
