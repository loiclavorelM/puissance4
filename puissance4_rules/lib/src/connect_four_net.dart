import 'dart:math';
import 'dart:typed_data';

import 'connect4_rules.dart';
import 'network_bot.dart';
import 'tflite_weights.dart';

/// Le réseau des bots RL (notebook, section 2) recalculé en Dart pur, avec
/// les poids lus dans le `.tflite` exporté par le notebook
/// (`readTfliteWeights`) : il tourne partout — serveur (Classé), web, bureau
/// — sans bibliothèque native. Sur Android et iOS, l'app passe plutôt par
/// TFLite, bien plus rapide (`NetworkBotBrain`).
///
/// Architecture : 3 plans d'entrée, un tronc de [_blocks] blocs résiduels de
/// convolutions 3×3 à [_channels] canaux (BatchNorm déjà fusionnées dans les
/// convolutions), une tête politique (softmax sur les colonnes jouables) et
/// une tête valeur (tanh). Activations en `(rangée, colonne, canal)`, comme
/// TFLite.
class ConnectFourNet {
  ConnectFourNet._(this._layers);

  /// Charge les poids d'un modèle `.tflite` exporté par le notebook.
  factory ConnectFourNet.fromTflite(Uint8List bytes) {
    final layers = readTfliteWeights(bytes);
    if (layers.length != _shapes.length) {
      throw FormatException(
        'Expected ${_shapes.length} layers, found ${layers.length}.',
      );
    }
    return ConnectFourNet._([
      for (var i = 0; i < layers.length; i++)
        if (layers[i].weights.length != _shapes[i].$1 ||
            layers[i].bias.length != _shapes[i].$2)
          throw FormatException('Unexpected shape for layer $i.')
        else
          (
            weights: layers[i].weights,
            bias: layers[i].bias,
            weights4: layers[i].weights.length % 4 == 0
                ? Float32x4List.view(layers[i].weights.buffer)
                : null,
          ),
    ]);
  }

  static const _channels = 64;
  static const _blocks = 6;
  static const _inputPlanes = 3;
  static const _cells = Connect4Rules.rows * Connect4Rules.columns;

  /// Nombre de (poids, biais) de chaque couche, dans l'ordre du modèle.
  static final List<(int, int)> _shapes = [
    (_channels * 9 * _inputPlanes, _channels), // stem
    for (var i = 0; i < 2 * _blocks; i++)
      (_channels * 9 * _channels, _channels),
    (2 * _channels, 2), // p_conv (1×1)
    (Connect4Rules.columns * 2 * _cells, Connect4Rules.columns), // p_fc
    (_channels, 1), // v_conv (1×1)
    (64 * _cells, 64), // v_fc1
    (64, 1), // value
  ];

  final List<_Layer> _layers;

  // Tampons réutilisés d'une évaluation à l'autre (pas d'allocation dans la
  // boucle du MCTS) : une instance n'est donc pas réentrante.
  final _input = Float32List(_cells * _inputPlanes);
  final _a = Float32List(_cells * _channels);
  final _b = Float32List(_cells * _channels);
  final _c = Float32List(_cells * _channels);

  /// Politique et valeur de [board] (codé par `encodeBoard`) pour le joueur
  /// au trait.
  NetworkOutput evaluate(Float32List board) {
    for (var p = 0; p < _cells; p++) {
      _input[p * 3] = board[p] == 1 ? 1 : 0;
      _input[p * 3 + 1] = board[p] == -1 ? 1 : 0;
      _input[p * 3 + 2] = 1;
    }
    _conv3x3(_input, _inputPlanes, _layers[0], _a, relu: true);
    var x = _a;
    var spare = _c;
    for (var i = 0; i < _blocks; i++) {
      _conv3x3(x, _channels, _layers[1 + 2 * i], _b, relu: true);
      _conv3x3(_b, _channels, _layers[2 + 2 * i], spare, relu: false);
      for (var j = 0; j < spare.length; j++) {
        final sum = spare[j] + x[j];
        spare[j] = sum > 0 ? sum : 0;
      }
      final previous = x;
      x = spare;
      spare = previous;
    }
    final head = 1 + 2 * _blocks;
    final policyPlanes = _conv1x1(x, _layers[head], 2);
    final logits = _dense(policyPlanes, _layers[head + 1], relu: false);
    final valuePlane = _conv1x1(x, _layers[head + 2], 1);
    final hidden = _dense(valuePlane, _layers[head + 3], relu: true);
    final value = _dense(hidden, _layers[head + 4], relu: false)[0];
    return (policy: _maskedSoftmax(logits, board), value: _tanh(value));
  }

  /// Convolution 3×3, remplissage par des zéros (`padding='same'`) ; poids
  /// en (sortie, kh, kw, entrée). Sur 64 canaux d'entrée, produits scalaires
  /// par paquets de 4 (`Float32x4`, SIMD sur la VM) : le MCTS appelle le
  /// réseau des centaines de fois par coup.
  static void _conv3x3(
    Float32List x,
    int inChannels,
    _Layer layer,
    Float32List out, {
    required bool relu,
  }) {
    final w = layer.weights;
    final b = layer.bias;
    const rows = Connect4Rules.rows;
    const cols = Connect4Rules.columns;
    // Déroulée par paquets de 4 × 4 canaux : 64 canaux (le tronc), pas les
    // 3 plans d'entrée.
    final vectorized = inChannels % 16 == 0;
    final lanes = inChannels ~/ 4;
    final x4 = vectorized
        ? Float32x4List.view(x.buffer, x.offsetInBytes)
        : null;
    final w4 = vectorized ? layer.weights4! : null;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final outBase = (r * cols + c) * _channels;
        for (var o = 0; o < _channels; o++) {
          var acc = b[o];
          var acc4 = Float32x4.zero();
          for (var kr = 0; kr < 3; kr++) {
            final rr = r + kr - 1;
            if (rr < 0 || rr >= rows) continue;
            for (var kc = 0; kc < 3; kc++) {
              final cc = c + kc - 1;
              if (cc < 0 || cc >= cols) continue;
              final cell = rr * cols + cc;
              final kernel = (o * 3 + kr) * 3 + kc;
              if (vectorized) {
                var xi = cell * lanes;
                var wi = kernel * lanes;
                final end = wi + lanes;
                // Déroulée par 4 : moins de tours de boucle, plus de calculs
                // indépendants en vol.
                while (wi < end) {
                  acc4 +=
                      w4![wi] * x4![xi] +
                      w4[wi + 1] * x4[xi + 1] +
                      w4[wi + 2] * x4[xi + 2] +
                      w4[wi + 3] * x4[xi + 3];
                  wi += 4;
                  xi += 4;
                }
              } else {
                final xBase = cell * inChannels;
                final wBase = kernel * inChannels;
                for (var i = 0; i < inChannels; i++) {
                  acc += w[wBase + i] * x[xBase + i];
                }
              }
            }
          }
          acc += acc4.x + acc4.y + acc4.z + acc4.w;
          out[outBase + o] = relu && acc < 0 ? 0 : acc;
        }
      }
    }
  }

  /// Convolution 1×1 suivie d'un ReLU, aplatie en (rangée, colonne, canal).
  static Float32List _conv1x1(Float32List x, _Layer layer, int outChannels) {
    final out = Float32List(_cells * outChannels);
    for (var p = 0; p < _cells; p++) {
      for (var o = 0; o < outChannels; o++) {
        var acc = layer.bias[o];
        for (var i = 0; i < _channels; i++) {
          acc += layer.weights[o * _channels + i] * x[p * _channels + i];
        }
        out[p * outChannels + o] = acc > 0 ? acc : 0;
      }
    }
    return out;
  }

  /// Couche dense ; poids en (sortie, entrée).
  static Float32List _dense(Float32List x, _Layer layer, {required bool relu}) {
    final outCount = layer.bias.length;
    final out = Float32List(outCount);
    for (var o = 0; o < outCount; o++) {
      var acc = layer.bias[o];
      final base = o * x.length;
      for (var i = 0; i < x.length; i++) {
        acc += layer.weights[base + i] * x[i];
      }
      out[o] = relu && acc < 0 ? 0 : acc;
    }
    return out;
  }

  /// Softmax limitée aux colonnes jouables (case du haut vide), comme la
  /// couche `MaskedSoftmax` du modèle exporté.
  static List<double> _maskedSoftmax(Float32List logits, Float32List board) {
    var maxLogit = double.negativeInfinity;
    for (var c = 0; c < Connect4Rules.columns; c++) {
      if (board[c] == 0 && logits[c] > maxLogit) maxLogit = logits[c];
    }
    final policy = List<double>.filled(Connect4Rules.columns, 0);
    if (maxLogit == double.negativeInfinity) return policy;
    var total = 0.0;
    for (var c = 0; c < Connect4Rules.columns; c++) {
      if (board[c] != 0) continue;
      policy[c] = exp(logits[c] - maxLogit);
      total += policy[c];
    }
    for (var c = 0; c < Connect4Rules.columns; c++) {
      policy[c] /= total;
    }
    return policy;
  }

  static double _tanh(double x) {
    final e = exp(-2 * x.abs());
    final t = (1 - e) / (1 + e);
    return x < 0 ? -t : t;
  }
}

typedef _Layer = ({
  Float32List weights,
  Float32List bias,
  // Mêmes poids vus par paquets de 4, si leur nombre s'y prête.
  Float32x4List? weights4,
});
