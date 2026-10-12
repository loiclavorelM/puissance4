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

abstract class FriendChallengeDto
    implements _is.SerializableModel, _is.ProtocolSerialization {
  FriendChallengeDto._({
    required this.code,
    required this.from,
    required this.expiresAt,
  });

  factory FriendChallengeDto({
    required String code,
    required _ifdcjd4x.FriendUserDto from,
    required DateTime expiresAt,
  }) = _FriendChallengeDtoImpl;

  factory FriendChallengeDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return FriendChallengeDto(
      code: jsonSerialization['code'] as String,
      from: _irho11n9.Protocol().deserialize<_ifdcjd4x.FriendUserDto>(
        jsonSerialization['from'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  String code;

  _ifdcjd4x.FriendUserDto from;

  DateTime expiresAt;

  /// Returns a shallow copy of this [FriendChallengeDto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FriendChallengeDto copyWith({
    String? code,
    _ifdcjd4x.FriendUserDto? from,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FriendChallengeDto',
      'code': code,
      'from': from.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FriendChallengeDto',
      'code': code,
      'from': from.toJsonForProtocol(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _FriendChallengeDtoImpl extends FriendChallengeDto {
  _FriendChallengeDtoImpl({
    required String code,
    required _ifdcjd4x.FriendUserDto from,
    required DateTime expiresAt,
  }) : super._(
         code: code,
         from: from,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [FriendChallengeDto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FriendChallengeDto copyWith({
    String? code,
    _ifdcjd4x.FriendUserDto? from,
    DateTime? expiresAt,
  }) {
    return FriendChallengeDto(
      code: code ?? this.code,
      from: from ?? this.from.copyWith(),
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
