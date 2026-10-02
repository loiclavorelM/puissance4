import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../model/shake_detector.dart';

/// Mesures brutes de l'accéléromètre (gravité retirée) : `(x, y, z, date)`.
/// Remplacé dans les tests.
final accelerationProvider =
    Provider<Stream<(double, double, double, DateTime)>>(
      (ref) => userAccelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).map((e) => (e.x, e.y, e.z, e.timestamp)),
    );

/// Une valeur par secousse du téléphone. N'écoute le capteur que tant qu'un
/// écran s'y abonne (autoDispose). Sans accéléromètre (desktop, certains
/// navigateurs), le stream échoue ou reste muet : la secousse est
/// simplement indisponible.
final shakeProvider = StreamProvider.autoDispose<DateTime>((ref) {
  // Un seul abonnement au capteur pour un détecteur (qui garde un état) ;
  // les secousses sont ensuite diffusées à qui les écoute.
  final detector = ShakeDetector();
  final shakes = StreamController<DateTime>.broadcast();
  final subscription = ref.watch(accelerationProvider).listen((m) {
    if (detector.add(m.$1, m.$2, m.$3, m.$4)) shakes.add(m.$4);
  }, onError: shakes.addError);
  ref.onDispose(() {
    unawaited(subscription.cancel());
    unawaited(shakes.close());
  });
  return shakes.stream;
});
