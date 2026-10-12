import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:flutter/material.dart';

import '../theme/dashboard_tokens.dart';
import 'chart_series.dart';

/// Couleur d'une série : le jeton de sa valeur s'il y en a un (`win` →
/// success), la couleur du widget s'il n'y a qu'une série, sinon la palette
/// des séries. « Autres » est toujours neutre.
Color seriesColor(
  DashboardTokens tokens, {
  required String? colorField,
  required Object? key,
  required int index,
  required WidgetDisplay display,
}) {
  if (key == othersKey) return tokens.neutral;
  if (colorField == null) return tokens.resolve(display.color);
  final token = AssistantContracts.catalog.fields[colorField]?.valueColors[key];
  return token != null ? tokens.resolve(token) : tokens.seriesAt(index);
}

/// Légende cliquable : un tap masque ou réaffiche une série (état
/// temporaire, la spec enregistrée ne change pas).
class ChartLegend extends StatelessWidget {
  const ChartLegend({
    super.key,
    required this.entries,
    required this.hidden,
    required this.onToggle,
  });

  final List<({Object? key, String label, Color color})> entries;
  final Set<Object?> hidden;
  final ValueChanged<Object?> onToggle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.dashboardTokens;
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final entry in entries)
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => onToggle(entry.key),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: hidden.contains(entry.key)
                          ? tokens.surfaceAlt
                          : entry.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: hidden.contains(entry.key)
                          ? tokens.textMuted
                          : tokens.text,
                      decoration: hidden.contains(entry.key)
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
