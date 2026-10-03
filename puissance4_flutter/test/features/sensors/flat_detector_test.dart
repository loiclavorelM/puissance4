import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_flutter/features/sensors/model/flat_detector.dart';

void main() {
  const g = FlatDetector.gravity;
  final t0 = DateTime(2026);
  DateTime at(int ms) => t0.add(Duration(milliseconds: ms));

  /// Mesure d'un téléphone immobile incliné de [degrees]° par rapport à
  /// l'horizontale.
  bool tilted(FlatDetector d, double degrees, int ms) {
    final rad = degrees * pi / 180;
    return d.add(0, g * sin(rad), g * cos(rad), at(ms));
  }

  test('lying flat for a moment makes it flat', () {
    final d = FlatDetector();
    expect(tilted(d, 2, 0), isFalse);
    expect(tilted(d, 3, 400), isFalse);
    expect(tilted(d, 2, 800), isTrue);
  });

  test('held upright, or only briefly level, it is not flat', () {
    final d = FlatDetector();
    for (var ms = 0; ms < 3000; ms += 100) {
      expect(tilted(d, 60, ms), isFalse);
    }
    expect(tilted(d, 5, 3000), isFalse);
    expect(tilted(d, 40, 3300), isFalse);
    expect(tilted(d, 5, 3600), isFalse);
  });

  test('small wobbles keep it flat, lifting it does not', () {
    final d = FlatDetector();
    tilted(d, 0, 0);
    expect(tilted(d, 0, 800), isTrue);
    expect(tilted(d, 15, 900), isTrue); // entre les deux seuils
    expect(tilted(d, 30, 1000), isFalse);
  });

  test('readings while moving are ignored', () {
    final d = FlatDetector();
    tilted(d, 0, 0);
    expect(tilted(d, 0, 800), isTrue);
    // Choc : 2 g, mesure non fiable pour l'orientation.
    expect(d.add(2 * g, 0, 0, at(900)), isTrue);
  });

  test('upside down on the table also counts as flat', () {
    final d = FlatDetector();
    d.add(0, 0, -g, at(0));
    expect(d.add(0, 0, -g, at(800)), isTrue);
  });
}
