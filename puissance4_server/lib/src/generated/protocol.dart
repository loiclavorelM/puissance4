/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:puissance4_server/src/generated/history/history_dto.dart'
    as _islja9se;
import 'package:puissance4_server/src/generated/leaderboard/leaderboard_dto.dart'
    as _i5549tex;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'package:serverpod_offline_sync_server/serverpod_offline_sync_server.dart'
    as _izehhkf5;
import 'bot/bot.dart' as _iij7x2jd;
import 'bot/enum_bot_level.dart' as _i65o1ott;
import 'game/enum_color.dart' as _im0plaxm;
import 'game/enum_match_result.dart' as _iyr3fkva;
import 'game/enum_outcome.dart' as _imvh44pi;
import 'game/enum_statut.dart' as _ip6diune;
import 'game/enum_type.dart' as _ig2x4mxg;
import 'game/offline_match_result.dart' as _ir8nzxqr;
import 'game/partie.dart' as _iuas6tq9;
import 'game/player.dart' as _id5q07gg;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'history/history_dto.dart' as _inn2tdi6;
import 'leaderboard/leaderboard_dto.dart' as _i6lckwy9;
import 'profile/enum_profile_update_error.dart' as _ib6s6ke7;
import 'profile/profile_update_exception.dart' as _i1cvnna1;
import 'profile/user.dart' as _iytd8mlf;
import 'profile/user_profile_dto.dart' as _ivqmpbel;
import 'ranked/elo_history.dart' as _i8na2re5;
export 'bot/bot.dart';
export 'bot/enum_bot_level.dart';
export 'game/enum_color.dart';
export 'game/enum_match_result.dart';
export 'game/enum_outcome.dart';
export 'game/enum_statut.dart';
export 'game/enum_type.dart';
export 'game/offline_match_result.dart';
export 'game/partie.dart';
export 'game/player.dart';
export 'greetings/greeting.dart';
export 'history/history_dto.dart';
export 'leaderboard/leaderboard_dto.dart';
export 'profile/enum_profile_update_error.dart';
export 'profile/profile_update_exception.dart';
export 'profile/user.dart';
export 'profile/user_profile_dto.dart';
export 'ranked/elo_history.dart';
export 'sync_tables.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'bot',
      dartName: 'Bot',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'botName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'elo',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'pathModel',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'elo_history',
      dartName: 'EloHistory',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'partieId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'eloVariation',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'newElo',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'elo_history_fk_0',
          columns: ['userId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'elo_history_fk_1',
          columns: ['partieId'],
          referenceTable: 'partie',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'offline_match_result',
      dartName: 'OfflineMatchResult',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'spaceId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'result',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EnumMatchResult',
        ),
        _isp.ColumnDefinition(
          name: 'botLevel',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EnumBotLevel',
        ),
        _isp.ColumnDefinition(
          name: 'moves',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<int>',
        ),
        _isp.ColumnDefinition(
          name: 'playedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'reconciled',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'offline_match_result_fk_0',
          columns: ['spaceId'],
          referenceTable: 'offline_sync_spaces',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'partie',
      dartName: 'Partie',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'code',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'typePartie',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EnumType',
        ),
        _isp.ColumnDefinition(
          name: 'playerRougeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'playerJauneId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'winner',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:EnumOutcome?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EnumStatut',
        ),
        _isp.ColumnDefinition(
          name: 'moves',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<int>',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'partie_fk_0',
          columns: ['playerRougeId'],
          referenceTable: 'player',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'partie_fk_1',
          columns: ['playerJauneId'],
          referenceTable: 'player',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'player',
      dartName: 'Player',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'botId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'player_fk_0',
          columns: ['botId'],
          referenceTable: 'bot',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'player_fk_1',
          columns: ['userId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'user',
      dartName: 'User',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'username',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'thumbnailPath',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'elo',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1000',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'user_fk_0',
          columns: ['authUserId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'user_auth_user_id_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'user_username_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'username',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iacs.Protocol.targetTableDefinitions,
    ..._iais.Protocol.targetTableDefinitions,
    ..._izehhkf5.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iij7x2jd.Bot) {
      return _iij7x2jd.Bot.fromJson(data) as T;
    }
    if (t == _i65o1ott.EnumBotLevel) {
      return _i65o1ott.EnumBotLevel.fromJson(data) as T;
    }
    if (t == _im0plaxm.EnumColor) {
      return _im0plaxm.EnumColor.fromJson(data) as T;
    }
    if (t == _iyr3fkva.EnumMatchResult) {
      return _iyr3fkva.EnumMatchResult.fromJson(data) as T;
    }
    if (t == _imvh44pi.EnumOutcome) {
      return _imvh44pi.EnumOutcome.fromJson(data) as T;
    }
    if (t == _ip6diune.EnumStatut) {
      return _ip6diune.EnumStatut.fromJson(data) as T;
    }
    if (t == _ig2x4mxg.EnumType) {
      return _ig2x4mxg.EnumType.fromJson(data) as T;
    }
    if (t == _ir8nzxqr.OfflineMatchResult) {
      return _ir8nzxqr.OfflineMatchResult.fromJson(data) as T;
    }
    if (t == _iuas6tq9.Partie) {
      return _iuas6tq9.Partie.fromJson(data) as T;
    }
    if (t == _id5q07gg.Player) {
      return _id5q07gg.Player.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _inn2tdi6.HistoryDto) {
      return _inn2tdi6.HistoryDto.fromJson(data) as T;
    }
    if (t == _i6lckwy9.LeaderboardEntryDto) {
      return _i6lckwy9.LeaderboardEntryDto.fromJson(data) as T;
    }
    if (t == _ib6s6ke7.EnumProfileUpdateError) {
      return _ib6s6ke7.EnumProfileUpdateError.fromJson(data) as T;
    }
    if (t == _i1cvnna1.ProfileUpdateException) {
      return _i1cvnna1.ProfileUpdateException.fromJson(data) as T;
    }
    if (t == _iytd8mlf.User) {
      return _iytd8mlf.User.fromJson(data) as T;
    }
    if (t == _ivqmpbel.UserProfileDto) {
      return _ivqmpbel.UserProfileDto.fromJson(data) as T;
    }
    if (t == _i8na2re5.EloHistory) {
      return _i8na2re5.EloHistory.fromJson(data) as T;
    }
    if (t == _is.getType<_iij7x2jd.Bot?>()) {
      return (data != null ? _iij7x2jd.Bot.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i65o1ott.EnumBotLevel?>()) {
      return (data != null ? _i65o1ott.EnumBotLevel.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_im0plaxm.EnumColor?>()) {
      return (data != null ? _im0plaxm.EnumColor.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iyr3fkva.EnumMatchResult?>()) {
      return (data != null ? _iyr3fkva.EnumMatchResult.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_imvh44pi.EnumOutcome?>()) {
      return (data != null ? _imvh44pi.EnumOutcome.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ip6diune.EnumStatut?>()) {
      return (data != null ? _ip6diune.EnumStatut.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ig2x4mxg.EnumType?>()) {
      return (data != null ? _ig2x4mxg.EnumType.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ir8nzxqr.OfflineMatchResult?>()) {
      return (data != null ? _ir8nzxqr.OfflineMatchResult.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iuas6tq9.Partie?>()) {
      return (data != null ? _iuas6tq9.Partie.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_id5q07gg.Player?>()) {
      return (data != null ? _id5q07gg.Player.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_inn2tdi6.HistoryDto?>()) {
      return (data != null ? _inn2tdi6.HistoryDto.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i6lckwy9.LeaderboardEntryDto?>()) {
      return (data != null
              ? _i6lckwy9.LeaderboardEntryDto.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ib6s6ke7.EnumProfileUpdateError?>()) {
      return (data != null
              ? _ib6s6ke7.EnumProfileUpdateError.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i1cvnna1.ProfileUpdateException?>()) {
      return (data != null
              ? _i1cvnna1.ProfileUpdateException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iytd8mlf.User?>()) {
      return (data != null ? _iytd8mlf.User.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ivqmpbel.UserProfileDto?>()) {
      return (data != null ? _ivqmpbel.UserProfileDto.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i8na2re5.EloHistory?>()) {
      return (data != null ? _i8na2re5.EloHistory.fromJson(data) : null) as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_islja9se.HistoryDto>) {
      return (data as List)
              .map((e) => deserialize<_islja9se.HistoryDto>(e))
              .toList()
          as T;
    }
    if (t == List<_i5549tex.LeaderboardEntryDto>) {
      return (data as List)
              .map((e) => deserialize<_i5549tex.LeaderboardEntryDto>(e))
              .toList()
          as T;
    }
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _izehhkf5.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iij7x2jd.Bot => 'Bot',
      _i65o1ott.EnumBotLevel => 'EnumBotLevel',
      _im0plaxm.EnumColor => 'EnumColor',
      _iyr3fkva.EnumMatchResult => 'EnumMatchResult',
      _imvh44pi.EnumOutcome => 'EnumOutcome',
      _ip6diune.EnumStatut => 'EnumStatut',
      _ig2x4mxg.EnumType => 'EnumType',
      _ir8nzxqr.OfflineMatchResult => 'OfflineMatchResult',
      _iuas6tq9.Partie => 'Partie',
      _id5q07gg.Player => 'Player',
      _izw8z7ou.Greeting => 'Greeting',
      _inn2tdi6.HistoryDto => 'HistoryDto',
      _i6lckwy9.LeaderboardEntryDto => 'LeaderboardEntryDto',
      _ib6s6ke7.EnumProfileUpdateError => 'EnumProfileUpdateError',
      _i1cvnna1.ProfileUpdateException => 'ProfileUpdateException',
      _iytd8mlf.User => 'User',
      _ivqmpbel.UserProfileDto => 'UserProfileDto',
      _i8na2re5.EloHistory => 'EloHistory',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('puissance4.', '');
    }

    switch (data) {
      case _iij7x2jd.Bot():
        return 'Bot';
      case _i65o1ott.EnumBotLevel():
        return 'EnumBotLevel';
      case _im0plaxm.EnumColor():
        return 'EnumColor';
      case _iyr3fkva.EnumMatchResult():
        return 'EnumMatchResult';
      case _imvh44pi.EnumOutcome():
        return 'EnumOutcome';
      case _ip6diune.EnumStatut():
        return 'EnumStatut';
      case _ig2x4mxg.EnumType():
        return 'EnumType';
      case _ir8nzxqr.OfflineMatchResult():
        return 'OfflineMatchResult';
      case _iuas6tq9.Partie():
        return 'Partie';
      case _id5q07gg.Player():
        return 'Player';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _inn2tdi6.HistoryDto():
        return 'HistoryDto';
      case _i6lckwy9.LeaderboardEntryDto():
        return 'LeaderboardEntryDto';
      case _ib6s6ke7.EnumProfileUpdateError():
        return 'EnumProfileUpdateError';
      case _i1cvnna1.ProfileUpdateException():
        return 'ProfileUpdateException';
      case _iytd8mlf.User():
        return 'User';
      case _ivqmpbel.UserProfileDto():
        return 'UserProfileDto';
      case _i8na2re5.EloHistory():
        return 'EloHistory';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _izehhkf5.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_offline_sync.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Bot') {
      return deserialize<_iij7x2jd.Bot>(data['data']);
    }
    if (dataClassName == 'EnumBotLevel') {
      return deserialize<_i65o1ott.EnumBotLevel>(data['data']);
    }
    if (dataClassName == 'EnumColor') {
      return deserialize<_im0plaxm.EnumColor>(data['data']);
    }
    if (dataClassName == 'EnumMatchResult') {
      return deserialize<_iyr3fkva.EnumMatchResult>(data['data']);
    }
    if (dataClassName == 'EnumOutcome') {
      return deserialize<_imvh44pi.EnumOutcome>(data['data']);
    }
    if (dataClassName == 'EnumStatut') {
      return deserialize<_ip6diune.EnumStatut>(data['data']);
    }
    if (dataClassName == 'EnumType') {
      return deserialize<_ig2x4mxg.EnumType>(data['data']);
    }
    if (dataClassName == 'OfflineMatchResult') {
      return deserialize<_ir8nzxqr.OfflineMatchResult>(data['data']);
    }
    if (dataClassName == 'Partie') {
      return deserialize<_iuas6tq9.Partie>(data['data']);
    }
    if (dataClassName == 'Player') {
      return deserialize<_id5q07gg.Player>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'HistoryDto') {
      return deserialize<_inn2tdi6.HistoryDto>(data['data']);
    }
    if (dataClassName == 'LeaderboardEntryDto') {
      return deserialize<_i6lckwy9.LeaderboardEntryDto>(data['data']);
    }
    if (dataClassName == 'EnumProfileUpdateError') {
      return deserialize<_ib6s6ke7.EnumProfileUpdateError>(data['data']);
    }
    if (dataClassName == 'ProfileUpdateException') {
      return deserialize<_i1cvnna1.ProfileUpdateException>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_iytd8mlf.User>(data['data']);
    }
    if (dataClassName == 'UserProfileDto') {
      return deserialize<_ivqmpbel.UserProfileDto>(data['data']);
    }
    if (dataClassName == 'EloHistory') {
      return deserialize<_i8na2re5.EloHistory>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_offline_sync.')) {
      data['className'] = dataClassName.substring(23);
      return _izehhkf5.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iacs.Protocol().registerHostProtocol('puissance4', this);
    _iais.Protocol().registerHostProtocol('puissance4', this);
    _izehhkf5.Protocol().registerHostProtocol('puissance4', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _izehhkf5.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _iij7x2jd.Bot:
        return _iij7x2jd.Bot.t;
      case _ir8nzxqr.OfflineMatchResult:
        return _ir8nzxqr.OfflineMatchResult.t;
      case _iuas6tq9.Partie:
        return _iuas6tq9.Partie.t;
      case _id5q07gg.Player:
        return _id5q07gg.Player.t;
      case _iytd8mlf.User:
        return _iytd8mlf.User.t;
      case _i8na2re5.EloHistory:
        return _i8na2re5.EloHistory.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'puissance4';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _izehhkf5.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
