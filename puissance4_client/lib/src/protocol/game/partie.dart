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
import '../game/enum_game_end_reason.dart' as _iuugnpks;
import '../game/enum_outcome.dart' as _ilk7rg3u;
import '../game/enum_statut.dart' as _irc493lf;
import '../game/enum_type.dart' as _iu5mz6ho;

abstract class Partie
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Partie._({
    this.id,
    this.code,
    required this.typePartie,
    required this.playerRougeId,
    required this.playerJauneId,
    this.winner,
    required this.status,
    required this.moves,
    DateTime? createdAt,
    this.updatedAt,
    this.rougeConnectionId,
    this.rougeDisconnectedAt,
    this.jauneConnectionId,
    this.jauneDisconnectedAt,
    this.endReason,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Partie({
    _isc.UuidValue? id,
    String? code,
    required _iu5mz6ho.EnumType typePartie,
    required _isc.UuidValue playerRougeId,
    required _isc.UuidValue playerJauneId,
    _ilk7rg3u.EnumOutcome? winner,
    required _irc493lf.EnumStatut status,
    required List<int> moves,
    DateTime? createdAt,
    DateTime? updatedAt,
    _isc.UuidValue? rougeConnectionId,
    DateTime? rougeDisconnectedAt,
    _isc.UuidValue? jauneConnectionId,
    DateTime? jauneDisconnectedAt,
    _iuugnpks.EnumGameEndReason? endReason,
  }) = _PartieImpl;

  factory Partie.fromJson(Map<String, dynamic> jsonSerialization) {
    return Partie(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      code: jsonSerialization['code'] as String?,
      typePartie: _iu5mz6ho.EnumType.fromJson(
        (jsonSerialization['typePartie'] as String),
      ),
      playerRougeId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['playerRougeId'],
      ),
      playerJauneId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['playerJauneId'],
      ),
      winner: jsonSerialization['winner'] == null
          ? null
          : _ilk7rg3u.EnumOutcome.fromJson(
              (jsonSerialization['winner'] as String),
            ),
      status: _irc493lf.EnumStatut.fromJson(
        (jsonSerialization['status'] as String),
      ),
      moves: _ixdd0t97.Protocol().deserialize<List<int>>(
        jsonSerialization['moves'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      rougeConnectionId: jsonSerialization['rougeConnectionId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['rougeConnectionId'],
            ),
      rougeDisconnectedAt: jsonSerialization['rougeDisconnectedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['rougeDisconnectedAt'],
            ),
      jauneConnectionId: jsonSerialization['jauneConnectionId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['jauneConnectionId'],
            ),
      jauneDisconnectedAt: jsonSerialization['jauneDisconnectedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['jauneDisconnectedAt'],
            ),
      endReason: jsonSerialization['endReason'] == null
          ? null
          : _iuugnpks.EnumGameEndReason.fromJson(
              (jsonSerialization['endReason'] as String),
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  String? code;

  _iu5mz6ho.EnumType typePartie;

  _isc.UuidValue playerRougeId;

  _isc.UuidValue playerJauneId;

  _ilk7rg3u.EnumOutcome? winner;

  _irc493lf.EnumStatut status;

  List<int> moves;

  DateTime createdAt;

  DateTime? updatedAt;

  _isc.UuidValue? rougeConnectionId;

  DateTime? rougeDisconnectedAt;

  _isc.UuidValue? jauneConnectionId;

  DateTime? jauneDisconnectedAt;

  _iuugnpks.EnumGameEndReason? endReason;

  /// Returns a shallow copy of this [Partie]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Partie copyWith({
    _isc.UuidValue? id,
    String? code,
    _iu5mz6ho.EnumType? typePartie,
    _isc.UuidValue? playerRougeId,
    _isc.UuidValue? playerJauneId,
    _ilk7rg3u.EnumOutcome? winner,
    _irc493lf.EnumStatut? status,
    List<int>? moves,
    DateTime? createdAt,
    DateTime? updatedAt,
    _isc.UuidValue? rougeConnectionId,
    DateTime? rougeDisconnectedAt,
    _isc.UuidValue? jauneConnectionId,
    DateTime? jauneDisconnectedAt,
    _iuugnpks.EnumGameEndReason? endReason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Partie',
      if (id != null) 'id': id?.toJson(),
      if (code != null) 'code': code,
      'typePartie': typePartie.toJson(),
      'playerRougeId': playerRougeId.toJson(),
      'playerJauneId': playerJauneId.toJson(),
      if (winner != null) 'winner': winner?.toJson(),
      'status': status.toJson(),
      'moves': moves.toJson(),
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (rougeConnectionId != null)
        'rougeConnectionId': rougeConnectionId?.toJson(),
      if (rougeDisconnectedAt != null)
        'rougeDisconnectedAt': rougeDisconnectedAt?.toJson(),
      if (jauneConnectionId != null)
        'jauneConnectionId': jauneConnectionId?.toJson(),
      if (jauneDisconnectedAt != null)
        'jauneDisconnectedAt': jauneDisconnectedAt?.toJson(),
      if (endReason != null) 'endReason': endReason?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Partie',
      if (id != null) 'id': id?.toJson(),
      if (code != null) 'code': code,
      'typePartie': typePartie.toJson(),
      'playerRougeId': playerRougeId.toJson(),
      'playerJauneId': playerJauneId.toJson(),
      if (winner != null) 'winner': winner?.toJson(),
      'status': status.toJson(),
      'moves': moves.toJson(),
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (rougeConnectionId != null)
        'rougeConnectionId': rougeConnectionId?.toJson(),
      if (rougeDisconnectedAt != null)
        'rougeDisconnectedAt': rougeDisconnectedAt?.toJson(),
      if (jauneConnectionId != null)
        'jauneConnectionId': jauneConnectionId?.toJson(),
      if (jauneDisconnectedAt != null)
        'jauneDisconnectedAt': jauneDisconnectedAt?.toJson(),
      if (endReason != null) 'endReason': endReason?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PartieImpl extends Partie {
  _PartieImpl({
    _isc.UuidValue? id,
    String? code,
    required _iu5mz6ho.EnumType typePartie,
    required _isc.UuidValue playerRougeId,
    required _isc.UuidValue playerJauneId,
    _ilk7rg3u.EnumOutcome? winner,
    required _irc493lf.EnumStatut status,
    required List<int> moves,
    DateTime? createdAt,
    DateTime? updatedAt,
    _isc.UuidValue? rougeConnectionId,
    DateTime? rougeDisconnectedAt,
    _isc.UuidValue? jauneConnectionId,
    DateTime? jauneDisconnectedAt,
    _iuugnpks.EnumGameEndReason? endReason,
  }) : super._(
         id: id,
         code: code,
         typePartie: typePartie,
         playerRougeId: playerRougeId,
         playerJauneId: playerJauneId,
         winner: winner,
         status: status,
         moves: moves,
         createdAt: createdAt,
         updatedAt: updatedAt,
         rougeConnectionId: rougeConnectionId,
         rougeDisconnectedAt: rougeDisconnectedAt,
         jauneConnectionId: jauneConnectionId,
         jauneDisconnectedAt: jauneDisconnectedAt,
         endReason: endReason,
       );

  /// Returns a shallow copy of this [Partie]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Partie copyWith({
    Object? id = _Undefined,
    Object? code = _Undefined,
    _iu5mz6ho.EnumType? typePartie,
    _isc.UuidValue? playerRougeId,
    _isc.UuidValue? playerJauneId,
    Object? winner = _Undefined,
    _irc493lf.EnumStatut? status,
    List<int>? moves,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
    Object? rougeConnectionId = _Undefined,
    Object? rougeDisconnectedAt = _Undefined,
    Object? jauneConnectionId = _Undefined,
    Object? jauneDisconnectedAt = _Undefined,
    Object? endReason = _Undefined,
  }) {
    return Partie(
      id: id is _isc.UuidValue? ? id : this.id,
      code: code is String? ? code : this.code,
      typePartie: typePartie ?? this.typePartie,
      playerRougeId: playerRougeId ?? this.playerRougeId,
      playerJauneId: playerJauneId ?? this.playerJauneId,
      winner: winner is _ilk7rg3u.EnumOutcome? ? winner : this.winner,
      status: status ?? this.status,
      moves: moves ?? this.moves.map((e0) => e0).toList(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      rougeConnectionId: rougeConnectionId is _isc.UuidValue?
          ? rougeConnectionId
          : this.rougeConnectionId,
      rougeDisconnectedAt: rougeDisconnectedAt is DateTime?
          ? rougeDisconnectedAt
          : this.rougeDisconnectedAt,
      jauneConnectionId: jauneConnectionId is _isc.UuidValue?
          ? jauneConnectionId
          : this.jauneConnectionId,
      jauneDisconnectedAt: jauneDisconnectedAt is DateTime?
          ? jauneDisconnectedAt
          : this.jauneDisconnectedAt,
      endReason: endReason is _iuugnpks.EnumGameEndReason?
          ? endReason
          : this.endReason,
    );
  }
}
