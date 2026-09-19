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
import 'bot/bot.dart' as _iij7x2jd;
import 'game/enum_player.dart' as _iugmtbin;
import 'game/enum_statut.dart' as _ip6diune;
import 'game/enum_type.dart' as _ig2x4mxg;
import 'game/partie.dart' as _iuas6tq9;
import 'game/player.dart' as _id5q07gg;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'profile/user.dart' as _iytd8mlf;
import 'ranked/elo_history.dart' as _i8na2re5;
export 'bot/bot.dart';
export 'game/enum_player.dart';
export 'game/enum_statut.dart';
export 'game/enum_type.dart';
export 'game/partie.dart';
export 'game/player.dart';
export 'greetings/greeting.dart';
export 'profile/user.dart';
export 'ranked/elo_history.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

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
    if (t == _iugmtbin.EnumPlayer) {
      return _iugmtbin.EnumPlayer.fromJson(data) as T;
    }
    if (t == _ip6diune.EnumStatut) {
      return _ip6diune.EnumStatut.fromJson(data) as T;
    }
    if (t == _ig2x4mxg.EnumType) {
      return _ig2x4mxg.EnumType.fromJson(data) as T;
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
    if (t == _i8na2re5.EloHistory) {
      return _i8na2re5.EloHistory.fromJson(data) as T;
    }
    if (t == _isc.getType<_iij7x2jd.Bot?>()) {
      return (data != null ? _iij7x2jd.Bot.fromJson(data) : null) as T;
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
    if (t == _isc.getType<_i8na2re5.EloHistory?>()) {
      return (data != null ? _i8na2re5.EloHistory.fromJson(data) : null) as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iij7x2jd.Bot => 'Bot',
      _iugmtbin.EnumPlayer => 'EnumPlayer',
      _ip6diune.EnumStatut => 'EnumStatut',
      _ig2x4mxg.EnumType => 'EnumType',
      _iuas6tq9.Partie => 'Partie',
      _id5q07gg.Player => 'Player',
      _izw8z7ou.Greeting => 'Greeting',
      _iytd8mlf.User => 'User',
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
      case _iugmtbin.EnumPlayer():
        return 'EnumPlayer';
      case _ip6diune.EnumStatut():
        return 'EnumStatut';
      case _ig2x4mxg.EnumType():
        return 'EnumType';
      case _iuas6tq9.Partie():
        return 'Partie';
      case _id5q07gg.Player():
        return 'Player';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _iytd8mlf.User():
        return 'User';
      case _i8na2re5.EloHistory():
        return 'EloHistory';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
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
    if (dataClassName == 'EnumPlayer') {
      return deserialize<_iugmtbin.EnumPlayer>(data['data']);
    }
    if (dataClassName == 'EnumStatut') {
      return deserialize<_ip6diune.EnumStatut>(data['data']);
    }
    if (dataClassName == 'EnumType') {
      return deserialize<_ig2x4mxg.EnumType>(data['data']);
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
    if (dataClassName == 'EloHistory') {
      return deserialize<_i8na2re5.EloHistory>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('puissance4', this);
    _iacc.Protocol().registerHostProtocol('puissance4', this);
  }

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
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
