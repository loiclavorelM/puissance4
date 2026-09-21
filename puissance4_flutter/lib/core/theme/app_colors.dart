import 'package:flutter/material.dart';

/// Palette partagée par tous les écrans de l'app — seule source de vérité
/// pour ces teintes, à ne jamais recopier en `Color(0xFF...)` local.
abstract final class AppColors {
  static const background = Color(0xFF0D0E1F);
  static const card = Color(0xFF171A38);
  static const fieldFill = Color(0xFF1E2247); // champs de saisie (Connexion)
  static const primary = Color(0xFFE8543F); // corail — Normal
  static const yellow = Color(0xFFF4B740); // Classé / ELO
  static const green = Color(0xFF34D399); // Multijoueur / Victoires
}
