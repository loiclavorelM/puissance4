import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'app_colors.dart';

@Preview(name: 'AppColors palette', group: 'Theme', size: Size(420, 320))
Widget appColorsPalettePreview() {
  return const _AppColorsSwatches();
}

/// Renders every [AppColors] entry as a labeled swatch — a quick visual
/// reference so a new screen picks an existing tone instead of guessing a
/// new `Color(0xFF...)`.
class _AppColorsSwatches extends StatelessWidget {
  const _AppColorsSwatches();

  static const _entries = [
    ('background', AppColors.background),
    ('card', AppColors.card),
    ('fieldFill', AppColors.fieldFill),
    ('primary', AppColors.primary),
    ('yellow', AppColors.yellow),
    ('green', AppColors.green),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final (label, color) in _entries)
              _Swatch(label: label, color: color),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
