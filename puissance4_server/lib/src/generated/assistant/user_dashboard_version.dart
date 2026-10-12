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
import '../assistant/enum_dashboard_author.dart' as _i94iawz8;

abstract class UserDashboardVersion
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  UserDashboardVersion._({
    this.id,
    required this.dashboardId,
    required this.version,
    required this.definitionJson,
    required this.author,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserDashboardVersion({
    _is.UuidValue? id,
    required _is.UuidValue dashboardId,
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
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      dashboardId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['dashboardId'],
      ),
      version: jsonSerialization['version'] as int,
      definitionJson: jsonSerialization['definitionJson'] as String,
      author: _i94iawz8.EnumDashboardAuthor.fromJson(
        (jsonSerialization['author'] as String),
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = UserDashboardVersionTable();

  static const db = UserDashboardVersionRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue dashboardId;

  int version;

  String definitionJson;

  _i94iawz8.EnumDashboardAuthor author;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [UserDashboardVersion]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  UserDashboardVersion copyWith({
    _is.UuidValue? id,
    _is.UuidValue? dashboardId,
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

  static UserDashboardVersionInclude include() {
    return UserDashboardVersionInclude._();
  }

  static UserDashboardVersionIncludeList includeList({
    _is.WhereExpressionBuilder<UserDashboardVersionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserDashboardVersionTable>? orderBy,
    _is.OrderByListBuilder<UserDashboardVersionTable>? orderByList,
    UserDashboardVersionInclude? include,
  }) {
    return UserDashboardVersionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserDashboardVersion.t),
      orderByList: orderByList?.call(UserDashboardVersion.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserDashboardVersionImpl extends UserDashboardVersion {
  _UserDashboardVersionImpl({
    _is.UuidValue? id,
    required _is.UuidValue dashboardId,
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
  @_is.useResult
  @override
  UserDashboardVersion copyWith({
    Object? id = _Undefined,
    _is.UuidValue? dashboardId,
    int? version,
    String? definitionJson,
    _i94iawz8.EnumDashboardAuthor? author,
    DateTime? createdAt,
  }) {
    return UserDashboardVersion(
      id: id is _is.UuidValue? ? id : this.id,
      dashboardId: dashboardId ?? this.dashboardId,
      version: version ?? this.version,
      definitionJson: definitionJson ?? this.definitionJson,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserDashboardVersionUpdateTable
    extends _is.UpdateTable<UserDashboardVersionTable> {
  UserDashboardVersionUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> dashboardId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.dashboardId,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );

  _is.ColumnValue<String, String> definitionJson(String value) =>
      _is.ColumnValue(
        table.definitionJson,
        value,
      );

  _is.ColumnValue<_i94iawz8.EnumDashboardAuthor, _i94iawz8.EnumDashboardAuthor>
  author(_i94iawz8.EnumDashboardAuthor value) => _is.ColumnValue(
    table.author,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class UserDashboardVersionTable extends _is.Table<_is.UuidValue?> {
  UserDashboardVersionTable({super.tableRelation})
    : super(tableName: 'user_dashboard_version') {
    updateTable = UserDashboardVersionUpdateTable(this);
    dashboardId = _is.ColumnUuid(
      'dashboardId',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
    definitionJson = _is.ColumnString(
      'definitionJson',
      this,
    );
    author = _is.ColumnEnum(
      'author',
      this,
      _is.EnumSerialization.byName,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final UserDashboardVersionUpdateTable updateTable;

  late final _is.ColumnUuid dashboardId;

  late final _is.ColumnInt version;

  late final _is.ColumnString definitionJson;

  late final _is.ColumnEnum<_i94iawz8.EnumDashboardAuthor> author;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    dashboardId,
    version,
    definitionJson,
    author,
    createdAt,
  ];
}

class UserDashboardVersionInclude extends _is.IncludeObject {
  UserDashboardVersionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => UserDashboardVersion.t;
}

class UserDashboardVersionIncludeList extends _is.IncludeList {
  UserDashboardVersionIncludeList._({
    _is.WhereExpressionBuilder<UserDashboardVersionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserDashboardVersion.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => UserDashboardVersion.t;
}

class UserDashboardVersionRepository {
  const UserDashboardVersionRepository._();

  /// Returns a list of [UserDashboardVersion]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<UserDashboardVersion>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserDashboardVersionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserDashboardVersionTable>? orderBy,
    _is.OrderByListBuilder<UserDashboardVersionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UserDashboardVersion>(
      where: where?.call(UserDashboardVersion.t),
      orderBy: orderBy?.call(UserDashboardVersion.t),
      orderByList: orderByList?.call(UserDashboardVersion.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [UserDashboardVersion] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<UserDashboardVersion?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserDashboardVersionTable>? where,
    int? offset,
    _is.OrderByBuilder<UserDashboardVersionTable>? orderBy,
    _is.OrderByListBuilder<UserDashboardVersionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UserDashboardVersion>(
      where: where?.call(UserDashboardVersion.t),
      orderBy: orderBy?.call(UserDashboardVersion.t),
      orderByList: orderByList?.call(UserDashboardVersion.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UserDashboardVersion] by its [id] or null if no such row exists.
  Future<UserDashboardVersion?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UserDashboardVersion>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UserDashboardVersion]s in the list and returns the inserted rows.
  ///
  /// The returned [UserDashboardVersion]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserDashboardVersion>> insert(
    _is.DatabaseSession session,
    List<UserDashboardVersion> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<UserDashboardVersion>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [UserDashboardVersion] and returns the inserted row.
  ///
  /// The returned [UserDashboardVersion] will have its `id` field set.
  Future<UserDashboardVersion> insertRow(
    _is.DatabaseSession session,
    UserDashboardVersion row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserDashboardVersion>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [UserDashboardVersion]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [UserDashboardVersion]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserDashboardVersion>> upsert(
    _is.DatabaseSession session,
    List<UserDashboardVersion> rows, {
    required _is.ColumnSelections<UserDashboardVersionTable> conflictColumns,
    _is.ColumnSelections<UserDashboardVersionTable>? updateColumns,
    _is.WhereExpressionBuilder<UserDashboardVersionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<UserDashboardVersion>(
      rows,
      conflictColumns: conflictColumns(UserDashboardVersion.t),
      updateColumns: updateColumns?.call(UserDashboardVersion.t),
      updateWhere: updateWhere?.call(UserDashboardVersion.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [UserDashboardVersion] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [UserDashboardVersion] will have its `id` field set.
  Future<UserDashboardVersion?> upsertRow(
    _is.DatabaseSession session,
    UserDashboardVersion row, {
    required _is.ColumnSelections<UserDashboardVersionTable> conflictColumns,
    _is.ColumnSelections<UserDashboardVersionTable>? updateColumns,
    _is.WhereExpressionBuilder<UserDashboardVersionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<UserDashboardVersion>(
      row,
      conflictColumns: conflictColumns(UserDashboardVersion.t),
      updateColumns: updateColumns?.call(UserDashboardVersion.t),
      updateWhere: updateWhere?.call(UserDashboardVersion.t),
      transaction: transaction,
    );
  }

  /// Updates all [UserDashboardVersion]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserDashboardVersion>> update(
    _is.DatabaseSession session,
    List<UserDashboardVersion> rows, {
    _is.ColumnSelections<UserDashboardVersionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<UserDashboardVersion>(
      rows,
      columns: columns?.call(UserDashboardVersion.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [UserDashboardVersion]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserDashboardVersion> updateRow(
    _is.DatabaseSession session,
    UserDashboardVersion row, {
    _is.ColumnSelections<UserDashboardVersionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserDashboardVersion>(
      row,
      columns: columns?.call(UserDashboardVersion.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserDashboardVersion] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserDashboardVersion?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<UserDashboardVersionUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<UserDashboardVersion>(
      id,
      columnValues: columnValues(UserDashboardVersion.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserDashboardVersion]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserDashboardVersion>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<UserDashboardVersionUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<UserDashboardVersionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserDashboardVersionTable>? orderBy,
    _is.OrderByListBuilder<UserDashboardVersionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<UserDashboardVersion>(
      columnValues: columnValues(UserDashboardVersion.t.updateTable),
      where: where(UserDashboardVersion.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserDashboardVersion.t),
      orderByList: orderByList?.call(UserDashboardVersion.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [UserDashboardVersion]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserDashboardVersion>> delete(
    _is.DatabaseSession session,
    List<UserDashboardVersion> rows, {
    _is.OrderByBuilder<UserDashboardVersionTable>? orderBy,
    _is.OrderByListBuilder<UserDashboardVersionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<UserDashboardVersion>(
      rows,
      orderBy: orderBy?.call(UserDashboardVersion.t),
      orderByList: orderByList?.call(UserDashboardVersion.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [UserDashboardVersion].
  Future<UserDashboardVersion> deleteRow(
    _is.DatabaseSession session,
    UserDashboardVersion row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserDashboardVersion>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserDashboardVersion>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserDashboardVersionTable> where,
    _is.OrderByBuilder<UserDashboardVersionTable>? orderBy,
    _is.OrderByListBuilder<UserDashboardVersionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<UserDashboardVersion>(
      where: where(UserDashboardVersion.t),
      orderBy: orderBy?.call(UserDashboardVersion.t),
      orderByList: orderByList?.call(UserDashboardVersion.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserDashboardVersionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<UserDashboardVersion>(
      where: where?.call(UserDashboardVersion.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UserDashboardVersion] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserDashboardVersionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UserDashboardVersion>(
      where: where(UserDashboardVersion.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
