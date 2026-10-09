import 'package:flutter/material.dart';

/// Couleurs du tableau de bord, fournies par l'app (depuis sa palette) :
/// le package ne contient aucune couleur en dur. Les définitions de widgets
/// ne parlent que de jetons (`accent`, `success`…), résolus ici.
@immutable
class DashboardTokens extends ThemeExtension<DashboardTokens> {
  const DashboardTokens({
    required this.surface,
    required this.surfaceAlt,
    required this.text,
    required this.textMuted,
    required this.grid,
    required this.accent,
    required this.success,
    required this.warn,
    required this.danger,
    required this.neutral,
    required this.rouge,
    required this.jaune,
    required this.series,
  });

  /// Fond des cartes.
  final Color surface;

  /// Fond des zones secondaires (cases vides, champs).
  final Color surfaceAlt;
  final Color text;
  final Color textMuted;

  /// Lignes de grille et séparateurs.
  final Color grid;
  final Color accent;
  final Color success;
  final Color warn;
  final Color danger;
  final Color neutral;

  /// Pions du plateau.
  final Color rouge;
  final Color jaune;

  /// Couleurs des séries sans jeton propre, dans l'ordre.
  final List<Color> series;

  /// Couleur du jeton [token] (`accent`, `success`… ou `null` → accent).
  Color resolve(String? token) => switch (token) {
    'success' => success,
    'warn' => warn,
    'danger' => danger,
    'neutral' => neutral,
    'rouge' => rouge,
    'jaune' => jaune,
    _ => accent,
  };

  /// Couleur de la [index]-ième série.
  Color seriesAt(int index) => series[index % series.length];

  @override
  DashboardTokens copyWith({
    Color? surface,
    Color? surfaceAlt,
    Color? text,
    Color? textMuted,
    Color? grid,
    Color? accent,
    Color? success,
    Color? warn,
    Color? danger,
    Color? neutral,
    Color? rouge,
    Color? jaune,
    List<Color>? series,
  }) => DashboardTokens(
    surface: surface ?? this.surface,
    surfaceAlt: surfaceAlt ?? this.surfaceAlt,
    text: text ?? this.text,
    textMuted: textMuted ?? this.textMuted,
    grid: grid ?? this.grid,
    accent: accent ?? this.accent,
    success: success ?? this.success,
    warn: warn ?? this.warn,
    danger: danger ?? this.danger,
    neutral: neutral ?? this.neutral,
    rouge: rouge ?? this.rouge,
    jaune: jaune ?? this.jaune,
    series: series ?? this.series,
  );

  @override
  DashboardTokens lerp(DashboardTokens? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return DashboardTokens(
      surface: mix(surface, other.surface),
      surfaceAlt: mix(surfaceAlt, other.surfaceAlt),
      text: mix(text, other.text),
      textMuted: mix(textMuted, other.textMuted),
      grid: mix(grid, other.grid),
      accent: mix(accent, other.accent),
      success: mix(success, other.success),
      warn: mix(warn, other.warn),
      danger: mix(danger, other.danger),
      neutral: mix(neutral, other.neutral),
      rouge: mix(rouge, other.rouge),
      jaune: mix(jaune, other.jaune),
      series: t < 0.5 ? series : other.series,
    );
  }
}

extension DashboardTokensContext on BuildContext {
  /// Jetons du thème courant ; à défaut, dérivés du `ColorScheme` (tests,
  /// aperçus qui montent un `MaterialApp` nu).
  DashboardTokens get dashboardTokens =>
      Theme.of(this).extension<DashboardTokens>() ??
      _fromScheme(Theme.of(this).colorScheme);

  static DashboardTokens _fromScheme(ColorScheme scheme) => DashboardTokens(
    surface: scheme.surface,
    surfaceAlt: scheme.surfaceContainerHighest,
    text: scheme.onSurface,
    textMuted: scheme.onSurfaceVariant,
    grid: scheme.outlineVariant,
    accent: scheme.primary,
    success: scheme.tertiary,
    warn: scheme.secondary,
    danger: scheme.error,
    neutral: scheme.outline,
    rouge: scheme.primary,
    jaune: scheme.secondary,
    series: [
      scheme.primary,
      scheme.tertiary,
      scheme.secondary,
      scheme.error,
      scheme.outline,
    ],
  );
}
