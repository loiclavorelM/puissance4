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

enum EnumGameEndReason implements _isc.SerializableModel {
  connectFour,
  boardFull,
  forfeit,
  disconnect,
  timeout,
  cancelled;

  static EnumGameEndReason fromJson(String name) {
    switch (name) {
      case 'connectFour':
        return EnumGameEndReason.connectFour;
      case 'boardFull':
        return EnumGameEndReason.boardFull;
      case 'forfeit':
        return EnumGameEndReason.forfeit;
      case 'disconnect':
        return EnumGameEndReason.disconnect;
      case 'timeout':
        return EnumGameEndReason.timeout;
      case 'cancelled':
        return EnumGameEndReason.cancelled;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "EnumGameEndReason"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
