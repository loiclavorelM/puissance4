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
import '../friends/enum_friend_relation.dart' as _i2d9j788;
import '../friends/friend_user_dto.dart' as _ifdcjd4x;

abstract class PlayerSearchResultDto
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PlayerSearchResultDto._({
    required this.player,
    required this.relation,
    this.friendshipId,
  });

  factory PlayerSearchResultDto({
    required _ifdcjd4x.FriendUserDto player,
    required _i2d9j788.EnumFriendRelation relation,
    _isc.UuidValue? friendshipId,
  }) = _PlayerSearchResultDtoImpl;

  factory PlayerSearchResultDto.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return PlayerSearchResultDto(
      player: _ixdd0t97.Protocol().deserialize<_ifdcjd4x.FriendUserDto>(
        jsonSerialization['player'],
      ),
      relation: _i2d9j788.EnumFriendRelation.fromJson(
        (jsonSerialization['relation'] as String),
      ),
      friendshipId: jsonSerialization['friendshipId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['friendshipId'],
            ),
    );
  }

  _ifdcjd4x.FriendUserDto player;

  _i2d9j788.EnumFriendRelation relation;

  _isc.UuidValue? friendshipId;

  /// Returns a shallow copy of this [PlayerSearchResultDto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PlayerSearchResultDto copyWith({
    _ifdcjd4x.FriendUserDto? player,
    _i2d9j788.EnumFriendRelation? relation,
    _isc.UuidValue? friendshipId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlayerSearchResultDto',
      'player': player.toJson(),
      'relation': relation.toJson(),
      if (friendshipId != null) 'friendshipId': friendshipId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlayerSearchResultDto',
      'player': player.toJsonForProtocol(),
      'relation': relation.toJson(),
      if (friendshipId != null) 'friendshipId': friendshipId?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlayerSearchResultDtoImpl extends PlayerSearchResultDto {
  _PlayerSearchResultDtoImpl({
    required _ifdcjd4x.FriendUserDto player,
    required _i2d9j788.EnumFriendRelation relation,
    _isc.UuidValue? friendshipId,
  }) : super._(
         player: player,
         relation: relation,
         friendshipId: friendshipId,
       );

  /// Returns a shallow copy of this [PlayerSearchResultDto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PlayerSearchResultDto copyWith({
    _ifdcjd4x.FriendUserDto? player,
    _i2d9j788.EnumFriendRelation? relation,
    Object? friendshipId = _Undefined,
  }) {
    return PlayerSearchResultDto(
      player: player ?? this.player.copyWith(),
      relation: relation ?? this.relation,
      friendshipId: friendshipId is _isc.UuidValue?
          ? friendshipId
          : this.friendshipId,
    );
  }
}
