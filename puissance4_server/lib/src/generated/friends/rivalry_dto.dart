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
import '../friends/friend_user_dto.dart' as _ifdcjd4x;

abstract class RivalryDto
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RivalryDto._({
    required this.friend,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.streak,
    this.lastPlayedAt,
    required this.partieIds,
  });

  factory RivalryDto({
    required _ifdcjd4x.FriendUserDto friend,
    required int wins,
    required int losses,
    required int draws,
    required int streak,
    DateTime? lastPlayedAt,
    required List<_is.UuidValue> partieIds,
  }) = _RivalryDtoImpl;

  factory RivalryDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return RivalryDto(
      friend: _irho11n9.Protocol().deserialize<_ifdcjd4x.FriendUserDto>(
        jsonSerialization['friend'],
      ),
      wins: jsonSerialization['wins'] as int,
      losses: jsonSerialization['losses'] as int,
      draws: jsonSerialization['draws'] as int,
      streak: jsonSerialization['streak'] as int,
      lastPlayedAt: jsonSerialization['lastPlayedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastPlayedAt'],
            ),
      partieIds: _irho11n9.Protocol().deserialize<List<_is.UuidValue>>(
        jsonSerialization['partieIds'],
      ),
    );
  }

  _ifdcjd4x.FriendUserDto friend;

  int wins;

  int losses;

  int draws;

  int streak;

  DateTime? lastPlayedAt;

  List<_is.UuidValue> partieIds;

  /// Returns a shallow copy of this [RivalryDto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RivalryDto copyWith({
    _ifdcjd4x.FriendUserDto? friend,
    int? wins,
    int? losses,
    int? draws,
    int? streak,
    DateTime? lastPlayedAt,
    List<_is.UuidValue>? partieIds,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RivalryDto',
      'friend': friend.toJson(),
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'streak': streak,
      if (lastPlayedAt != null) 'lastPlayedAt': lastPlayedAt?.toJson(),
      'partieIds': partieIds.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RivalryDto',
      'friend': friend.toJsonForProtocol(),
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'streak': streak,
      if (lastPlayedAt != null) 'lastPlayedAt': lastPlayedAt?.toJson(),
      'partieIds': partieIds.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RivalryDtoImpl extends RivalryDto {
  _RivalryDtoImpl({
    required _ifdcjd4x.FriendUserDto friend,
    required int wins,
    required int losses,
    required int draws,
    required int streak,
    DateTime? lastPlayedAt,
    required List<_is.UuidValue> partieIds,
  }) : super._(
         friend: friend,
         wins: wins,
         losses: losses,
         draws: draws,
         streak: streak,
         lastPlayedAt: lastPlayedAt,
         partieIds: partieIds,
       );

  /// Returns a shallow copy of this [RivalryDto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RivalryDto copyWith({
    _ifdcjd4x.FriendUserDto? friend,
    int? wins,
    int? losses,
    int? draws,
    int? streak,
    Object? lastPlayedAt = _Undefined,
    List<_is.UuidValue>? partieIds,
  }) {
    return RivalryDto(
      friend: friend ?? this.friend.copyWith(),
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      streak: streak ?? this.streak,
      lastPlayedAt: lastPlayedAt is DateTime?
          ? lastPlayedAt
          : this.lastPlayedAt,
      partieIds: partieIds ?? this.partieIds.map((e0) => e0).toList(),
    );
  }
}
