import 'dart:isolate';
import 'dart:typed_data';

import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Coup de [level] après [moves], calculé hors du thread UI : l'Expert lance
/// 800 inférences par coup. Avec TFLite (Android, iOS) ; sans sa
/// bibliothèque native (bureau), avec le même réseau recalculé en Dart.
/// L'interpréteur est créé dans l'isolate de calcul à partir des octets du
/// modèle, puis refermé.
Future<int> runNetworkBot(BotLevel level, Uint8List model, List<int> moves) =>
    Isolate.run(() {
      final Interpreter interpreter;
      try {
        interpreter = Interpreter.fromBuffer(model);
      } on Object {
        return NetworkBot(
          level,
          ConnectFourNet.fromTflite(model).evaluate,
        ).chooseColumn(moves);
      }
      try {
        return NetworkBot(level, _evaluator(interpreter)).chooseColumn(moves);
      } finally {
        interpreter.close();
      }
    });

/// Entrée `board` (1, 6, 7) ; sorties `policy` (1, 7) et `value` (1, 1),
/// reconnues à leur forme (l'ordre des sorties d'un export Keras n'est pas
/// garanti).
NetworkEvaluator _evaluator(Interpreter interpreter) {
  final outputs = interpreter.getOutputTensors();
  final policyIndex = outputs.indexWhere((t) => t.shape.last == 7);
  final valueIndex = outputs.indexWhere((t) => t.shape.last == 1);
  if (policyIndex < 0 || valueIndex < 0) {
    throw StateError(
      'Unexpected model outputs: ${outputs.map((t) => t.shape)}',
    );
  }
  return (board) {
    final input = [
      for (var r = 0; r < Connect4Rules.rows; r++)
        board.sublist(
          r * Connect4Rules.columns,
          (r + 1) * Connect4Rules.columns,
        ),
    ];
    final policy = [List<double>.filled(Connect4Rules.columns, 0)];
    final value = [List<double>.filled(1, 0)];
    interpreter.runForMultipleInputs(
      [
        [input],
      ],
      {policyIndex: policy, valueIndex: value},
    );
    return (policy: policy[0], value: value[0][0]);
  };
}
