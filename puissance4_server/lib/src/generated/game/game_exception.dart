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
import '../game/enum_game_error.dart' as _idjduqjg;

abstract class GameException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  GameException._({
    required this.reason,
    this.partieId,
  });

  factory GameException({
    required _idjduqjg.EnumGameError reason,
    _is.UuidValue? partieId,
  }) = _GameExceptionImpl;

  factory GameException.fromJson(Map<String, dynamic> jsonSerialization) {
    return GameException(
      reason: _idjduqjg.EnumGameError.fromJson(
        (jsonSerialization['reason'] as String),
      ),
      partieId: jsonSerialization['partieId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['partieId']),
    );
  }

  _idjduqjg.EnumGameError reason;

  _is.UuidValue? partieId;

  /// Returns a shallow copy of this [GameException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GameException copyWith({
    _idjduqjg.EnumGameError? reason,
    _is.UuidValue? partieId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GameException',
      'reason': reason.toJson(),
      if (partieId != null) 'partieId': partieId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GameException',
      'reason': reason.toJson(),
      if (partieId != null) 'partieId': partieId?.toJson(),
    };
  }

  @override
  String toString() {
    return 'GameException(reason: $reason, partieId: $partieId)';
  }
}

class _Undefined {}

class _GameExceptionImpl extends GameException {
  _GameExceptionImpl({
    required _idjduqjg.EnumGameError reason,
    _is.UuidValue? partieId,
  }) : super._(
         reason: reason,
         partieId: partieId,
       );

  /// Returns a shallow copy of this [GameException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GameException copyWith({
    _idjduqjg.EnumGameError? reason,
    Object? partieId = _Undefined,
  }) {
    return GameException(
      reason: reason ?? this.reason,
      partieId: partieId is _is.UuidValue? ? partieId : this.partieId,
    );
  }
}
