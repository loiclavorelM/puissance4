import 'package:assistant_ui/assistant_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_palette.dart';
import '../viewmodel/assistant_providers.dart';

/// Onglet « Stats » (E16) : le tableau de bord modulable du joueur et son
/// assistant. Tout l'affichage vient du package `assistant_ui` ; l'app
/// fournit ses ports, ses couleurs et sa coquille.
class AssistantScreen extends ConsumerWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = ref.watch(assistantAvailableProvider);
    return Theme(
      data: Theme.of(context).copyWith(
        extensions: [
          ...Theme.of(context).extensions.values,
          dashboardTokensFrom(context.colors),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                context.l10n.statsTitle,
                style: TextStyle(
                  color: context.colors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: available
                  ? AssistantDashboardView(
                      dashboard: ref.watch(dashboardControllerProvider),
                      data: ref.watch(dataSourceClientProvider),
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          context.l10n.statsServerRequired,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.colors.textMuted),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Jetons du tableau de bord tirés de la palette de l'app : les pions
/// gardent leurs couleurs du plateau, les victoires leur vert.
DashboardTokens dashboardTokensFrom(AppPalette palette) => DashboardTokens(
  surface: palette.card,
  surfaceAlt: palette.fieldFill,
  text: palette.text,
  textMuted: palette.textMuted,
  grid: palette.divider,
  accent: palette.blue,
  success: palette.green,
  warn: palette.yellow,
  danger: palette.primary,
  neutral: palette.textFaint,
  rouge: palette.primary,
  jaune: palette.yellow,
  series: [
    palette.blue,
    palette.green,
    palette.yellow,
    palette.primary,
    palette.textMuted,
  ],
);
