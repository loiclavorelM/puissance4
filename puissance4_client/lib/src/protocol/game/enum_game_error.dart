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

enum EnumGameError implements _isc.SerializableModel {
  userNotFound,
  roomNotFound,
  ownRoom,
  alreadyInGame,
  gameNotFound,
  notAPlayer,
  gameOver,
  notYourTurn,
  invalidMove,
  noBotAvailable,
  friendUnavailable;

  static EnumGameError fromJson(String name) {
    switch (name) {
      case 'userNotFound':
        return EnumGameError.userNotFound;
      case 'roomNotFound':
        return EnumGameError.roomNotFound;
      case 'ownRoom':
        return EnumGameError.ownRoom;
      case 'alreadyInGame':
        return EnumGameError.alreadyInGame;
      case 'gameNotFound':
        return EnumGameError.gameNotFound;
      case 'notAPlayer':
        return EnumGameError.notAPlayer;
      case 'gameOver':
        return EnumGameError.gameOver;
      case 'notYourTurn':
        return EnumGameError.notYourTurn;
      case 'invalidMove':
        return EnumGameError.invalidMove;
      case 'noBotAvailable':
        return EnumGameError.noBotAvailable;
      case 'friendUnavailable':
        return EnumGameError.friendUnavailable;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "EnumGameError"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
