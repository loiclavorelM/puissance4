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

abstract class AssistantRequestLog
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AssistantRequestLog._({
    this.id,
    required this.userId,
    this.conversationId,
    required this.model,
    required this.inputTokens,
    required this.outputTokens,
    required this.toolsJson,
    required this.turns,
    required this.durationMs,
    this.errorCode,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AssistantRequestLog({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    _isc.UuidValue? conversationId,
    required String model,
    required int inputTokens,
    required int outputTokens,
    required String toolsJson,
    required int turns,
    required int durationMs,
    String? errorCode,
    DateTime? createdAt,
  }) = _AssistantRequestLogImpl;

  factory AssistantRequestLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssistantRequestLog(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      conversationId: jsonSerialization['conversationId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['conversationId'],
            ),
      model: jsonSerialization['model'] as String,
      inputTokens: jsonSerialization['inputTokens'] as int,
      outputTokens: jsonSerialization['outputTokens'] as int,
      toolsJson: jsonSerialization['toolsJson'] as String,
      turns: jsonSerialization['turns'] as int,
      durationMs: jsonSerialization['durationMs'] as int,
      errorCode: jsonSerialization['errorCode'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue userId;

  _isc.UuidValue? conversationId;

  String model;

  int inputTokens;

  int outputTokens;

  String toolsJson;

  int turns;

  int durationMs;

  String? errorCode;

  DateTime createdAt;

  /// Returns a shallow copy of this [AssistantRequestLog]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AssistantRequestLog copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? userId,
    _isc.UuidValue? conversationId,
    String? model,
    int? inputTokens,
    int? outputTokens,
    String? toolsJson,
    int? turns,
    int? durationMs,
    String? errorCode,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssistantRequestLog',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      if (conversationId != null) 'conversationId': conversationId?.toJson(),
      'model': model,
      'inputTokens': inputTokens,
      'outputTokens': outputTokens,
      'toolsJson': toolsJson,
      'turns': turns,
      'durationMs': durationMs,
      if (errorCode != null) 'errorCode': errorCode,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AssistantRequestLog',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      if (conversationId != null) 'conversationId': conversationId?.toJson(),
      'model': model,
      'inputTokens': inputTokens,
      'outputTokens': outputTokens,
      'toolsJson': toolsJson,
      'turns': turns,
      'durationMs': durationMs,
      if (errorCode != null) 'errorCode': errorCode,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssistantRequestLogImpl extends AssistantRequestLog {
  _AssistantRequestLogImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    _isc.UuidValue? conversationId,
    required String model,
    required int inputTokens,
    required int outputTokens,
    required String toolsJson,
    required int turns,
    required int durationMs,
    String? errorCode,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         conversationId: conversationId,
         model: model,
         inputTokens: inputTokens,
         outputTokens: outputTokens,
         toolsJson: toolsJson,
         turns: turns,
         durationMs: durationMs,
         errorCode: errorCode,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AssistantRequestLog]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AssistantRequestLog copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? userId,
    Object? conversationId = _Undefined,
    String? model,
    int? inputTokens,
    int? outputTokens,
    String? toolsJson,
    int? turns,
    int? durationMs,
    Object? errorCode = _Undefined,
    DateTime? createdAt,
  }) {
    return AssistantRequestLog(
      id: id is _isc.UuidValue? ? id : this.id,
      userId: userId ?? this.userId,
      conversationId: conversationId is _isc.UuidValue?
          ? conversationId
          : this.conversationId,
      model: model ?? this.model,
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      toolsJson: toolsJson ?? this.toolsJson,
      turns: turns ?? this.turns,
      durationMs: durationMs ?? this.durationMs,
      errorCode: errorCode is String? ? errorCode : this.errorCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
