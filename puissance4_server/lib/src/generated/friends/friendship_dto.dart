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
import 'package:puissance4_server/src/generated/protocol.dart' as _irho11n9;
import 'package:serverpod/serverpod.dart' as _is;
import '../friends/enum_friendship_status.dart' as _ipfdbv44;
import '../friends/friend_user_dto.dart' as _ifdcjd4x;

abstract class FriendshipDto
    implements _is.SerializableModel, _is.ProtocolSerialization {
  FriendshipDto._({
    required this.id,
    required this.other,
    required this.status,
    required this.incoming,
    required this.createdAt,
    this.respondedAt,
  });

  factory FriendshipDto({
    required _is.UuidValue id,
    required _ifdcjd4x.FriendUserDto other,
    required _ipfdbv44.EnumFriendshipStatus status,
    required bool incoming,
    required DateTime createdAt,
    DateTime? respondedAt,
  }) = _FriendshipDtoImpl;

  factory FriendshipDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return FriendshipDto(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      other: _irho11n9.Protocol().deserialize<_ifdcjd4x.FriendUserDto>(
        jsonSerialization['other'],
      ),
      status: _ipfdbv44.EnumFriendshipStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      incoming: _is.BoolJsonExtension.fromJson(jsonSerialization['incoming']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      respondedAt: jsonSerialization['respondedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['respondedAt'],
            ),
    );
  }

  _is.UuidValue id;

  _ifdcjd4x.FriendUserDto other;

  _ipfdbv44.EnumFriendshipStatus status;

  bool incoming;

  DateTime createdAt;

  DateTime? respondedAt;

  /// Returns a shallow copy of this [FriendshipDto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FriendshipDto copyWith({
    _is.UuidValue? id,
    _ifdcjd4x.FriendUserDto? other,
    _ipfdbv44.EnumFriendshipStatus? status,
    bool? incoming,
    DateTime? createdAt,
    DateTime? respondedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FriendshipDto',
      'id': id.toJson(),
      'other': other.toJson(),
      'status': status.toJson(),
      'incoming': incoming,
      'createdAt': createdAt.toJson(),
      if (respondedAt != null) 'respondedAt': respondedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FriendshipDto',
      'id': id.toJson(),
      'other': other.toJsonForProtocol(),
      'status': status.toJson(),
      'incoming': incoming,
      'createdAt': createdAt.toJson(),
      if (respondedAt != null) 'respondedAt': respondedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FriendshipDtoImpl extends FriendshipDto {
  _FriendshipDtoImpl({
    required _is.UuidValue id,
    required _ifdcjd4x.FriendUserDto other,
    required _ipfdbv44.EnumFriendshipStatus status,
    required bool incoming,
    required DateTime createdAt,
    DateTime? respondedAt,
  }) : super._(
         id: id,
         other: other,
         status: status,
         incoming: incoming,
         createdAt: createdAt,
         respondedAt: respondedAt,
       );

  /// Returns a shallow copy of this [FriendshipDto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FriendshipDto copyWith({
    _is.UuidValue? id,
    _ifdcjd4x.FriendUserDto? other,
    _ipfdbv44.EnumFriendshipStatus? status,
    bool? incoming,
    DateTime? createdAt,
    Object? respondedAt = _Undefined,
  }) {
    return FriendshipDto(
      id: id ?? this.id,
      other: other ?? this.other.copyWith(),
      status: status ?? this.status,
      incoming: incoming ?? this.incoming,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt is DateTime? ? respondedAt : this.respondedAt,
    );
  }
}
