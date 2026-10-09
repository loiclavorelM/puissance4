import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

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
        color: context.colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.yellow.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: TextStyle(color: context.colors.text)),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel,
              style: TextStyle(color: context.colors.yellow),
            ),
          ),
        ],
      ),
    );
  }
}
