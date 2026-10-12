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

abstract class UserDashboard
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  UserDashboard._({
    this.id,
    required this.userId,
    required this.version,
    required this.definitionJson,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory UserDashboard({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required int version,
    required String definitionJson,
    DateTime? updatedAt,
  }) = _UserDashboardImpl;

  factory UserDashboard.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserDashboard(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      version: jsonSerialization['version'] as int,
      definitionJson: jsonSerialization['definitionJson'] as String,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = UserDashboardTable();

  static const db = UserDashboardRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue userId;

  int version;

  String definitionJson;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [UserDashboard]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  UserDashboard copyWith({
    _is.UuidValue? id,
    _is.UuidValue? userId,
    int? version,
    String? definitionJson,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserDashboard',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'version': version,
      'definitionJson': definitionJson,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserDashboard',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'version': version,
      'definitionJson': definitionJson,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static UserDashboardInclude include() {
    return UserDashboardInclude._();
  }

  static UserDashboardIncludeList includeList({
    _is.WhereExpressionBuilder<UserDashboardTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserDashboardTable>? orderBy,
    _is.OrderByListBuilder<UserDashboardTable>? orderByList,
    UserDashboardInclude? include,
  }) {
    return UserDashboardIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserDashboard.t),
      orderByList: orderByList?.call(UserDashboard.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserDashboardImpl extends UserDashboard {
  _UserDashboardImpl({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required int version,
    required String definitionJson,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         version: version,
         definitionJson: definitionJson,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [UserDashboard]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  UserDashboard copyWith({
    Object? id = _Undefined,
    _is.UuidValue? userId,
    int? version,
    String? definitionJson,
    DateTime? updatedAt,
  }) {
    return UserDashboard(
      id: id is _is.UuidValue? ? id : this.id,
      userId: userId ?? this.userId,
      version: version ?? this.version,
      definitionJson: definitionJson ?? this.definitionJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserDashboardUpdateTable extends _is.UpdateTable<UserDashboardTable> {
  UserDashboardUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.userId,
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

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class UserDashboardTable extends _is.Table<_is.UuidValue?> {
  UserDashboardTable({super.tableRelation})
    : super(tableName: 'user_dashboard') {
    updateTable = UserDashboardUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
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
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final UserDashboardUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  late final _is.ColumnInt version;

  late final _is.ColumnString definitionJson;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    version,
    definitionJson,
    updatedAt,
  ];
}

class UserDashboardInclude extends _is.IncludeObject {
  UserDashboardInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => UserDashboard.t;
}

class UserDashboardIncludeList extends _is.IncludeList {
  UserDashboardIncludeList._({
    _is.WhereExpressionBuilder<UserDashboardTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserDashboard.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => UserDashboard.t;
}

class UserDashboardRepository {
  const UserDashboardRepository._();

  /// Returns a list of [UserDashboard]s matching the given query parameters.
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
  Future<List<UserDashboard>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserDashboardTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserDashboardTable>? orderBy,
    _is.OrderByListBuilder<UserDashboardTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UserDashboard>(
      where: where?.call(UserDashboard.t),
      orderBy: orderBy?.call(UserDashboard.t),
      orderByList: orderByList?.call(UserDashboard.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [UserDashboard] matching the given query parameters.
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
  Future<UserDashboard?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserDashboardTable>? where,
    int? offset,
    _is.OrderByBuilder<UserDashboardTable>? orderBy,
    _is.OrderByListBuilder<UserDashboardTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UserDashboard>(
      where: where?.call(UserDashboard.t),
      orderBy: orderBy?.call(UserDashboard.t),
      orderByList: orderByList?.call(UserDashboard.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UserDashboard] by its [id] or null if no such row exists.
  Future<UserDashboard?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UserDashboard>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UserDashboard]s in the list and returns the inserted rows.
  ///
  /// The returned [UserDashboard]s will have their `id` fields set.
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
  Future<List<UserDashboard>> insert(
    _is.DatabaseSession session,
    List<UserDashboard> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<UserDashboard>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [UserDashboard] and returns the inserted row.
  ///
  /// The returned [UserDashboard] will have its `id` field set.
  Future<UserDashboard> insertRow(
    _is.DatabaseSession session,
    UserDashboard row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserDashboard>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [UserDashboard]s in the list and returns the resulting rows.
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
  /// The returned [UserDashboard]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserDashboard>> upsert(
    _is.DatabaseSession session,
    List<UserDashboard> rows, {
    required _is.ColumnSelections<UserDashboardTable> conflictColumns,
    _is.ColumnSelections<UserDashboardTable>? updateColumns,
    _is.WhereExpressionBuilder<UserDashboardTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<UserDashboard>(
      rows,
      conflictColumns: conflictColumns(UserDashboard.t),
      updateColumns: updateColumns?.call(UserDashboard.t),
      updateWhere: updateWhere?.call(UserDashboard.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [UserDashboard] and returns the resulting row.
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
  /// The returned [UserDashboard] will have its `id` field set.
  Future<UserDashboard?> upsertRow(
    _is.DatabaseSession session,
    UserDashboard row, {
    required _is.ColumnSelections<UserDashboardTable> conflictColumns,
    _is.ColumnSelections<UserDashboardTable>? updateColumns,
    _is.WhereExpressionBuilder<UserDashboardTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<UserDashboard>(
      row,
      conflictColumns: conflictColumns(UserDashboard.t),
      updateColumns: updateColumns?.call(UserDashboard.t),
      updateWhere: updateWhere?.call(UserDashboard.t),
      transaction: transaction,
    );
  }

  /// Updates all [UserDashboard]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserDashboard>> update(
    _is.DatabaseSession session,
    List<UserDashboard> rows, {
    _is.ColumnSelections<UserDashboardTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<UserDashboard>(
      rows,
      columns: columns?.call(UserDashboard.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [UserDashboard]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserDashboard> updateRow(
    _is.DatabaseSession session,
    UserDashboard row, {
    _is.ColumnSelections<UserDashboardTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserDashboard>(
      row,
      columns: columns?.call(UserDashboard.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserDashboard] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserDashboard?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<UserDashboardUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<UserDashboard>(
      id,
      columnValues: columnValues(UserDashboard.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserDashboard]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserDashboard>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<UserDashboardUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<UserDashboardTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserDashboardTable>? orderBy,
    _is.OrderByListBuilder<UserDashboardTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<UserDashboard>(
      columnValues: columnValues(UserDashboard.t.updateTable),
      where: where(UserDashboard.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserDashboard.t),
      orderByList: orderByList?.call(UserDashboard.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [UserDashboard]s in the list and returns the deleted rows.
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
  Future<List<UserDashboard>> delete(
    _is.DatabaseSession session,
    List<UserDashboard> rows, {
    _is.OrderByBuilder<UserDashboardTable>? orderBy,
    _is.OrderByListBuilder<UserDashboardTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<UserDashboard>(
      rows,
      orderBy: orderBy?.call(UserDashboard.t),
      orderByList: orderByList?.call(UserDashboard.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [UserDashboard].
  Future<UserDashboard> deleteRow(
    _is.DatabaseSession session,
    UserDashboard row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserDashboard>(
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
  Future<List<UserDashboard>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserDashboardTable> where,
    _is.OrderByBuilder<UserDashboardTable>? orderBy,
    _is.OrderByListBuilder<UserDashboardTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<UserDashboard>(
      where: where(UserDashboard.t),
      orderBy: orderBy?.call(UserDashboard.t),
      orderByList: orderByList?.call(UserDashboard.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserDashboardTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<UserDashboard>(
      where: where?.call(UserDashboard.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UserDashboard] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserDashboardTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UserDashboard>(
      where: where(UserDashboard.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
