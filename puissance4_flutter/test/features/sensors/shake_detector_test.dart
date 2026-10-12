import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_flutter/features/sensors/model/shake_detector.dart';

void main() {
  final t0 = DateTime(2026);
  DateTime at(int ms) => t0.add(Duration(milliseconds: ms));

  /// Envoie un pic (20 m/s² sur x) à chacun des instants [ms].
  List<bool> peaks(ShakeDetector detector, List<int> ms) => [
    for (final m in ms) detector.add(20, 0, 0, at(m)),
  ];

  test('three strong peaks within a second make a shake', () {
    expect(peaks(ShakeDetector(), [0, 200, 400]), [false, false, true]);
  });

  test('a single bump or gentle moves are not a shake', () {
    final detector = ShakeDetector();
    expect(peaks(detector, [0]), [false]);
    for (var ms = 100; ms < 1000; ms += 100) {
      expect(detector.add(5, 5, 0, at(ms)), isFalse);
    }
  });

  test('peaks too far apart do not add up', () {
    expect(peaks(ShakeDetector(), [0, 700, 1400, 2100]), everyElement(false));
  });

  test('samples of the same peak count once', () {
    expect(peaks(ShakeDetector(), [0, 20, 40, 60]), everyElement(false));
  });

  test('one gesture triggers only one shake (cooldown)', () {
    final detector = ShakeDetector();
    expect(peaks(detector, [0, 200, 400]).last, isTrue);
    expect(peaks(detector, [600, 800, 1000]), everyElement(false));
    expect(peaks(detector, [2500, 2700, 2900]).last, isTrue);
  });
}
