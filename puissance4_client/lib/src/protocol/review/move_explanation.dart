/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class MoveExplanation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  MoveExplanation._({
    this.id,
    required this.positionKey,
    required this.language,
    required this.explanation,
    required this.model,
    required this.requestedBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MoveExplanation({
    _isc.UuidValue? id,
    required String positionKey,
    required String language,
    required String explanation,
    required String model,
    required _isc.UuidValue requestedBy,
    DateTime? createdAt,
  }) = _MoveExplanationImpl;

  factory MoveExplanation.fromJson(Map<String, dynamic> jsonSerialization) {
    return MoveExplanation(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      positionKey: jsonSerialization['positionKey'] as String,
      language: jsonSerialization['language'] as String,
      explanation: jsonSerialization['explanation'] as String,
      model: jsonSerialization['model'] as String,
      requestedBy: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['requestedBy'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  String positionKey;

  String language;

  String explanation;

  String model;

  _isc.UuidValue requestedBy;

  DateTime createdAt;

  /// Returns a shallow copy of this [MoveExplanation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MoveExplanation copyWith({
    _isc.UuidValue? id,
    String? positionKey,
    String? language,
    String? explanation,
    String? model,
    _isc.UuidValue? requestedBy,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MoveExplanation',
      if (id != null) 'id': id?.toJson(),
      'positionKey': positionKey,
      'language': language,
      'explanation': explanation,
      'model': model,
      'requestedBy': requestedBy.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MoveExplanation',
      if (id != null) 'id': id?.toJson(),
      'positionKey': positionKey,
      'language': language,
      'explanation': explanation,
      'model': model,
      'requestedBy': requestedBy.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MoveExplanationImpl extends MoveExplanation {
  _MoveExplanationImpl({
    _isc.UuidValue? id,
    required String positionKey,
    required String language,
    required String explanation,
    required String model,
    required _isc.UuidValue requestedBy,
    DateTime? createdAt,
  }) : super._(
         id: id,
         positionKey: positionKey,
         language: language,
         explanation: explanation,
         model: model,
         requestedBy: requestedBy,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MoveExplanation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  MoveExplanation copyWith({
    Object? id = _Undefined,
    String? positionKey,
    String? language,
    String? explanation,
    String? model,
    _isc.UuidValue? requestedBy,
    DateTime? createdAt,
  }) {
    return MoveExplanation(
      id: id is _isc.UuidValue? ? id : this.id,
      positionKey: positionKey ?? this.positionKey,
      language: language ?? this.language,
      explanation: explanation ?? this.explanation,
      model: model ?? this.model,
      requestedBy: requestedBy ?? this.requestedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
