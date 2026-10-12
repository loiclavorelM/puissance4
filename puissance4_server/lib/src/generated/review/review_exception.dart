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
import '../review/enum_review_error.dart' as _if3tnwjp;

abstract class ReviewException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  ReviewException._({required this.reason});

  factory ReviewException({required _if3tnwjp.EnumReviewError reason}) =
      _ReviewExceptionImpl;

  factory ReviewException.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReviewException(
      reason: _if3tnwjp.EnumReviewError.fromJson(
        (jsonSerialization['reason'] as String),
      ),
    );
  }

  _if3tnwjp.EnumReviewError reason;

  /// Returns a shallow copy of this [ReviewException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ReviewException copyWith({_if3tnwjp.EnumReviewError? reason});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReviewException',
      'reason': reason.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ReviewException',
      'reason': reason.toJson(),
    };
  }

  @override
  String toString() {
    return 'ReviewException(reason: $reason)';
  }
}

class _ReviewExceptionImpl extends ReviewException {
  _ReviewExceptionImpl({required _if3tnwjp.EnumReviewError reason})
    : super._(reason: reason);

  /// Returns a shallow copy of this [ReviewException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ReviewException copyWith({_if3tnwjp.EnumReviewError? reason}) {
    return ReviewException(reason: reason ?? this.reason);
  }
}
