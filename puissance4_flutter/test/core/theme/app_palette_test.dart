import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_flutter/core/theme/app_palette.dart';

/// Rapport de contraste WCAG entre [foreground] (éventuellement translucide)
/// posé sur [background] opaque.
double _contrast(Color foreground, Color background) {
  final fg = Color.alphaBlend(foreground, background);
  final a = fg.computeLuminance();
  final b = background.computeLuminance();
  return (a > b ? a + 0.05 : b + 0.05) / (a > b ? b + 0.05 : a + 0.05);
}

void main() {
  for (final (name, palette) in [
    ('dark', AppPalette.dark),
    ('light', AppPalette.light),
  ]) {
    group('$name palette', () {
      for (final (surfaceName, surface) in [
        ('background', palette.background),
        ('card', palette.card),
      ]) {
        test('body text is readable on $surfaceName (WCAG AA, 4.5:1)', () {
          for (final (role, color) in [
            ('text', palette.text),
            ('textSecondary', palette.textSecondary),
            ('textMuted', palette.textMuted),
          ]) {
            expect(
              _contrast(color, surface),
              greaterThanOrEqualTo(4.5),
              reason: '$role on $surfaceName',
            );
          }
        });

        test('hints and accents stand out on $surfaceName (3:1)', () {
          for (final (role, color) in [
            ('textFaint', palette.textFaint),
            ('primary', palette.primary),
            ('yellow', palette.yellow),
            ('green', palette.green),
            ('blue', palette.blue),
          ]) {
            expect(
              _contrast(color, surface),
              greaterThanOrEqualTo(3),
              reason: '$role on $surfaceName',
            );
          }
        });
      }
    });
  }

  testWidgets('context.colors falls back to the dark palette without the '
      'app theme', (tester) async {
    late AppPalette colors;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            colors = context.colors;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(colors, same(AppPalette.dark));
  });
}
