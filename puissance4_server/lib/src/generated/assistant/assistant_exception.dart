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
import '../assistant/enum_assistant_error.dart' as _i54e3bop;

abstract class AssistantException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  AssistantException._({
    required this.reason,
    this.message,
  });

  factory AssistantException({
    required _i54e3bop.EnumAssistantError reason,
    String? message,
  }) = _AssistantExceptionImpl;

  factory AssistantException.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssistantException(
      reason: _i54e3bop.EnumAssistantError.fromJson(
        (jsonSerialization['reason'] as String),
      ),
      message: jsonSerialization['message'] as String?,
    );
  }

  _i54e3bop.EnumAssistantError reason;

  String? message;

  /// Returns a shallow copy of this [AssistantException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AssistantException copyWith({
    _i54e3bop.EnumAssistantError? reason,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssistantException',
      'reason': reason.toJson(),
      if (message != null) 'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AssistantException',
      'reason': reason.toJson(),
      if (message != null) 'message': message,
    };
  }

  @override
  String toString() {
    return 'AssistantException(reason: $reason, message: $message)';
  }
}

class _Undefined {}

class _AssistantExceptionImpl extends AssistantException {
  _AssistantExceptionImpl({
    required _i54e3bop.EnumAssistantError reason,
    String? message,
  }) : super._(
         reason: reason,
         message: message,
       );

  /// Returns a shallow copy of this [AssistantException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AssistantException copyWith({
    _i54e3bop.EnumAssistantError? reason,
    Object? message = _Undefined,
  }) {
    return AssistantException(
      reason: reason ?? this.reason,
      message: message is String? ? message : this.message,
    );
  }
}
