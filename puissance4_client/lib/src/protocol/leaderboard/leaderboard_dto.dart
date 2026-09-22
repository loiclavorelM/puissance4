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

abstract class LeaderboardEntryDto
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  LeaderboardEntryDto._({
    required this.id,
    required this.rank,
    required this.username,
    this.thumbnailUrl,
    required this.elo,
  });

  factory LeaderboardEntryDto({
    required _isc.UuidValue id,
    required int rank,
    required String username,
    String? thumbnailUrl,
    required int elo,
  }) = _LeaderboardEntryDtoImpl;

  factory LeaderboardEntryDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return LeaderboardEntryDto(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      rank: jsonSerialization['rank'] as int,
      username: jsonSerialization['username'] as String,
      thumbnailUrl: jsonSerialization['thumbnailUrl'] as String?,
      elo: jsonSerialization['elo'] as int,
    );
  }

  _isc.UuidValue id;

  int rank;

  String username;

  String? thumbnailUrl;

  int elo;

  /// Returns a shallow copy of this [LeaderboardEntryDto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  LeaderboardEntryDto copyWith({
    _isc.UuidValue? id,
    int? rank,
    String? username,
    String? thumbnailUrl,
    int? elo,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LeaderboardEntryDto',
      'id': id.toJson(),
      'rank': rank,
      'username': username,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'elo': elo,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LeaderboardEntryDto',
      'id': id.toJson(),
      'rank': rank,
      'username': username,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'elo': elo,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LeaderboardEntryDtoImpl extends LeaderboardEntryDto {
  _LeaderboardEntryDtoImpl({
    required _isc.UuidValue id,
    required int rank,
    required String username,
    String? thumbnailUrl,
    required int elo,
  }) : super._(
         id: id,
         rank: rank,
         username: username,
         thumbnailUrl: thumbnailUrl,
         elo: elo,
       );

  /// Returns a shallow copy of this [LeaderboardEntryDto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  LeaderboardEntryDto copyWith({
    _isc.UuidValue? id,
    int? rank,
    String? username,
    Object? thumbnailUrl = _Undefined,
    int? elo,
  }) {
    return LeaderboardEntryDto(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      username: username ?? this.username,
      thumbnailUrl: thumbnailUrl is String? ? thumbnailUrl : this.thumbnailUrl,
      elo: elo ?? this.elo,
    );
  }
}
