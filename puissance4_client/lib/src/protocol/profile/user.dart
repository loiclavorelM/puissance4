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
import 'package:puissance4_client/src/protocol/protocol.dart' as _ixdd0t97;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class User
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  User._({
    this.id,
    this.authUserId,
    this.authUser,
    required this.username,
    this.thumbnailPath,
    int? elo,
    DateTime? createdAt,
    this.updatedAt,
  }) : elo = elo ?? 1000,
       createdAt = createdAt ?? DateTime.now();

  factory User({
    _isc.UuidValue? id,
    _isc.UuidValue? authUserId,
    _iacc.AuthUser? authUser,
    required String username,
    String? thumbnailPath,
    int? elo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserImpl;

  factory User.fromJson(Map<String, dynamic> jsonSerialization) {
    return User(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authUserId: jsonSerialization['authUserId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['authUserId'],
            ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _ixdd0t97.Protocol().deserialize<_iacc.AuthUser>(
              jsonSerialization['authUser'],
            ),
      username: jsonSerialization['username'] as String,
      thumbnailPath: jsonSerialization['thumbnailPath'] as String?,
      elo: jsonSerialization['elo'] as int?,
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

  _isc.UuidValue? authUserId;

  _iacc.AuthUser? authUser;

  String username;

  String? thumbnailPath;

  int elo;

  DateTime createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  User copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? authUserId,
    _iacc.AuthUser? authUser,
    String? username,
    String? thumbnailPath,
    int? elo,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'User',
      if (id != null) 'id': id?.toJson(),
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'username': username,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
      'elo': elo,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'User',
      if (id != null) 'id': id?.toJson(),
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'username': username,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
      'elo': elo,
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

class _UserImpl extends User {
  _UserImpl({
    _isc.UuidValue? id,
    _isc.UuidValue? authUserId,
    _iacc.AuthUser? authUser,
    required String username,
    String? thumbnailPath,
    int? elo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         username: username,
         thumbnailPath: thumbnailPath,
         elo: elo,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  User copyWith({
    Object? id = _Undefined,
    Object? authUserId = _Undefined,
    Object? authUser = _Undefined,
    String? username,
    Object? thumbnailPath = _Undefined,
    int? elo,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return User(
      id: id is _isc.UuidValue? ? id : this.id,
      authUserId: authUserId is _isc.UuidValue? ? authUserId : this.authUserId,
      authUser: authUser is _iacc.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      username: username ?? this.username,
      thumbnailPath: thumbnailPath is String?
          ? thumbnailPath
          : this.thumbnailPath,
      elo: elo ?? this.elo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
