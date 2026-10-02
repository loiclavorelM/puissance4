import 'dart:math';

/// Reconnaît une secousse dans les mesures de l'accéléromètre, gravité
/// retirée (E10, US10.1). Pur Dart : testable sans capteur.
///
/// Une secousse = [peaksNeeded] pics au-dessus de [threshold] en moins de
/// [window] — un seul choc (téléphone posé un peu fort, bosse en voiture)
/// ne suffit pas. Après une secousse, [cooldown] avant la suivante : on ne
/// relance pas trois parties d'un même geste.
class ShakeDetector {
  ShakeDetector({
    this.threshold = 13,
    this.peaksNeeded = 3,
    this.window = const Duration(milliseconds: 1000),
    this.minPeakGap = const Duration(milliseconds: 80),
    this.cooldown = const Duration(seconds: 2),
  });

  /// Accélération (m/s², sans la gravité) à partir de laquelle une mesure
  /// compte comme un pic.
  final double threshold;
  final int peaksNeeded;
  final Duration window;

  /// Mesures plus rapprochées : un même pic, échantillonné plusieurs fois.
  final Duration minPeakGap;
  final Duration cooldown;

  final _peaks = <DateTime>[];
  DateTime? _lastShake;

  /// Ajoute une mesure ; `true` si elle complète une secousse.
  bool add(double x, double y, double z, DateTime at) {
    if (sqrt(x * x + y * y + z * z) < threshold) return false;
    final lastShake = _lastShake;
    if (lastShake != null && at.difference(lastShake) < cooldown) {
      return false;
    }
    if (_peaks.isNotEmpty && at.difference(_peaks.last) < minPeakGap) {
      return false;
    }
    _peaks
      ..add(at)
      ..removeWhere((peak) => at.difference(peak) > window);
    if (_peaks.length < peaksNeeded) return false;
    _peaks.clear();
    _lastShake = at;
    return true;
  }
}
