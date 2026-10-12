import 'dart:convert';
import 'dart:io';

import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:test/test.dart';

/// Modèles exportés par le notebook, copiés dans les assets du serveur.
const _models = '../puissance4_server/assets/models';

void main() {
  // Sorties de TFLite (LiteRT, Python) sur les mêmes positions, encodées
  // comme `encodeBoard` : le réseau en Dart doit les retrouver.
  final reference =
      jsonDecode(
            File('test/fixtures/tflite_reference.json').readAsStringSync(),
          )
          as Map<String, dynamic>;

  group('Given a ConnectFourNet loaded from a .tflite', () {
    for (final MapEntry(key: model, value: positions) in reference.entries) {
      test('when it evaluates positions then $model matches TFLite', () {
        final net = ConnectFourNet.fromTflite(
          File('$_models/$model').readAsBytesSync(),
        );
        for (final position in positions as List) {
          final moves = (position['moves'] as List).cast<int>();
          final output = net.evaluate(encodeBoard(moves));
          final policy = (position['policy'] as List).cast<num>();
          for (var c = 0; c < Connect4Rules.columns; c++) {
            expect(
              output.policy[c],
              closeTo(policy[c], 1e-4),
              reason: '$moves',
            );
          }
          expect(
            output.value,
            closeTo(position['value'] as num, 1e-4),
            reason: '$moves',
          );
        }
      });
    }

    test('when every level is loaded then its model is a valid network', () {
      for (final level in BotLevel.values) {
        final net = ConnectFourNet.fromTflite(
          File('$_models/${level.model}').readAsBytesSync(),
        );
        final policy = net.evaluate(encodeBoard([])).policy;
        expect(policy.fold<double>(0, (a, b) => a + b), closeTo(1, 1e-5));
      }
    });

    test('when the file is not a model then it throws', () {
      expect(
        () => ConnectFourNet.fromTflite(utf8.encode('not a model, really')),
        throwsA(anything),
      );
    });
  });
}
