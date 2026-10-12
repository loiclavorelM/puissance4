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
import '../assistant/enum_dashboard_author.dart' as _i94iawz8;

abstract class UserDashboardVersion
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  UserDashboardVersion._({
    this.id,
    required this.dashboardId,
    required this.version,
    required this.definitionJson,
    required this.author,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserDashboardVersion({
    _isc.UuidValue? id,
    required _isc.UuidValue dashboardId,
    required int version,
    required String definitionJson,
    required _i94iawz8.EnumDashboardAuthor author,
    DateTime? createdAt,
  }) = _UserDashboardVersionImpl;

  factory UserDashboardVersion.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return UserDashboardVersion(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      dashboardId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['dashboardId'],
      ),
      version: jsonSerialization['version'] as int,
      definitionJson: jsonSerialization['definitionJson'] as String,
      author: _i94iawz8.EnumDashboardAuthor.fromJson(
        (jsonSerialization['author'] as String),
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue dashboardId;

  int version;

  String definitionJson;

  _i94iawz8.EnumDashboardAuthor author;

  DateTime createdAt;

  /// Returns a shallow copy of this [UserDashboardVersion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UserDashboardVersion copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? dashboardId,
    int? version,
    String? definitionJson,
    _i94iawz8.EnumDashboardAuthor? author,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserDashboardVersion',
      if (id != null) 'id': id?.toJson(),
      'dashboardId': dashboardId.toJson(),
      'version': version,
      'definitionJson': definitionJson,
      'author': author.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserDashboardVersion',
      if (id != null) 'id': id?.toJson(),
      'dashboardId': dashboardId.toJson(),
      'version': version,
      'definitionJson': definitionJson,
      'author': author.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserDashboardVersionImpl extends UserDashboardVersion {
  _UserDashboardVersionImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue dashboardId,
    required int version,
    required String definitionJson,
    required _i94iawz8.EnumDashboardAuthor author,
    DateTime? createdAt,
  }) : super._(
         id: id,
         dashboardId: dashboardId,
         version: version,
         definitionJson: definitionJson,
         author: author,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [UserDashboardVersion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UserDashboardVersion copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? dashboardId,
    int? version,
    String? definitionJson,
    _i94iawz8.EnumDashboardAuthor? author,
    DateTime? createdAt,
  }) {
    return UserDashboardVersion(
      id: id is _isc.UuidValue? ? id : this.id,
      dashboardId: dashboardId ?? this.dashboardId,
      version: version ?? this.version,
      definitionJson: definitionJson ?? this.definitionJson,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
