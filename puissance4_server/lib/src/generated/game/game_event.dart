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
import '../game/enum_color.dart' as _ik9tqcac;
import '../game/enum_game_end_reason.dart' as _iuugnpks;
import '../game/enum_game_event_type.dart' as _iwu9m14m;
import '../game/enum_outcome.dart' as _ilk7rg3u;
import '../game/enum_type.dart' as _iu5mz6ho;
import '../game/game_player_info.dart' as _iw3k47v1;

abstract class GameEvent
    implements _is.SerializableModel, _is.ProtocolSerialization {
  GameEvent._({
    required this.type,
    this.code,
    this.roomExpiresAt,
    this.partieId,
    this.typePartie,
    this.yourColor,
    this.rouge,
    this.jaune,
    this.moves,
    this.turnDeadline,
    this.winner,
    this.endReason,
    this.aboutColor,
    this.opponentConnected,
    this.eloVariation,
  });

  factory GameEvent({
    required _iwu9m14m.EnumGameEventType type,
    String? code,
    DateTime? roomExpiresAt,
    _is.UuidValue? partieId,
    _iu5mz6ho.EnumType? typePartie,
    _ik9tqcac.EnumColor? yourColor,
    _iw3k47v1.GamePlayerInfo? rouge,
    _iw3k47v1.GamePlayerInfo? jaune,
    List<int>? moves,
    DateTime? turnDeadline,
    _ilk7rg3u.EnumOutcome? winner,
    _iuugnpks.EnumGameEndReason? endReason,
    _ik9tqcac.EnumColor? aboutColor,
    bool? opponentConnected,
    int? eloVariation,
  }) = _GameEventImpl;

  factory GameEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return GameEvent(
      type: _iwu9m14m.EnumGameEventType.fromJson(
        (jsonSerialization['type'] as String),
      ),
      code: jsonSerialization['code'] as String?,
      roomExpiresAt: jsonSerialization['roomExpiresAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['roomExpiresAt'],
            ),
      partieId: jsonSerialization['partieId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['partieId']),
      typePartie: jsonSerialization['typePartie'] == null
          ? null
          : _iu5mz6ho.EnumType.fromJson(
              (jsonSerialization['typePartie'] as String),
            ),
      yourColor: jsonSerialization['yourColor'] == null
          ? null
          : _ik9tqcac.EnumColor.fromJson(
              (jsonSerialization['yourColor'] as String),
            ),
      rouge: jsonSerialization['rouge'] == null
          ? null
          : _irho11n9.Protocol().deserialize<_iw3k47v1.GamePlayerInfo>(
              jsonSerialization['rouge'],
            ),
      jaune: jsonSerialization['jaune'] == null
          ? null
          : _irho11n9.Protocol().deserialize<_iw3k47v1.GamePlayerInfo>(
              jsonSerialization['jaune'],
            ),
      moves: jsonSerialization['moves'] == null
          ? null
          : _irho11n9.Protocol().deserialize<List<int>>(
              jsonSerialization['moves'],
            ),
      turnDeadline: jsonSerialization['turnDeadline'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['turnDeadline'],
            ),
      winner: jsonSerialization['winner'] == null
          ? null
          : _ilk7rg3u.EnumOutcome.fromJson(
              (jsonSerialization['winner'] as String),
            ),
      endReason: jsonSerialization['endReason'] == null
          ? null
          : _iuugnpks.EnumGameEndReason.fromJson(
              (jsonSerialization['endReason'] as String),
            ),
      aboutColor: jsonSerialization['aboutColor'] == null
          ? null
          : _ik9tqcac.EnumColor.fromJson(
              (jsonSerialization['aboutColor'] as String),
            ),
      opponentConnected: jsonSerialization['opponentConnected'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['opponentConnected'],
            ),
      eloVariation: jsonSerialization['eloVariation'] as int?,
    );
  }

  _iwu9m14m.EnumGameEventType type;

  String? code;

  DateTime? roomExpiresAt;

  _is.UuidValue? partieId;

  _iu5mz6ho.EnumType? typePartie;

  _ik9tqcac.EnumColor? yourColor;

  _iw3k47v1.GamePlayerInfo? rouge;

  _iw3k47v1.GamePlayerInfo? jaune;

  List<int>? moves;

  DateTime? turnDeadline;

  _ilk7rg3u.EnumOutcome? winner;

  _iuugnpks.EnumGameEndReason? endReason;

  _ik9tqcac.EnumColor? aboutColor;

  bool? opponentConnected;

  int? eloVariation;

  /// Returns a shallow copy of this [GameEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GameEvent copyWith({
    _iwu9m14m.EnumGameEventType? type,
    String? code,
    DateTime? roomExpiresAt,
    _is.UuidValue? partieId,
    _iu5mz6ho.EnumType? typePartie,
    _ik9tqcac.EnumColor? yourColor,
    _iw3k47v1.GamePlayerInfo? rouge,
    _iw3k47v1.GamePlayerInfo? jaune,
    List<int>? moves,
    DateTime? turnDeadline,
    _ilk7rg3u.EnumOutcome? winner,
    _iuugnpks.EnumGameEndReason? endReason,
    _ik9tqcac.EnumColor? aboutColor,
    bool? opponentConnected,
    int? eloVariation,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GameEvent',
      'type': type.toJson(),
      if (code != null) 'code': code,
      if (roomExpiresAt != null) 'roomExpiresAt': roomExpiresAt?.toJson(),
      if (partieId != null) 'partieId': partieId?.toJson(),
      if (typePartie != null) 'typePartie': typePartie?.toJson(),
      if (yourColor != null) 'yourColor': yourColor?.toJson(),
      if (rouge != null) 'rouge': rouge?.toJson(),
      if (jaune != null) 'jaune': jaune?.toJson(),
      if (moves != null) 'moves': moves?.toJson(),
      if (turnDeadline != null) 'turnDeadline': turnDeadline?.toJson(),
      if (winner != null) 'winner': winner?.toJson(),
      if (endReason != null) 'endReason': endReason?.toJson(),
      if (aboutColor != null) 'aboutColor': aboutColor?.toJson(),
      if (opponentConnected != null) 'opponentConnected': opponentConnected,
      if (eloVariation != null) 'eloVariation': eloVariation,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GameEvent',
      'type': type.toJson(),
      if (code != null) 'code': code,
      if (roomExpiresAt != null) 'roomExpiresAt': roomExpiresAt?.toJson(),
      if (partieId != null) 'partieId': partieId?.toJson(),
      if (typePartie != null) 'typePartie': typePartie?.toJson(),
      if (yourColor != null) 'yourColor': yourColor?.toJson(),
      if (rouge != null) 'rouge': rouge?.toJsonForProtocol(),
      if (jaune != null) 'jaune': jaune?.toJsonForProtocol(),
      if (moves != null) 'moves': moves?.toJson(),
      if (turnDeadline != null) 'turnDeadline': turnDeadline?.toJson(),
      if (winner != null) 'winner': winner?.toJson(),
      if (endReason != null) 'endReason': endReason?.toJson(),
      if (aboutColor != null) 'aboutColor': aboutColor?.toJson(),
      if (opponentConnected != null) 'opponentConnected': opponentConnected,
      if (eloVariation != null) 'eloVariation': eloVariation,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GameEventImpl extends GameEvent {
  _GameEventImpl({
    required _iwu9m14m.EnumGameEventType type,
    String? code,
    DateTime? roomExpiresAt,
    _is.UuidValue? partieId,
    _iu5mz6ho.EnumType? typePartie,
    _ik9tqcac.EnumColor? yourColor,
    _iw3k47v1.GamePlayerInfo? rouge,
    _iw3k47v1.GamePlayerInfo? jaune,
    List<int>? moves,
    DateTime? turnDeadline,
    _ilk7rg3u.EnumOutcome? winner,
    _iuugnpks.EnumGameEndReason? endReason,
    _ik9tqcac.EnumColor? aboutColor,
    bool? opponentConnected,
    int? eloVariation,
  }) : super._(
         type: type,
         code: code,
         roomExpiresAt: roomExpiresAt,
         partieId: partieId,
         typePartie: typePartie,
         yourColor: yourColor,
         rouge: rouge,
         jaune: jaune,
         moves: moves,
         turnDeadline: turnDeadline,
         winner: winner,
         endReason: endReason,
         aboutColor: aboutColor,
         opponentConnected: opponentConnected,
         eloVariation: eloVariation,
       );

  /// Returns a shallow copy of this [GameEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GameEvent copyWith({
    _iwu9m14m.EnumGameEventType? type,
    Object? code = _Undefined,
    Object? roomExpiresAt = _Undefined,
    Object? partieId = _Undefined,
    Object? typePartie = _Undefined,
    Object? yourColor = _Undefined,
    Object? rouge = _Undefined,
    Object? jaune = _Undefined,
    Object? moves = _Undefined,
    Object? turnDeadline = _Undefined,
    Object? winner = _Undefined,
    Object? endReason = _Undefined,
    Object? aboutColor = _Undefined,
    Object? opponentConnected = _Undefined,
    Object? eloVariation = _Undefined,
  }) {
    return GameEvent(
      type: type ?? this.type,
      code: code is String? ? code : this.code,
      roomExpiresAt: roomExpiresAt is DateTime?
          ? roomExpiresAt
          : this.roomExpiresAt,
      partieId: partieId is _is.UuidValue? ? partieId : this.partieId,
      typePartie: typePartie is _iu5mz6ho.EnumType?
          ? typePartie
          : this.typePartie,
      yourColor: yourColor is _ik9tqcac.EnumColor? ? yourColor : this.yourColor,
      rouge: rouge is _iw3k47v1.GamePlayerInfo?
          ? rouge
          : this.rouge?.copyWith(),
      jaune: jaune is _iw3k47v1.GamePlayerInfo?
          ? jaune
          : this.jaune?.copyWith(),
      moves: moves is List<int>? ? moves : this.moves?.map((e0) => e0).toList(),
      turnDeadline: turnDeadline is DateTime?
          ? turnDeadline
          : this.turnDeadline,
      winner: winner is _ilk7rg3u.EnumOutcome? ? winner : this.winner,
      endReason: endReason is _iuugnpks.EnumGameEndReason?
          ? endReason
          : this.endReason,
      aboutColor: aboutColor is _ik9tqcac.EnumColor?
          ? aboutColor
          : this.aboutColor,
      opponentConnected: opponentConnected is bool?
          ? opponentConnected
          : this.opponentConnected,
      eloVariation: eloVariation is int? ? eloVariation : this.eloVariation,
    );
  }
}
