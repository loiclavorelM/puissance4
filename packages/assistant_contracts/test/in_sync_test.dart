import 'dart:io';

import 'package:test/test.dart';

import '../tool/generate.dart';

void main() {
  test(
    'generated constants match contracts/ (run dart run tool/generate.dart)',
    () {
      expect(File(output).readAsStringSync(), generate(Directory('contracts')));
    },
  );

  test(
    'the package does not depend on Serverpod or Flutter (transposable)',
    () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, isNot(contains('serverpod')));
      expect(pubspec, isNot(contains('flutter')));
    },
  );
}
