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
import '../game/enum_color.dart' as _ik9tqcac;
import '../game/enum_game_end_reason.dart' as _iuugnpks;
import '../game/enum_outcome.dart' as _ilk7rg3u;
import '../game/enum_type.dart' as _iu5mz6ho;
import '../game/game_player_info.dart' as _iw3k47v1;

abstract class ReplayDto
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ReplayDto._({
    required this.id,
    required this.typePartie,
    required this.date,
    required this.moves,
    required this.rouge,
    required this.jaune,
    required this.playedAs,
    this.winner,
    this.endReason,
  });

  factory ReplayDto({
    required _isc.UuidValue id,
    required _iu5mz6ho.EnumType typePartie,
    required DateTime date,
    required List<int> moves,
    required _iw3k47v1.GamePlayerInfo rouge,
    required _iw3k47v1.GamePlayerInfo jaune,
    required _ik9tqcac.EnumColor playedAs,
    _ilk7rg3u.EnumOutcome? winner,
    _iuugnpks.EnumGameEndReason? endReason,
  }) = _ReplayDtoImpl;

  factory ReplayDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReplayDto(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      typePartie: _iu5mz6ho.EnumType.fromJson(
        (jsonSerialization['typePartie'] as String),
      ),
      date: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      moves: _ixdd0t97.Protocol().deserialize<List<int>>(
        jsonSerialization['moves'],
      ),
      rouge: _ixdd0t97.Protocol().deserialize<_iw3k47v1.GamePlayerInfo>(
        jsonSerialization['rouge'],
      ),
      jaune: _ixdd0t97.Protocol().deserialize<_iw3k47v1.GamePlayerInfo>(
        jsonSerialization['jaune'],
      ),
      playedAs: _ik9tqcac.EnumColor.fromJson(
        (jsonSerialization['playedAs'] as String),
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
    );
  }

  _isc.UuidValue id;

  _iu5mz6ho.EnumType typePartie;

  DateTime date;

  List<int> moves;

  _iw3k47v1.GamePlayerInfo rouge;

  _iw3k47v1.GamePlayerInfo jaune;

  _ik9tqcac.EnumColor playedAs;

  _ilk7rg3u.EnumOutcome? winner;

  _iuugnpks.EnumGameEndReason? endReason;

  /// Returns a shallow copy of this [ReplayDto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ReplayDto copyWith({
    _isc.UuidValue? id,
    _iu5mz6ho.EnumType? typePartie,
    DateTime? date,
    List<int>? moves,
    _iw3k47v1.GamePlayerInfo? rouge,
    _iw3k47v1.GamePlayerInfo? jaune,
    _ik9tqcac.EnumColor? playedAs,
    _ilk7rg3u.EnumOutcome? winner,
    _iuugnpks.EnumGameEndReason? endReason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReplayDto',
      'id': id.toJson(),
      'typePartie': typePartie.toJson(),
      'date': date.toJson(),
      'moves': moves.toJson(),
      'rouge': rouge.toJson(),
      'jaune': jaune.toJson(),
      'playedAs': playedAs.toJson(),
      if (winner != null) 'winner': winner?.toJson(),
      if (endReason != null) 'endReason': endReason?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ReplayDto',
      'id': id.toJson(),
      'typePartie': typePartie.toJson(),
      'date': date.toJson(),
      'moves': moves.toJson(),
      'rouge': rouge.toJsonForProtocol(),
      'jaune': jaune.toJsonForProtocol(),
      'playedAs': playedAs.toJson(),
      if (winner != null) 'winner': winner?.toJson(),
      if (endReason != null) 'endReason': endReason?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReplayDtoImpl extends ReplayDto {
  _ReplayDtoImpl({
    required _isc.UuidValue id,
    required _iu5mz6ho.EnumType typePartie,
    required DateTime date,
    required List<int> moves,
    required _iw3k47v1.GamePlayerInfo rouge,
    required _iw3k47v1.GamePlayerInfo jaune,
    required _ik9tqcac.EnumColor playedAs,
    _ilk7rg3u.EnumOutcome? winner,
    _iuugnpks.EnumGameEndReason? endReason,
  }) : super._(
         id: id,
         typePartie: typePartie,
         date: date,
         moves: moves,
         rouge: rouge,
         jaune: jaune,
         playedAs: playedAs,
         winner: winner,
         endReason: endReason,
       );

  /// Returns a shallow copy of this [ReplayDto]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ReplayDto copyWith({
    _isc.UuidValue? id,
    _iu5mz6ho.EnumType? typePartie,
    DateTime? date,
    List<int>? moves,
    _iw3k47v1.GamePlayerInfo? rouge,
    _iw3k47v1.GamePlayerInfo? jaune,
    _ik9tqcac.EnumColor? playedAs,
    Object? winner = _Undefined,
    Object? endReason = _Undefined,
  }) {
    return ReplayDto(
      id: id ?? this.id,
      typePartie: typePartie ?? this.typePartie,
      date: date ?? this.date,
      moves: moves ?? this.moves.map((e0) => e0).toList(),
      rouge: rouge ?? this.rouge.copyWith(),
      jaune: jaune ?? this.jaune.copyWith(),
      playedAs: playedAs ?? this.playedAs,
      winner: winner is _ilk7rg3u.EnumOutcome? ? winner : this.winner,
      endReason: endReason is _iuugnpks.EnumGameEndReason?
          ? endReason
          : this.endReason,
    );
  }
}
