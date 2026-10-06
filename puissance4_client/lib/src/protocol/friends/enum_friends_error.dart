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

enum EnumFriendsError implements _isc.SerializableModel {
  guestNotAllowed,
  userNotFound,
  cannotAddSelf,
  alreadyFriends,
  requestAlreadySent,
  requestNotFound,
  notFriends,
  tooManyFriends,
  challengeNotFound;

  static EnumFriendsError fromJson(String name) {
    switch (name) {
      case 'guestNotAllowed':
        return EnumFriendsError.guestNotAllowed;
      case 'userNotFound':
        return EnumFriendsError.userNotFound;
      case 'cannotAddSelf':
        return EnumFriendsError.cannotAddSelf;
      case 'alreadyFriends':
        return EnumFriendsError.alreadyFriends;
      case 'requestAlreadySent':
        return EnumFriendsError.requestAlreadySent;
      case 'requestNotFound':
        return EnumFriendsError.requestNotFound;
      case 'notFriends':
        return EnumFriendsError.notFriends;
      case 'tooManyFriends':
        return EnumFriendsError.tooManyFriends;
      case 'challengeNotFound':
        return EnumFriendsError.challengeNotFound;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "EnumFriendsError"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
