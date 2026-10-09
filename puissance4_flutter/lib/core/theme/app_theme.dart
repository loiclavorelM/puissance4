import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Thème Material construit sur [palette], pour que les widgets Material
/// (dialogues, snackbars, feuilles du bas, barre d'état) suivent le même
/// thème que les écrans.
ThemeData buildAppTheme(AppPalette palette) {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: palette.brightness,
      ).copyWith(
        primary: palette.primary,
        onPrimary: Colors.white,
        surface: palette.card,
        onSurface: palette.text,
        onSurfaceVariant: palette.textSecondary,
        outline: palette.outline,
        outlineVariant: palette.divider,
      );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.background,
    dividerColor: palette.fieldFill,
    extensions: [palette],
  );
}
