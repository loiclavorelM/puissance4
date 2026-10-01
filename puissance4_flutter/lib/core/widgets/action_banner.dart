import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bandeau d'information avec une action (ex. « Tu as une partie en cours —
/// Reprendre »), partagé par les écrans Multi et Classé.
class ActionBanner extends StatelessWidget {
  const ActionBanner({
    super.key,
    required this.text,
    required this.actionLabel,
    required this.onAction,
  });

  final String text;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(color: AppColors.yellow),
            ),
          ),
        ],
      ),
    );
  }
}
