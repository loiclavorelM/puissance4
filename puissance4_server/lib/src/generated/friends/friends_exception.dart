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
import '../friends/enum_friends_error.dart' as _ir66pb6p;

abstract class FriendsException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  FriendsException._({required this.reason});

  factory FriendsException({required _ir66pb6p.EnumFriendsError reason}) =
      _FriendsExceptionImpl;

  factory FriendsException.fromJson(Map<String, dynamic> jsonSerialization) {
    return FriendsException(
      reason: _ir66pb6p.EnumFriendsError.fromJson(
        (jsonSerialization['reason'] as String),
      ),
    );
  }

  _ir66pb6p.EnumFriendsError reason;

  /// Returns a shallow copy of this [FriendsException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FriendsException copyWith({_ir66pb6p.EnumFriendsError? reason});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FriendsException',
      'reason': reason.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FriendsException',
      'reason': reason.toJson(),
    };
  }

  @override
  String toString() {
    return 'FriendsException(reason: $reason)';
  }
}

class _FriendsExceptionImpl extends FriendsException {
  _FriendsExceptionImpl({required _ir66pb6p.EnumFriendsError reason})
    : super._(reason: reason);

  /// Returns a shallow copy of this [FriendsException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FriendsException copyWith({_ir66pb6p.EnumFriendsError? reason}) {
    return FriendsException(reason: reason ?? this.reason);
  }
}
