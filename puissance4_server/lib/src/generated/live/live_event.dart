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
import '../live/enum_live_event_type.dart' as _iamggups;

abstract class LiveEvent
    implements _is.SerializableModel, _is.ProtocolSerialization {
  LiveEvent._({required this.type});

  factory LiveEvent({required _iamggups.EnumLiveEventType type}) =
      _LiveEventImpl;

  factory LiveEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return LiveEvent(
      type: _iamggups.EnumLiveEventType.fromJson(
        (jsonSerialization['type'] as String),
      ),
    );
  }

  _iamggups.EnumLiveEventType type;

  /// Returns a shallow copy of this [LiveEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LiveEvent copyWith({_iamggups.EnumLiveEventType? type});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LiveEvent',
      'type': type.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LiveEvent',
      'type': type.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _LiveEventImpl extends LiveEvent {
  _LiveEventImpl({required _iamggups.EnumLiveEventType type})
    : super._(type: type);

  /// Returns a shallow copy of this [LiveEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LiveEvent copyWith({_iamggups.EnumLiveEventType? type}) {
    return LiveEvent(type: type ?? this.type);
  }
}
