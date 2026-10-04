import 'dart:math';

/// Reconnaît un téléphone posé à plat (sur une table) dans les mesures
/// brutes de l'accéléromètre, gravité comprise (E10). Pur Dart : testable
/// sans capteur.
///
/// À plat = la gravité arrive presque entièrement sur l'axe z : inclinaison
/// sous [flatAngle]° pendant [settle] (un téléphone simplement tenu bien
/// droit dans la main passe par là sans y rester). Il cesse de l'être au-delà
/// de [liftAngle]° : l'écart entre les deux seuils évite de clignoter autour
/// d'une limite. Les mesures pendant un mouvement (accélération loin de 1 g)
/// sont ignorées.
class FlatDetector {
  FlatDetector({
    this.flatAngle = 10,
    this.liftAngle = 20,
    this.settle = const Duration(milliseconds: 700),
  });

  static const gravity = 9.80665;

  final double flatAngle;
  final double liftAngle;
  final Duration settle;

  bool _isFlat = false;
  DateTime? _flatSince;

  bool get isFlat => _isFlat;

  /// Ajoute une mesure (m/s²) et renvoie l'état, à plat ou non.
  bool add(double x, double y, double z, DateTime at) {
    final norm = sqrt(x * x + y * y + z * z);
    if (norm < 0.8 * gravity || norm > 1.2 * gravity) return _isFlat;
    final tilt = acos((z.abs() / norm).clamp(0, 1)) * 180 / pi;

    if (_isFlat) {
      if (tilt > liftAngle) {
        _isFlat = false;
        _flatSince = null;
      }
      return _isFlat;
    }
    if (tilt > flatAngle) {
      _flatSince = null;
      return false;
    }
    final since = _flatSince ??= at;
    _isFlat = at.difference(since) >= settle;
    return _isFlat;
  }
}
