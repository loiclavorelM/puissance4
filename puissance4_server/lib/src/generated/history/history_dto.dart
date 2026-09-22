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
import '../game/enum_color.dart' as _ik9tqcac;
import '../game/enum_match_result.dart' as _ib5rq0bj;
import '../game/enum_type.dart' as _iu5mz6ho;

abstract class HistoryDto
    implements _is.SerializableModel, _is.ProtocolSerialization {
  HistoryDto._({
    required this.id,
    required this.date,
    required this.typePartie,
    required this.adversaire,
    required this.resultat,
    required this.playedAs,
    this.eloVariation,
  });

  factory HistoryDto({
    required _is.UuidValue id,
    required DateTime date,
    required _iu5mz6ho.EnumType typePartie,
    required String adversaire,
    required _ib5rq0bj.EnumMatchResult resultat,
    required _ik9tqcac.EnumColor playedAs,
    int? eloVariation,
  }) = _HistoryDtoImpl;

  factory HistoryDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return HistoryDto(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      date: _is.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      typePartie: _iu5mz6ho.EnumType.fromJson(
        (jsonSerialization['typePartie'] as String),
      ),
      adversaire: jsonSerialization['adversaire'] as String,
      resultat: _ib5rq0bj.EnumMatchResult.fromJson(
        (jsonSerialization['resultat'] as String),
      ),
      playedAs: _ik9tqcac.EnumColor.fromJson(
        (jsonSerialization['playedAs'] as String),
      ),
      eloVariation: jsonSerialization['eloVariation'] as int?,
    );
  }

  _is.UuidValue id;

  DateTime date;

  _iu5mz6ho.EnumType typePartie;

  String adversaire;

  _ib5rq0bj.EnumMatchResult resultat;

  _ik9tqcac.EnumColor playedAs;

  int? eloVariation;

  /// Returns a shallow copy of this [HistoryDto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  HistoryDto copyWith({
    _is.UuidValue? id,
    DateTime? date,
    _iu5mz6ho.EnumType? typePartie,
    String? adversaire,
    _ib5rq0bj.EnumMatchResult? resultat,
    _ik9tqcac.EnumColor? playedAs,
    int? eloVariation,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HistoryDto',
      'id': id.toJson(),
      'date': date.toJson(),
      'typePartie': typePartie.toJson(),
      'adversaire': adversaire,
      'resultat': resultat.toJson(),
      'playedAs': playedAs.toJson(),
      if (eloVariation != null) 'eloVariation': eloVariation,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HistoryDto',
      'id': id.toJson(),
      'date': date.toJson(),
      'typePartie': typePartie.toJson(),
      'adversaire': adversaire,
      'resultat': resultat.toJson(),
      'playedAs': playedAs.toJson(),
      if (eloVariation != null) 'eloVariation': eloVariation,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HistoryDtoImpl extends HistoryDto {
  _HistoryDtoImpl({
    required _is.UuidValue id,
    required DateTime date,
    required _iu5mz6ho.EnumType typePartie,
    required String adversaire,
    required _ib5rq0bj.EnumMatchResult resultat,
    required _ik9tqcac.EnumColor playedAs,
    int? eloVariation,
  }) : super._(
         id: id,
         date: date,
         typePartie: typePartie,
         adversaire: adversaire,
         resultat: resultat,
         playedAs: playedAs,
         eloVariation: eloVariation,
       );

  /// Returns a shallow copy of this [HistoryDto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  HistoryDto copyWith({
    _is.UuidValue? id,
    DateTime? date,
    _iu5mz6ho.EnumType? typePartie,
    String? adversaire,
    _ib5rq0bj.EnumMatchResult? resultat,
    _ik9tqcac.EnumColor? playedAs,
    Object? eloVariation = _Undefined,
  }) {
    return HistoryDto(
      id: id ?? this.id,
      date: date ?? this.date,
      typePartie: typePartie ?? this.typePartie,
      adversaire: adversaire ?? this.adversaire,
      resultat: resultat ?? this.resultat,
      playedAs: playedAs ?? this.playedAs,
      eloVariation: eloVariation is int? ? eloVariation : this.eloVariation,
    );
  }
}
