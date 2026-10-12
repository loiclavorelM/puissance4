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

abstract class AssistantToken
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AssistantToken._({
    this.id,
    required this.conversationId,
    required this.token,
    required this.kind,
    required this.ref,
  });

  factory AssistantToken({
    _isc.UuidValue? id,
    required _isc.UuidValue conversationId,
    required String token,
    required String kind,
    required String ref,
  }) = _AssistantTokenImpl;

  factory AssistantToken.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssistantToken(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      conversationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['conversationId'],
      ),
      token: jsonSerialization['token'] as String,
      kind: jsonSerialization['kind'] as String,
      ref: jsonSerialization['ref'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue conversationId;

  String token;

  String kind;

  String ref;

  /// Returns a shallow copy of this [AssistantToken]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AssistantToken copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? conversationId,
    String? token,
    String? kind,
    String? ref,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssistantToken',
      if (id != null) 'id': id?.toJson(),
      'conversationId': conversationId.toJson(),
      'token': token,
      'kind': kind,
      'ref': ref,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AssistantToken',
      if (id != null) 'id': id?.toJson(),
      'conversationId': conversationId.toJson(),
      'token': token,
      'kind': kind,
      'ref': ref,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssistantTokenImpl extends AssistantToken {
  _AssistantTokenImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue conversationId,
    required String token,
    required String kind,
    required String ref,
  }) : super._(
         id: id,
         conversationId: conversationId,
         token: token,
         kind: kind,
         ref: ref,
       );

  /// Returns a shallow copy of this [AssistantToken]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AssistantToken copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? conversationId,
    String? token,
    String? kind,
    String? ref,
  }) {
    return AssistantToken(
      id: id is _isc.UuidValue? ? id : this.id,
      conversationId: conversationId ?? this.conversationId,
      token: token ?? this.token,
      kind: kind ?? this.kind,
      ref: ref ?? this.ref,
    );
  }
}
