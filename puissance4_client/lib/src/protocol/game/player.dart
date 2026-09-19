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

abstract class Player
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Player._({
    this.id,
    this.botId,
    this.userId,
  });

  factory Player({
    _isc.UuidValue? id,
    _isc.UuidValue? botId,
    _isc.UuidValue? userId,
  }) = _PlayerImpl;

  factory Player.fromJson(Map<String, dynamic> jsonSerialization) {
    return Player(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      botId: jsonSerialization['botId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['botId']),
      userId: jsonSerialization['userId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue? botId;

  _isc.UuidValue? userId;

  /// Returns a shallow copy of this [Player]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Player copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? botId,
    _isc.UuidValue? userId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Player',
      if (id != null) 'id': id?.toJson(),
      if (botId != null) 'botId': botId?.toJson(),
      if (userId != null) 'userId': userId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Player',
      if (id != null) 'id': id?.toJson(),
      if (botId != null) 'botId': botId?.toJson(),
      if (userId != null) 'userId': userId?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlayerImpl extends Player {
  _PlayerImpl({
    _isc.UuidValue? id,
    _isc.UuidValue? botId,
    _isc.UuidValue? userId,
  }) : super._(
         id: id,
         botId: botId,
         userId: userId,
       );

  /// Returns a shallow copy of this [Player]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Player copyWith({
    Object? id = _Undefined,
    Object? botId = _Undefined,
    Object? userId = _Undefined,
  }) {
    return Player(
      id: id is _isc.UuidValue? ? id : this.id,
      botId: botId is _isc.UuidValue? ? botId : this.botId,
      userId: userId is _isc.UuidValue? ? userId : this.userId,
    );
  }
}
