import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../model/flat_detector.dart';

/// Mesures brutes de l'accéléromètre (m/s², gravité comprise) :
/// `(x, y, z, date)`. Remplacé dans les tests.
final gravityProvider = Provider<Stream<(double, double, double, DateTime)>>(
  (ref) => accelerometerEventStream(
    samplingPeriod: SensorInterval.uiInterval,
  ).map((e) => (e.x, e.y, e.z, e.timestamp)),
);

/// Le téléphone est posé à plat — n'émet qu'aux changements. N'écoute le
/// capteur que tant qu'un écran s'y abonne (autoDispose). Sans
/// accéléromètre (desktop, certains navigateurs), reste à `false`.
final isFlatProvider = StreamProvider.autoDispose<bool>((ref) {
  // Un seul abonnement au capteur pour un détecteur (qui garde un état).
  final detector = FlatDetector();
  final changes = StreamController<bool>.broadcast();
  var last = false;
  final subscription = ref.watch(gravityProvider).listen((m) {
    final flat = detector.add(m.$1, m.$2, m.$3, m.$4);
    if (flat != last) changes.add(last = flat);
  }, onError: (_) {});
  ref.onDispose(() {
    unawaited(subscription.cancel());
    unawaited(changes.close());
  });
  return changes.stream;
});
