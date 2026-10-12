import 'dart:typed_data';

/// Poids et biais d'une couche (convolution ou dense), dans l'ordre où
/// TFLite les range : convolution (sortie, kh, kw, entrée), dense
/// (sortie, entrée).
typedef LayerWeights = ({Float32List weights, Float32List bias});

/// Lit les poids des couches `CONV_2D` et `FULLY_CONNECTED` d'un modèle
/// `.tflite`, dans l'ordre des opérations — sans TFLite : le fichier est un
/// flatbuffer (schéma `tensorflow/lite/schema/schema.fbs`) dont seules
/// quelques tables servent ici. Les BatchNorm y sont déjà fusionnées dans
/// les convolutions par le convertisseur.
List<LayerWeights> readTfliteWeights(Uint8List bytes) {
  final fb = _FlatBuffer(bytes);
  final model = fb.root();
  final opcodes = fb.tables(model, _ModelField.operatorCodes);
  final buffers = fb.tables(model, _ModelField.buffers);
  final subgraph = fb.tables(model, _ModelField.subgraphs).first;
  final tensors = fb.tables(subgraph, _SubGraphField.tensors);

  Float32List tensorData(int index) {
    final tensor = tensors[index];
    if (fb.byte(tensor, _TensorField.type) != _float32) {
      throw const FormatException('Only float32 models are supported.');
    }
    final buffer = buffers[fb.uint(tensor, _TensorField.buffer)];
    final data = fb.bytes(buffer, _BufferField.data);
    if (data == null) {
      throw const FormatException('Tensor data stored outside the model.');
    }
    // Copie : les données d'un flatbuffer ne sont pas forcément alignées
    // sur 4 octets, ce qu'exige une vue Float32List.
    return Float32List.view(Uint8List.fromList(data).buffer);
  }

  return [
    for (final op in fb.tables(subgraph, _SubGraphField.operators))
      if (_weightedOps.contains(
        _builtinCode(fb, opcodes[fb.uint(op, _OperatorField.opcodeIndex)]),
      ))
        (
          weights: tensorData(fb.ints(op, _OperatorField.inputs)[1]),
          bias: tensorData(fb.ints(op, _OperatorField.inputs)[2]),
        ),
  ];
}

const _float32 = 0;
const _conv2d = 3;
const _fullyConnected = 9;
const _weightedOps = {_conv2d, _fullyConnected};

/// Code de l'opération : l'ancien champ sur un octet, ou le nouveau sur 32
/// bits pour les codes au-delà de 127 (convention du schéma : le plus grand).
int _builtinCode(_FlatBuffer fb, int opcode) {
  final deprecated = fb.byte(opcode, _OperatorCodeField.deprecatedBuiltinCode);
  final current = fb.int32(opcode, _OperatorCodeField.builtinCode);
  return current > deprecated ? current : deprecated;
}

// Numéros des champs utilisés, dans l'ordre du schéma.
abstract final class _ModelField {
  static const operatorCodes = 1;
  static const subgraphs = 2;
  static const buffers = 4;
}

abstract final class _OperatorCodeField {
  static const deprecatedBuiltinCode = 0;
  static const builtinCode = 3;
}

abstract final class _SubGraphField {
  static const tensors = 0;
  static const operators = 3;
}

abstract final class _TensorField {
  static const type = 1;
  static const buffer = 2;
}

abstract final class _OperatorField {
  static const opcodeIndex = 0;
  static const inputs = 1;
}

abstract final class _BufferField {
  static const data = 0;
}

/// Lecture minimale d'un flatbuffer : tables, scalaires et vecteurs. Une
/// table est repérée par sa position ; sa vtable donne la position de
/// chaque champ (0 : champ absent, valeur par défaut).
class _FlatBuffer {
  _FlatBuffer(this._bytes) : _data = ByteData.sublistView(_bytes);

  final Uint8List _bytes;
  final ByteData _data;

  int root() => _data.getUint32(0, Endian.little);

  /// Position du champ [field] de [table], ou 0 s'il est absent.
  int _field(int table, int field) {
    final vtable = table - _data.getInt32(table, Endian.little);
    final vtableSize = _data.getUint16(vtable, Endian.little);
    final slot = 4 + 2 * field;
    if (slot >= vtableSize) return 0;
    final offset = _data.getUint16(vtable + slot, Endian.little);
    return offset == 0 ? 0 : table + offset;
  }

  int byte(int table, int field) {
    final at = _field(table, field);
    return at == 0 ? 0 : _data.getInt8(at);
  }

  int uint(int table, int field) {
    final at = _field(table, field);
    return at == 0 ? 0 : _data.getUint32(at, Endian.little);
  }

  int int32(int table, int field) {
    final at = _field(table, field);
    return at == 0 ? 0 : _data.getInt32(at, Endian.little);
  }

  /// Début et longueur du vecteur [field], ou `null` s'il est absent.
  (int, int)? _vector(int table, int field) {
    final at = _field(table, field);
    if (at == 0) return null;
    final start = at + _data.getUint32(at, Endian.little);
    return (start + 4, _data.getUint32(start, Endian.little));
  }

  List<int> tables(int table, int field) {
    final vector = _vector(table, field);
    if (vector == null) return const [];
    final (start, length) = vector;
    return [
      for (var i = 0; i < length; i++)
        start + 4 * i + _data.getUint32(start + 4 * i, Endian.little),
    ];
  }

  List<int> ints(int table, int field) {
    final vector = _vector(table, field);
    if (vector == null) return const [];
    final (start, length) = vector;
    return [
      for (var i = 0; i < length; i++)
        _data.getInt32(start + 4 * i, Endian.little),
    ];
  }

  Uint8List? bytes(int table, int field) {
    final vector = _vector(table, field);
    if (vector == null) return null;
    final (start, length) = vector;
    return Uint8List.sublistView(_bytes, start, start + length);
  }
}
