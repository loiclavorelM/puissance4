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
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_database/serverpod_database.dart' as _isd;
import 'package:serverpod_offline_sync_client/serverpod_offline_sync_client.dart'
    as _ipulbpi2;
import 'bot/bot.dart' as _iij7x2jd;
import 'bot/enum_bot_level.dart' as _i65o1ott;
import 'game/enum_match_result.dart' as _iyr3fkva;
import 'game/enum_player.dart' as _iugmtbin;
import 'game/enum_statut.dart' as _ip6diune;
import 'game/enum_type.dart' as _ig2x4mxg;
import 'game/offline_match_result.dart' as _ir8nzxqr;
import 'game/partie.dart' as _iuas6tq9;
import 'game/player.dart' as _id5q07gg;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'profile/user.dart' as _iytd8mlf;
import 'profile/user_profile_dto.dart' as _ivqmpbel;
import 'ranked/elo_history.dart' as _i8na2re5;
export 'bot/bot.dart';
export 'bot/enum_bot_level.dart';
export 'game/enum_match_result.dart';
export 'game/enum_player.dart';
export 'game/enum_statut.dart';
export 'game/enum_type.dart';
export 'game/offline_match_result.dart';
export 'game/partie.dart';
export 'game/player.dart';
export 'greetings/greeting.dart';
export 'profile/user.dart';
export 'profile/user_profile_dto.dart';
export 'ranked/elo_history.dart';
export 'client.dart';
export 'sync_tables.dart';

class Protocol extends _isd.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isd.TableDefinition> get targetTableDefinitions => [
    _isd.TableDefinition(
      name: 'offline_match_result',
      dartName: 'OfflineMatchResult',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isd.ColumnDefinition(
          name: 'id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isd.ColumnDefinition(
          name: 'spaceId',
          columnType: _isd.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isd.ColumnDefinition(
          name: 'result',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EnumMatchResult',
        ),
        _isd.ColumnDefinition(
          name: 'botLevel',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EnumBotLevel',
        ),
        _isd.ColumnDefinition(
          name: 'moves',
          columnType: _isd.ColumnType.json,
          isNullable: false,
          dartType: 'List<int>',
        ),
        _isd.ColumnDefinition(
          name: 'playedAt',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isd.ColumnDefinition(
          name: 'reconciled',
          columnType: _isd.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
      ],
      foreignKeys: [
        _isd.ForeignKeyDefinition(
          constraintName: 'offline_match_result_fk_0',
          columns: ['spaceId'],
          referenceTable: 'offline_sync_spaces',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    ..._iacc.Protocol() is _isd.DatabaseSerializationManager
        ? (_iacc.Protocol() as _isd.DatabaseSerializationManager)
              .getTargetTableDefinitions()
        : [],
    ..._iaic.Protocol() is _isd.DatabaseSerializationManager
        ? (_iaic.Protocol() as _isd.DatabaseSerializationManager)
              .getTargetTableDefinitions()
        : [],
    ..._ipulbpi2.Protocol() is _isd.DatabaseSerializationManager
        ? (_ipulbpi2.Protocol() as _isd.DatabaseSerializationManager)
              .getTargetTableDefinitions()
        : [],
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
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
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
    if (t == _iyr3fkva.EnumMatchResult) {
      return _iyr3fkva.EnumMatchResult.fromJson(data) as T;
    }
    if (t == _iugmtbin.EnumPlayer) {
      return _iugmtbin.EnumPlayer.fromJson(data) as T;
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
    if (t == _iytd8mlf.User) {
      return _iytd8mlf.User.fromJson(data) as T;
    }
    if (t == _ivqmpbel.UserProfileDto) {
      return _ivqmpbel.UserProfileDto.fromJson(data) as T;
    }
    if (t == _i8na2re5.EloHistory) {
      return _i8na2re5.EloHistory.fromJson(data) as T;
    }
    if (t == _isc.getType<_iij7x2jd.Bot?>()) {
      return (data != null ? _iij7x2jd.Bot.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i65o1ott.EnumBotLevel?>()) {
      return (data != null ? _i65o1ott.EnumBotLevel.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iyr3fkva.EnumMatchResult?>()) {
      return (data != null ? _iyr3fkva.EnumMatchResult.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iugmtbin.EnumPlayer?>()) {
      return (data != null ? _iugmtbin.EnumPlayer.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ip6diune.EnumStatut?>()) {
      return (data != null ? _ip6diune.EnumStatut.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ig2x4mxg.EnumType?>()) {
      return (data != null ? _ig2x4mxg.EnumType.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ir8nzxqr.OfflineMatchResult?>()) {
      return (data != null ? _ir8nzxqr.OfflineMatchResult.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iuas6tq9.Partie?>()) {
      return (data != null ? _iuas6tq9.Partie.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_id5q07gg.Player?>()) {
      return (data != null ? _id5q07gg.Player.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iytd8mlf.User?>()) {
      return (data != null ? _iytd8mlf.User.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ivqmpbel.UserProfileDto?>()) {
      return (data != null ? _ivqmpbel.UserProfileDto.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i8na2re5.EloHistory?>()) {
      return (data != null ? _i8na2re5.EloHistory.fromJson(data) : null) as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _ipulbpi2.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iij7x2jd.Bot => 'Bot',
      _i65o1ott.EnumBotLevel => 'EnumBotLevel',
      _iyr3fkva.EnumMatchResult => 'EnumMatchResult',
      _iugmtbin.EnumPlayer => 'EnumPlayer',
      _ip6diune.EnumStatut => 'EnumStatut',
      _ig2x4mxg.EnumType => 'EnumType',
      _ir8nzxqr.OfflineMatchResult => 'OfflineMatchResult',
      _iuas6tq9.Partie => 'Partie',
      _id5q07gg.Player => 'Player',
      _izw8z7ou.Greeting => 'Greeting',
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
      case _iyr3fkva.EnumMatchResult():
        return 'EnumMatchResult';
      case _iugmtbin.EnumPlayer():
        return 'EnumPlayer';
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
      case _iytd8mlf.User():
        return 'User';
      case _ivqmpbel.UserProfileDto():
        return 'UserProfileDto';
      case _i8na2re5.EloHistory():
        return 'EloHistory';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _ipulbpi2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_offline_sync.$className';
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
    if (dataClassName == 'EnumMatchResult') {
      return deserialize<_iyr3fkva.EnumMatchResult>(data['data']);
    }
    if (dataClassName == 'EnumPlayer') {
      return deserialize<_iugmtbin.EnumPlayer>(data['data']);
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
      return _iacc.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_offline_sync.')) {
      data['className'] = dataClassName.substring(23);
      return _ipulbpi2.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iacc.Protocol().registerHostProtocol('puissance4', this);
    _iaic.Protocol().registerHostProtocol('puissance4', this);
    _ipulbpi2.Protocol().registerHostProtocol('puissance4', this);
  }

  @override
  _isd.Table? getTableForType(Type t) {
    {
      var protocol = _iacc.Protocol();
      var table = protocol is _isd.DatabaseSerializationManager
          ? (protocol as _isd.DatabaseSerializationManager).getTableForType(t)
          : null;
      if (table != null) {
        return table;
      }
    }
    {
      var protocol = _iaic.Protocol();
      var table = protocol is _isd.DatabaseSerializationManager
          ? (protocol as _isd.DatabaseSerializationManager).getTableForType(t)
          : null;
      if (table != null) {
        return table;
      }
    }
    {
      var protocol = _ipulbpi2.Protocol();
      var table = protocol is _isd.DatabaseSerializationManager
          ? (protocol as _isd.DatabaseSerializationManager).getTableForType(t)
          : null;
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _ir8nzxqr.OfflineMatchResult:
        return _ir8nzxqr.OfflineMatchResult.t;
    }
    return null;
  }

  @override
  List<_isd.TableDefinition> getTargetTableDefinitions() =>
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
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _ipulbpi2.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
