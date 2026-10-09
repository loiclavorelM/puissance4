import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'app_palette.dart';

@Preview(name: 'AppPalette dark', group: 'Theme', size: Size(420, 420))
Widget appPaletteDarkPreview() {
  return const _AppPaletteSwatches(AppPalette.dark);
}

@Preview(name: 'AppPalette light', group: 'Theme', size: Size(420, 420))
Widget appPaletteLightPreview() {
  return const _AppPaletteSwatches(AppPalette.light);
}

/// Renders every [AppPalette] role as a labeled swatch — a quick visual
/// reference so a new screen picks an existing role instead of guessing a
/// new `Color(0xFF...)`.
class _AppPaletteSwatches extends StatelessWidget {
  const _AppPaletteSwatches(this.palette);

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final entries = [
      ('background', palette.background),
      ('card', palette.card),
      ('fieldFill', palette.fieldFill),
      ('text', palette.text),
      ('textSecondary', palette.textSecondary),
      ('textMuted', palette.textMuted),
      ('textFaint', palette.textFaint),
      ('outline', palette.outline),
      ('divider', palette.divider),
      ('primary', palette.primary),
      ('yellow', palette.yellow),
      ('green', palette.green),
      ('blue', palette.blue),
    ];
    return ColoredBox(
      color: palette.background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final (label, color) in entries)
              _Swatch(label: label, color: color, palette: palette),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.label,
    required this.color,
    required this.palette,
  });

  final String label;
  final Color color;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.outline),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: palette.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
