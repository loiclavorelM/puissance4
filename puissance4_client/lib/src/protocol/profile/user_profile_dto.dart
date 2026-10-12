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

abstract class UserProfileDto
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  UserProfileDto._({
    required this.id,
    required this.username,
    this.thumbnailUrl,
    required this.elo,
    required this.nbParties,
    required this.nbVictoires,
    bool? isGuest,
  }) : isGuest = isGuest ?? false;

  factory UserProfileDto({
    required _isc.UuidValue id,
    required String username,
    String? thumbnailUrl,
    required int elo,
    required int nbParties,
    required int nbVictoires,
    bool? isGuest,
  }) = _UserProfileDtoImpl;

  factory UserProfileDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserProfileDto(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      username: jsonSerialization['username'] as String,
      thumbnailUrl: jsonSerialization['thumbnailUrl'] as String?,
      elo: jsonSerialization['elo'] as int,
      nbParties: jsonSerialization['nbParties'] as int,
      nbVictoires: jsonSerialization['nbVictoires'] as int,
      isGuest: jsonSerialization['isGuest'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isGuest']),
    );
  }

  _isc.UuidValue id;

  String username;

  String? thumbnailUrl;

  int elo;

  int nbParties;

  int nbVictoires;

  bool isGuest;

  /// Returns a shallow copy of this [UserProfileDto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UserProfileDto copyWith({
    _isc.UuidValue? id,
    String? username,
    String? thumbnailUrl,
    int? elo,
    int? nbParties,
    int? nbVictoires,
    bool? isGuest,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserProfileDto',
      'id': id.toJson(),
      'username': username,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'elo': elo,
      'nbParties': nbParties,
      'nbVictoires': nbVictoires,
      'isGuest': isGuest,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserProfileDto',
      'id': id.toJson(),
      'username': username,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'elo': elo,
      'nbParties': nbParties,
      'nbVictoires': nbVictoires,
      'isGuest': isGuest,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserProfileDtoImpl extends UserProfileDto {
  _UserProfileDtoImpl({
    required _isc.UuidValue id,
    required String username,
    String? thumbnailUrl,
    required int elo,
    required int nbParties,
    required int nbVictoires,
    bool? isGuest,
  }) : super._(
         id: id,
         username: username,
         thumbnailUrl: thumbnailUrl,
         elo: elo,
         nbParties: nbParties,
         nbVictoires: nbVictoires,
         isGuest: isGuest,
       );

  /// Returns a shallow copy of this [UserProfileDto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UserProfileDto copyWith({
    _isc.UuidValue? id,
    String? username,
    Object? thumbnailUrl = _Undefined,
    int? elo,
    int? nbParties,
    int? nbVictoires,
    bool? isGuest,
  }) {
    return UserProfileDto(
      id: id ?? this.id,
      username: username ?? this.username,
      thumbnailUrl: thumbnailUrl is String? ? thumbnailUrl : this.thumbnailUrl,
      elo: elo ?? this.elo,
      nbParties: nbParties ?? this.nbParties,
      nbVictoires: nbVictoires ?? this.nbVictoires,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}
