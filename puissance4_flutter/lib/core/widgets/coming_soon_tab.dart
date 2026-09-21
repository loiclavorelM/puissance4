import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Corps d'un onglet de la coquille principale pas encore implémenté —
/// titre + "Pas encore implémenté" sur fond sombre. Partagé pour éviter de
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
            const Text(
              'Pas encore implémenté',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
