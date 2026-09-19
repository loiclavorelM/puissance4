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

abstract class Bot
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Bot._({
    this.id,
    required this.botName,
    required this.elo,
    required this.pathModel,
    required this.description,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Bot({
    _isc.UuidValue? id,
    required String botName,
    required int elo,
    required String pathModel,
    required String description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BotImpl;

  factory Bot.fromJson(Map<String, dynamic> jsonSerialization) {
    return Bot(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      botName: jsonSerialization['botName'] as String,
      elo: jsonSerialization['elo'] as int,
      pathModel: jsonSerialization['pathModel'] as String,
      description: jsonSerialization['description'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  String botName;

  int elo;

  String pathModel;

  String description;

  DateTime createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [Bot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Bot copyWith({
    _isc.UuidValue? id,
    String? botName,
    int? elo,
    String? pathModel,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Bot',
      if (id != null) 'id': id?.toJson(),
      'botName': botName,
      'elo': elo,
      'pathModel': pathModel,
      'description': description,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Bot',
      if (id != null) 'id': id?.toJson(),
      'botName': botName,
      'elo': elo,
      'pathModel': pathModel,
      'description': description,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BotImpl extends Bot {
  _BotImpl({
    _isc.UuidValue? id,
    required String botName,
    required int elo,
    required String pathModel,
    required String description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         botName: botName,
         elo: elo,
         pathModel: pathModel,
         description: description,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Bot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Bot copyWith({
    Object? id = _Undefined,
    String? botName,
    int? elo,
    String? pathModel,
    String? description,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return Bot(
      id: id is _isc.UuidValue? ? id : this.id,
      botName: botName ?? this.botName,
      elo: elo ?? this.elo,
      pathModel: pathModel ?? this.pathModel,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
