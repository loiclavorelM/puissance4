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
import '../friends/friend_user_dto.dart' as _ifdcjd4x;
import '../game/enum_match_result.dart' as _ib5rq0bj;
import '../game/enum_type.dart' as _iu5mz6ho;

abstract class FriendActivityDto
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  FriendActivityDto._({
    required this.partieId,
    required this.friend,
    required this.typePartie,
    required this.result,
    required this.opponent,
    this.eloVariation,
    required this.at,
  });

  factory FriendActivityDto({
    required _isc.UuidValue partieId,
    required _ifdcjd4x.FriendUserDto friend,
    required _iu5mz6ho.EnumType typePartie,
    required _ib5rq0bj.EnumMatchResult result,
    required String opponent,
    int? eloVariation,
    required DateTime at,
  }) = _FriendActivityDtoImpl;

  factory FriendActivityDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return FriendActivityDto(
      partieId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['partieId'],
      ),
      friend: _ixdd0t97.Protocol().deserialize<_ifdcjd4x.FriendUserDto>(
        jsonSerialization['friend'],
      ),
      typePartie: _iu5mz6ho.EnumType.fromJson(
        (jsonSerialization['typePartie'] as String),
      ),
      result: _ib5rq0bj.EnumMatchResult.fromJson(
        (jsonSerialization['result'] as String),
      ),
      opponent: jsonSerialization['opponent'] as String,
      eloVariation: jsonSerialization['eloVariation'] as int?,
      at: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['at']),
    );
  }

  _isc.UuidValue partieId;

  _ifdcjd4x.FriendUserDto friend;

  _iu5mz6ho.EnumType typePartie;

  _ib5rq0bj.EnumMatchResult result;

  String opponent;

  int? eloVariation;

  DateTime at;

  /// Returns a shallow copy of this [FriendActivityDto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  FriendActivityDto copyWith({
    _isc.UuidValue? partieId,
    _ifdcjd4x.FriendUserDto? friend,
    _iu5mz6ho.EnumType? typePartie,
    _ib5rq0bj.EnumMatchResult? result,
    String? opponent,
    int? eloVariation,
    DateTime? at,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FriendActivityDto',
      'partieId': partieId.toJson(),
      'friend': friend.toJson(),
      'typePartie': typePartie.toJson(),
      'result': result.toJson(),
      'opponent': opponent,
      if (eloVariation != null) 'eloVariation': eloVariation,
      'at': at.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FriendActivityDto',
      'partieId': partieId.toJson(),
      'friend': friend.toJsonForProtocol(),
      'typePartie': typePartie.toJson(),
      'result': result.toJson(),
      'opponent': opponent,
      if (eloVariation != null) 'eloVariation': eloVariation,
      'at': at.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FriendActivityDtoImpl extends FriendActivityDto {
  _FriendActivityDtoImpl({
    required _isc.UuidValue partieId,
    required _ifdcjd4x.FriendUserDto friend,
    required _iu5mz6ho.EnumType typePartie,
    required _ib5rq0bj.EnumMatchResult result,
    required String opponent,
    int? eloVariation,
    required DateTime at,
  }) : super._(
         partieId: partieId,
         friend: friend,
         typePartie: typePartie,
         result: result,
         opponent: opponent,
         eloVariation: eloVariation,
         at: at,
       );

  /// Returns a shallow copy of this [FriendActivityDto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  FriendActivityDto copyWith({
    _isc.UuidValue? partieId,
    _ifdcjd4x.FriendUserDto? friend,
    _iu5mz6ho.EnumType? typePartie,
    _ib5rq0bj.EnumMatchResult? result,
    String? opponent,
    Object? eloVariation = _Undefined,
    DateTime? at,
  }) {
    return FriendActivityDto(
      partieId: partieId ?? this.partieId,
      friend: friend ?? this.friend.copyWith(),
      typePartie: typePartie ?? this.typePartie,
      result: result ?? this.result,
      opponent: opponent ?? this.opponent,
      eloVariation: eloVariation is int? ? eloVariation : this.eloVariation,
      at: at ?? this.at,
    );
  }
}
