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

abstract class GamePlayerInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  GamePlayerInfo._({
    required this.username,
    required this.elo,
    bool? isBot,
  }) : isBot = isBot ?? false;

  factory GamePlayerInfo({
    required String username,
    required int elo,
    bool? isBot,
  }) = _GamePlayerInfoImpl;

  factory GamePlayerInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return GamePlayerInfo(
      username: jsonSerialization['username'] as String,
      elo: jsonSerialization['elo'] as int,
      isBot: jsonSerialization['isBot'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isBot']),
    );
  }

  String username;

  int elo;

  bool isBot;

  /// Returns a shallow copy of this [GamePlayerInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  GamePlayerInfo copyWith({
    String? username,
    int? elo,
    bool? isBot,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GamePlayerInfo',
      'username': username,
      'elo': elo,
      'isBot': isBot,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GamePlayerInfo',
      'username': username,
      'elo': elo,
      'isBot': isBot,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _GamePlayerInfoImpl extends GamePlayerInfo {
  _GamePlayerInfoImpl({
    required String username,
    required int elo,
    bool? isBot,
  }) : super._(
         username: username,
         elo: elo,
         isBot: isBot,
       );

  /// Returns a shallow copy of this [GamePlayerInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  GamePlayerInfo copyWith({
    String? username,
    int? elo,
    bool? isBot,
  }) {
    return GamePlayerInfo(
      username: username ?? this.username,
      elo: elo ?? this.elo,
      isBot: isBot ?? this.isBot,
    );
  }
}
