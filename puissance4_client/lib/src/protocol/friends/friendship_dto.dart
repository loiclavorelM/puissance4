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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../friends/enum_friend_presence.dart' as _iyn06qfo;
import '../friends/enum_friendship_status.dart' as _ipfdbv44;
import '../friends/friend_user_dto.dart' as _ifdcjd4x;
import '../game/enum_type.dart' as _iu5mz6ho;

abstract class FriendshipDto
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  FriendshipDto._({
    required this.id,
    required this.other,
    required this.status,
    required this.incoming,
    required this.createdAt,
    this.respondedAt,
    this.presence,
    this.playing,
    this.lastSeenAt,
  });

  factory FriendshipDto({
    required _isc.UuidValue id,
    required _ifdcjd4x.FriendUserDto other,
    required _ipfdbv44.EnumFriendshipStatus status,
    required bool incoming,
    required DateTime createdAt,
    DateTime? respondedAt,
    _iyn06qfo.EnumFriendPresence? presence,
    _iu5mz6ho.EnumType? playing,
    DateTime? lastSeenAt,
  }) = _FriendshipDtoImpl;

  factory FriendshipDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return FriendshipDto(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      other: _ixdd0t97.Protocol().deserialize<_ifdcjd4x.FriendUserDto>(
        jsonSerialization['other'],
      ),
      status: _ipfdbv44.EnumFriendshipStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      incoming: _isc.BoolJsonExtension.fromJson(jsonSerialization['incoming']),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      respondedAt: jsonSerialization['respondedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['respondedAt'],
            ),
      presence: jsonSerialization['presence'] == null
          ? null
          : _iyn06qfo.EnumFriendPresence.fromJson(
              (jsonSerialization['presence'] as String),
            ),
      playing: jsonSerialization['playing'] == null
          ? null
          : _iu5mz6ho.EnumType.fromJson(
              (jsonSerialization['playing'] as String),
            ),
      lastSeenAt: jsonSerialization['lastSeenAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSeenAt'],
            ),
    );
  }

  _isc.UuidValue id;

  _ifdcjd4x.FriendUserDto other;

  _ipfdbv44.EnumFriendshipStatus status;

  bool incoming;

  DateTime createdAt;

  DateTime? respondedAt;

  _iyn06qfo.EnumFriendPresence? presence;

  _iu5mz6ho.EnumType? playing;

  DateTime? lastSeenAt;

  /// Returns a shallow copy of this [FriendshipDto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  FriendshipDto copyWith({
    _isc.UuidValue? id,
    _ifdcjd4x.FriendUserDto? other,
    _ipfdbv44.EnumFriendshipStatus? status,
    bool? incoming,
    DateTime? createdAt,
    DateTime? respondedAt,
    _iyn06qfo.EnumFriendPresence? presence,
    _iu5mz6ho.EnumType? playing,
    DateTime? lastSeenAt,
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
      if (presence != null) 'presence': presence?.toJson(),
      if (playing != null) 'playing': playing?.toJson(),
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt?.toJson(),
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
      if (presence != null) 'presence': presence?.toJson(),
      if (playing != null) 'playing': playing?.toJson(),
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FriendshipDtoImpl extends FriendshipDto {
  _FriendshipDtoImpl({
    required _isc.UuidValue id,
    required _ifdcjd4x.FriendUserDto other,
    required _ipfdbv44.EnumFriendshipStatus status,
    required bool incoming,
    required DateTime createdAt,
    DateTime? respondedAt,
    _iyn06qfo.EnumFriendPresence? presence,
    _iu5mz6ho.EnumType? playing,
    DateTime? lastSeenAt,
  }) : super._(
         id: id,
         other: other,
         status: status,
         incoming: incoming,
         createdAt: createdAt,
         respondedAt: respondedAt,
         presence: presence,
         playing: playing,
         lastSeenAt: lastSeenAt,
       );

  /// Returns a shallow copy of this [FriendshipDto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  FriendshipDto copyWith({
    _isc.UuidValue? id,
    _ifdcjd4x.FriendUserDto? other,
    _ipfdbv44.EnumFriendshipStatus? status,
    bool? incoming,
    DateTime? createdAt,
    Object? respondedAt = _Undefined,
    Object? presence = _Undefined,
    Object? playing = _Undefined,
    Object? lastSeenAt = _Undefined,
  }) {
    return FriendshipDto(
      id: id ?? this.id,
      other: other ?? this.other.copyWith(),
      status: status ?? this.status,
      incoming: incoming ?? this.incoming,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt is DateTime? ? respondedAt : this.respondedAt,
      presence: presence is _iyn06qfo.EnumFriendPresence?
          ? presence
          : this.presence,
      playing: playing is _iu5mz6ho.EnumType? ? playing : this.playing,
      lastSeenAt: lastSeenAt is DateTime? ? lastSeenAt : this.lastSeenAt,
    );
  }
}
