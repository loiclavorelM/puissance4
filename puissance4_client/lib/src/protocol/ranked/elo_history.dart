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

abstract class EloHistory
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  EloHistory._({
    this.id,
    required this.userId,
    required this.partieId,
    required this.eloVariation,
    required this.newElo,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory EloHistory({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required _isc.UuidValue partieId,
    required int eloVariation,
    required int newElo,
    DateTime? createdAt,
  }) = _EloHistoryImpl;

  factory EloHistory.fromJson(Map<String, dynamic> jsonSerialization) {
    return EloHistory(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      partieId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['partieId'],
      ),
      eloVariation: jsonSerialization['eloVariation'] as int,
      newElo: jsonSerialization['newElo'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue userId;

  _isc.UuidValue partieId;

  int eloVariation;

  int newElo;

  DateTime createdAt;

  /// Returns a shallow copy of this [EloHistory]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  EloHistory copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? userId,
    _isc.UuidValue? partieId,
    int? eloVariation,
    int? newElo,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EloHistory',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'partieId': partieId.toJson(),
      'eloVariation': eloVariation,
      'newElo': newElo,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EloHistory',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'partieId': partieId.toJson(),
      'eloVariation': eloVariation,
      'newElo': newElo,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EloHistoryImpl extends EloHistory {
  _EloHistoryImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required _isc.UuidValue partieId,
    required int eloVariation,
    required int newElo,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         partieId: partieId,
         eloVariation: eloVariation,
         newElo: newElo,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [EloHistory]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  EloHistory copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? userId,
    _isc.UuidValue? partieId,
    int? eloVariation,
    int? newElo,
    DateTime? createdAt,
  }) {
    return EloHistory(
      id: id is _isc.UuidValue? ? id : this.id,
      userId: userId ?? this.userId,
      partieId: partieId ?? this.partieId,
      eloVariation: eloVariation ?? this.eloVariation,
      newElo: newElo ?? this.newElo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
