import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the package depends on neither Serverpod nor a state manager', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final forbidden in ['serverpod', 'riverpod', 'provider:', 'bloc']) {
      expect(pubspec, isNot(contains(forbidden)), reason: forbidden);
    }
  });
}
