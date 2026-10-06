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
import 'package:serverpod/serverpod.dart' as _is;

abstract class FriendUserDto
    implements _is.SerializableModel, _is.ProtocolSerialization {
  FriendUserDto._({
    required this.userId,
    required this.username,
    this.thumbnailUrl,
    required this.elo,
  });

  factory FriendUserDto({
    required _is.UuidValue userId,
    required String username,
    String? thumbnailUrl,
    required int elo,
  }) = _FriendUserDtoImpl;

  factory FriendUserDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return FriendUserDto(
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      username: jsonSerialization['username'] as String,
      thumbnailUrl: jsonSerialization['thumbnailUrl'] as String?,
      elo: jsonSerialization['elo'] as int,
    );
  }

  _is.UuidValue userId;

  String username;

  String? thumbnailUrl;

  int elo;

  /// Returns a shallow copy of this [FriendUserDto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FriendUserDto copyWith({
    _is.UuidValue? userId,
    String? username,
    String? thumbnailUrl,
    int? elo,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FriendUserDto',
      'userId': userId.toJson(),
      'username': username,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'elo': elo,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FriendUserDto',
      'userId': userId.toJson(),
      'username': username,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'elo': elo,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FriendUserDtoImpl extends FriendUserDto {
  _FriendUserDtoImpl({
    required _is.UuidValue userId,
    required String username,
    String? thumbnailUrl,
    required int elo,
  }) : super._(
         userId: userId,
         username: username,
         thumbnailUrl: thumbnailUrl,
         elo: elo,
       );

  /// Returns a shallow copy of this [FriendUserDto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FriendUserDto copyWith({
    _is.UuidValue? userId,
    String? username,
    Object? thumbnailUrl = _Undefined,
    int? elo,
  }) {
    return FriendUserDto(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      thumbnailUrl: thumbnailUrl is String? ? thumbnailUrl : this.thumbnailUrl,
      elo: elo ?? this.elo,
    );
  }
}
