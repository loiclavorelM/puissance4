import 'package:flutter/material.dart';

/// Palette de l'app, déclinée en thème sombre et clair — seule source de
/// vérité pour les teintes, à ne jamais recopier en `Color(0xFF...)` local
/// ni en `Colors.white70`. Les widgets la lisent via `context.colors`.
///
/// Les noms décrivent un rôle (fond, carte, texte secondaire…) et non une
/// teinte, pour que chaque thème choisisse la sienne.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.card,
    required this.fieldFill,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.textFaint,
    required this.outline,
    required this.divider,
    required this.primary,
    required this.yellow,
    required this.green,
    required this.blue,
  });

  /// Thème d'origine de l'app (maquettes), thème par défaut.
  static const dark = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF0D0E1F),
    card: Color(0xFF171A38),
    fieldFill: Color(0xFF1E2247),
    text: Colors.white,
    textSecondary: Colors.white70,
    textMuted: Colors.white54,
    textFaint: Colors.white38,
    outline: Colors.white24,
    divider: Colors.white10,
    primary: Color(0xFFC0392B),
    yellow: Color(0xFFFFD500),
    green: Color(0xFF34D399),
    blue: Color(0xFF60A5FA),
  );

  /// Accents assombris : le jaune, le vert et le bleu vifs du thème sombre
  /// ne se lisent pas sur fond blanc.
  static const light = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFF4F5FB),
    card: Color(0xFFFFFFFF),
    fieldFill: Color(0xFFE6E8F2),
    text: Color(0xFF1A1C33),
    textSecondary: Color(0xC21A1C33),
    textMuted: Color(0xA31A1C33),
    textFaint: Color(0x851A1C33),
    outline: Color(0x3D1A1C33),
    divider: Color(0x1A1A1C33),
    primary: Color(0xFFC0392B),
    yellow: Color(0xFFA16207),
    green: Color(0xFF047857),
    blue: Color(0xFF2563EB),
  );

  final Brightness brightness;

  final Color background;
  final Color card;

  /// Champs de saisie, séparateurs et bordures des cartes.
  final Color fieldFill;

  final Color text;
  final Color textSecondary;
  final Color textMuted;

  /// Indices, libellés désactivés, icônes au repos.
  final Color textFaint;

  final Color outline;
  final Color divider;

  /// Rouge — Normal.
  final Color primary;

  /// Classé / Elo.
  final Color yellow;

  /// Multijoueur / victoires.
  final Color green;

  /// Face à face (deux joueurs, local).
  final Color blue;

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? background,
    Color? card,
    Color? fieldFill,
    Color? text,
    Color? textSecondary,
    Color? textMuted,
    Color? textFaint,
    Color? outline,
    Color? divider,
    Color? primary,
    Color? yellow,
    Color? green,
    Color? blue,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      card: card ?? this.card,
      fieldFill: fieldFill ?? this.fieldFill,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
      outline: outline ?? this.outline,
      divider: divider ?? this.divider,
      primary: primary ?? this.primary,
      yellow: yellow ?? this.yellow,
      green: green ?? this.green,
      blue: blue ?? this.blue,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: mix(background, other.background),
      card: mix(card, other.card),
      fieldFill: mix(fieldFill, other.fieldFill),
      text: mix(text, other.text),
      textSecondary: mix(textSecondary, other.textSecondary),
      textMuted: mix(textMuted, other.textMuted),
      textFaint: mix(textFaint, other.textFaint),
      outline: mix(outline, other.outline),
      divider: mix(divider, other.divider),
      primary: mix(primary, other.primary),
      yellow: mix(yellow, other.yellow),
      green: mix(green, other.green),
      blue: mix(blue, other.blue),
    );
  }
}

extension AppPaletteContext on BuildContext {
  /// Palette du thème courant — sombre si l'arbre n'a pas de thème de l'app
  /// (tests qui montent un `MaterialApp` nu).
  AppPalette get colors =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}
