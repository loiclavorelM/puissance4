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
import '../profile/enum_profile_update_error.dart' as _i6z5h8zt;

abstract class ProfileUpdateException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  ProfileUpdateException._({required this.reason});

  factory ProfileUpdateException({
    required _i6z5h8zt.EnumProfileUpdateError reason,
  }) = _ProfileUpdateExceptionImpl;

  factory ProfileUpdateException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ProfileUpdateException(
      reason: _i6z5h8zt.EnumProfileUpdateError.fromJson(
        (jsonSerialization['reason'] as String),
      ),
    );
  }

  _i6z5h8zt.EnumProfileUpdateError reason;

  /// Returns a shallow copy of this [ProfileUpdateException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ProfileUpdateException copyWith({_i6z5h8zt.EnumProfileUpdateError? reason});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProfileUpdateException',
      'reason': reason.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProfileUpdateException',
      'reason': reason.toJson(),
    };
  }

  @override
  String toString() {
    return 'ProfileUpdateException(reason: $reason)';
  }
}

class _ProfileUpdateExceptionImpl extends ProfileUpdateException {
  _ProfileUpdateExceptionImpl({
    required _i6z5h8zt.EnumProfileUpdateError reason,
  }) : super._(reason: reason);

  /// Returns a shallow copy of this [ProfileUpdateException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ProfileUpdateException copyWith({_i6z5h8zt.EnumProfileUpdateError? reason}) {
    return ProfileUpdateException(reason: reason ?? this.reason);
  }
}
