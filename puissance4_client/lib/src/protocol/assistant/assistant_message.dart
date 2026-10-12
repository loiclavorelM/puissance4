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

abstract class AssistantMessage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AssistantMessage._({
    this.id,
    required this.conversationId,
    required this.position,
    required this.contentJson,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AssistantMessage({
    _isc.UuidValue? id,
    required _isc.UuidValue conversationId,
    required int position,
    required String contentJson,
    DateTime? createdAt,
  }) = _AssistantMessageImpl;

  factory AssistantMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssistantMessage(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      conversationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['conversationId'],
      ),
      position: jsonSerialization['position'] as int,
      contentJson: jsonSerialization['contentJson'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue conversationId;

  int position;

  String contentJson;

  DateTime createdAt;

  /// Returns a shallow copy of this [AssistantMessage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AssistantMessage copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? conversationId,
    int? position,
    String? contentJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssistantMessage',
      if (id != null) 'id': id?.toJson(),
      'conversationId': conversationId.toJson(),
      'position': position,
      'contentJson': contentJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AssistantMessage',
      if (id != null) 'id': id?.toJson(),
      'conversationId': conversationId.toJson(),
      'position': position,
      'contentJson': contentJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssistantMessageImpl extends AssistantMessage {
  _AssistantMessageImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue conversationId,
    required int position,
    required String contentJson,
    DateTime? createdAt,
  }) : super._(
         id: id,
         conversationId: conversationId,
         position: position,
         contentJson: contentJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AssistantMessage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AssistantMessage copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? conversationId,
    int? position,
    String? contentJson,
    DateTime? createdAt,
  }) {
    return AssistantMessage(
      id: id is _isc.UuidValue? ? id : this.id,
      conversationId: conversationId ?? this.conversationId,
      position: position ?? this.position,
      contentJson: contentJson ?? this.contentJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
