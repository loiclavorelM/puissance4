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
import '../friends/enum_friendship_status.dart' as _ipfdbv44;

abstract class Friendship
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Friendship._({
    this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.pairKey,
    required this.status,
    DateTime? createdAt,
    this.respondedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Friendship({
    _isc.UuidValue? id,
    required _isc.UuidValue requesterId,
    required _isc.UuidValue addresseeId,
    required String pairKey,
    required _ipfdbv44.EnumFriendshipStatus status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) = _FriendshipImpl;

  factory Friendship.fromJson(Map<String, dynamic> jsonSerialization) {
    return Friendship(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      requesterId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['requesterId'],
      ),
      addresseeId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['addresseeId'],
      ),
      pairKey: jsonSerialization['pairKey'] as String,
      status: _ipfdbv44.EnumFriendshipStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      respondedAt: jsonSerialization['respondedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['respondedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue requesterId;

  _isc.UuidValue addresseeId;

  String pairKey;

  _ipfdbv44.EnumFriendshipStatus status;

  DateTime createdAt;

  DateTime? respondedAt;

  /// Returns a shallow copy of this [Friendship]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Friendship copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? requesterId,
    _isc.UuidValue? addresseeId,
    String? pairKey,
    _ipfdbv44.EnumFriendshipStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Friendship',
      if (id != null) 'id': id?.toJson(),
      'requesterId': requesterId.toJson(),
      'addresseeId': addresseeId.toJson(),
      'pairKey': pairKey,
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
      if (respondedAt != null) 'respondedAt': respondedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Friendship',
      if (id != null) 'id': id?.toJson(),
      'requesterId': requesterId.toJson(),
      'addresseeId': addresseeId.toJson(),
      'pairKey': pairKey,
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
      if (respondedAt != null) 'respondedAt': respondedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FriendshipImpl extends Friendship {
  _FriendshipImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue requesterId,
    required _isc.UuidValue addresseeId,
    required String pairKey,
    required _ipfdbv44.EnumFriendshipStatus status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) : super._(
         id: id,
         requesterId: requesterId,
         addresseeId: addresseeId,
         pairKey: pairKey,
         status: status,
         createdAt: createdAt,
         respondedAt: respondedAt,
       );

  /// Returns a shallow copy of this [Friendship]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Friendship copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? requesterId,
    _isc.UuidValue? addresseeId,
    String? pairKey,
    _ipfdbv44.EnumFriendshipStatus? status,
    DateTime? createdAt,
    Object? respondedAt = _Undefined,
  }) {
    return Friendship(
      id: id is _isc.UuidValue? ? id : this.id,
      requesterId: requesterId ?? this.requesterId,
      addresseeId: addresseeId ?? this.addresseeId,
      pairKey: pairKey ?? this.pairKey,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt is DateTime? ? respondedAt : this.respondedAt,
    );
  }
}
