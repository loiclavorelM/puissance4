import 'package:flutter/material.dart';

/// Palette partagée par les écrans de la coquille principale (post
/// connexion) — mêmes teintes que `login_screen.dart`, centralisées ici
/// pour éviter de les redupliquer dans chaque nouvel écran.
abstract final class AppColors {
  static const background = Color(0xFF0D0E1F);
  static const card = Color(0xFF171A38);
  static const primary = Color(0xFFE8543F); // corail — Normal
  static const yellow = Color(0xFFF4B740); // Classé / ELO
  static const green = Color(0xFF34D399); // Multijoueur / Victoires
}
