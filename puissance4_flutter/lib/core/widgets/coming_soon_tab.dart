import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../l10n/l10n.dart';

/// SnackBar générique pour une action pas encore construite — partagé pour
/// éviter de recopier le même `ScaffoldMessenger.showSnackBar` dans chaque
/// écran qui a des affordances en attendant leur epic.
void showComingSoonSnackBar(BuildContext context) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.l10n.comingSoon)));
}

/// Corps d'un onglet de la coquille principale pas encore implémenté —
/// titre + context.l10n.notImplemented sur fond sombre. Partagé pour éviter de
/// recopier ce même bloc dans chaque nouvel onglet en attendant son epic.
class ComingSoonTab extends StatelessWidget {
  const ComingSoonTab({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.notImplemented,
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
