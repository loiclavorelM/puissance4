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

abstract class UserDashboard
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  UserDashboard._({
    this.id,
    required this.userId,
    required this.version,
    required this.definitionJson,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory UserDashboard({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required int version,
    required String definitionJson,
    DateTime? updatedAt,
  }) = _UserDashboardImpl;

  factory UserDashboard.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserDashboard(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      version: jsonSerialization['version'] as int,
      definitionJson: jsonSerialization['definitionJson'] as String,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue userId;

  int version;

  String definitionJson;

  DateTime updatedAt;

  /// Returns a shallow copy of this [UserDashboard]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UserDashboard copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? userId,
    int? version,
    String? definitionJson,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserDashboard',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'version': version,
      'definitionJson': definitionJson,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserDashboard',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'version': version,
      'definitionJson': definitionJson,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserDashboardImpl extends UserDashboard {
  _UserDashboardImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required int version,
    required String definitionJson,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         version: version,
         definitionJson: definitionJson,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [UserDashboard]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UserDashboard copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? userId,
    int? version,
    String? definitionJson,
    DateTime? updatedAt,
  }) {
    return UserDashboard(
      id: id is _isc.UuidValue? ? id : this.id,
      userId: userId ?? this.userId,
      version: version ?? this.version,
      definitionJson: definitionJson ?? this.definitionJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
