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

abstract class AssistantConversation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AssistantConversation._({
    this.id,
    required this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory AssistantConversation({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AssistantConversationImpl;

  factory AssistantConversation.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AssistantConversation(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue userId;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [AssistantConversation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AssistantConversation copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssistantConversation',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AssistantConversation',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssistantConversationImpl extends AssistantConversation {
  _AssistantConversationImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AssistantConversation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AssistantConversation copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssistantConversation(
      id: id is _isc.UuidValue? ? id : this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
