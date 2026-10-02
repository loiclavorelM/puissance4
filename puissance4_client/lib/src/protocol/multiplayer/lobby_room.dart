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

abstract class LobbyRoom
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  LobbyRoom._({
    required this.code,
    required this.hostUsername,
    required this.hostElo,
    this.hostThumbnailUrl,
    required this.expiresAt,
  });

  factory LobbyRoom({
    required String code,
    required String hostUsername,
    required int hostElo,
    String? hostThumbnailUrl,
    required DateTime expiresAt,
  }) = _LobbyRoomImpl;

  factory LobbyRoom.fromJson(Map<String, dynamic> jsonSerialization) {
    return LobbyRoom(
      code: jsonSerialization['code'] as String,
      hostUsername: jsonSerialization['hostUsername'] as String,
      hostElo: jsonSerialization['hostElo'] as int,
      hostThumbnailUrl: jsonSerialization['hostThumbnailUrl'] as String?,
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  String code;

  String hostUsername;

  int hostElo;

  String? hostThumbnailUrl;

  DateTime expiresAt;

  /// Returns a shallow copy of this [LobbyRoom]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  LobbyRoom copyWith({
    String? code,
    String? hostUsername,
    int? hostElo,
    String? hostThumbnailUrl,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LobbyRoom',
      'code': code,
      'hostUsername': hostUsername,
      'hostElo': hostElo,
      if (hostThumbnailUrl != null) 'hostThumbnailUrl': hostThumbnailUrl,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LobbyRoom',
      'code': code,
      'hostUsername': hostUsername,
      'hostElo': hostElo,
      if (hostThumbnailUrl != null) 'hostThumbnailUrl': hostThumbnailUrl,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LobbyRoomImpl extends LobbyRoom {
  _LobbyRoomImpl({
    required String code,
    required String hostUsername,
    required int hostElo,
    String? hostThumbnailUrl,
    required DateTime expiresAt,
  }) : super._(
         code: code,
         hostUsername: hostUsername,
         hostElo: hostElo,
         hostThumbnailUrl: hostThumbnailUrl,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [LobbyRoom]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  LobbyRoom copyWith({
    String? code,
    String? hostUsername,
    int? hostElo,
    Object? hostThumbnailUrl = _Undefined,
    DateTime? expiresAt,
  }) {
    return LobbyRoom(
      code: code ?? this.code,
      hostUsername: hostUsername ?? this.hostUsername,
      hostElo: hostElo ?? this.hostElo,
      hostThumbnailUrl: hostThumbnailUrl is String?
          ? hostThumbnailUrl
          : this.hostThumbnailUrl,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
