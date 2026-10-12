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

abstract class AssistantConversation
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  AssistantConversation._({
    this.id,
    required this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory AssistantConversation({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AssistantConversationImpl;

  factory AssistantConversation.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AssistantConversation(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = AssistantConversationTable();

  static const db = AssistantConversationRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue userId;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AssistantConversation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AssistantConversation copyWith({
    _is.UuidValue? id,
    _is.UuidValue? userId,
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

  static AssistantConversationInclude include() {
    return AssistantConversationInclude._();
  }

  static AssistantConversationIncludeList includeList({
    _is.WhereExpressionBuilder<AssistantConversationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantConversationTable>? orderBy,
    _is.OrderByListBuilder<AssistantConversationTable>? orderByList,
    AssistantConversationInclude? include,
  }) {
    return AssistantConversationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssistantConversation.t),
      orderByList: orderByList?.call(AssistantConversation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssistantConversationImpl extends AssistantConversation {
  _AssistantConversationImpl({
    _is.UuidValue? id,
    required _is.UuidValue userId,
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
  @_is.useResult
  @override
  AssistantConversation copyWith({
    Object? id = _Undefined,
    _is.UuidValue? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssistantConversation(
      id: id is _is.UuidValue? ? id : this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AssistantConversationUpdateTable
    extends _is.UpdateTable<AssistantConversationTable> {
  AssistantConversationUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.userId,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class AssistantConversationTable extends _is.Table<_is.UuidValue?> {
  AssistantConversationTable({super.tableRelation})
    : super(tableName: 'assistant_conversation') {
    updateTable = AssistantConversationUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final AssistantConversationUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    createdAt,
    updatedAt,
  ];
}

class AssistantConversationInclude extends _is.IncludeObject {
  AssistantConversationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => AssistantConversation.t;
}

class AssistantConversationIncludeList extends _is.IncludeList {
  AssistantConversationIncludeList._({
    _is.WhereExpressionBuilder<AssistantConversationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AssistantConversation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AssistantConversation.t;
}

class AssistantConversationRepository {
  const AssistantConversationRepository._();

  /// Returns a list of [AssistantConversation]s matching the given query parameters.
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
  Future<List<AssistantConversation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantConversationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantConversationTable>? orderBy,
    _is.OrderByListBuilder<AssistantConversationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AssistantConversation>(
      where: where?.call(AssistantConversation.t),
      orderBy: orderBy?.call(AssistantConversation.t),
      orderByList: orderByList?.call(AssistantConversation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AssistantConversation] matching the given query parameters.
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
  Future<AssistantConversation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantConversationTable>? where,
    int? offset,
    _is.OrderByBuilder<AssistantConversationTable>? orderBy,
    _is.OrderByListBuilder<AssistantConversationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AssistantConversation>(
      where: where?.call(AssistantConversation.t),
      orderBy: orderBy?.call(AssistantConversation.t),
      orderByList: orderByList?.call(AssistantConversation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AssistantConversation] by its [id] or null if no such row exists.
  Future<AssistantConversation?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AssistantConversation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AssistantConversation]s in the list and returns the inserted rows.
  ///
  /// The returned [AssistantConversation]s will have their `id` fields set.
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
  Future<List<AssistantConversation>> insert(
    _is.DatabaseSession session,
    List<AssistantConversation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AssistantConversation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AssistantConversation] and returns the inserted row.
  ///
  /// The returned [AssistantConversation] will have its `id` field set.
  Future<AssistantConversation> insertRow(
    _is.DatabaseSession session,
    AssistantConversation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AssistantConversation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AssistantConversation]s in the list and returns the resulting rows.
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
  /// The returned [AssistantConversation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantConversation>> upsert(
    _is.DatabaseSession session,
    List<AssistantConversation> rows, {
    required _is.ColumnSelections<AssistantConversationTable> conflictColumns,
    _is.ColumnSelections<AssistantConversationTable>? updateColumns,
    _is.WhereExpressionBuilder<AssistantConversationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AssistantConversation>(
      rows,
      conflictColumns: conflictColumns(AssistantConversation.t),
      updateColumns: updateColumns?.call(AssistantConversation.t),
      updateWhere: updateWhere?.call(AssistantConversation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AssistantConversation] and returns the resulting row.
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
  /// The returned [AssistantConversation] will have its `id` field set.
  Future<AssistantConversation?> upsertRow(
    _is.DatabaseSession session,
    AssistantConversation row, {
    required _is.ColumnSelections<AssistantConversationTable> conflictColumns,
    _is.ColumnSelections<AssistantConversationTable>? updateColumns,
    _is.WhereExpressionBuilder<AssistantConversationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AssistantConversation>(
      row,
      conflictColumns: conflictColumns(AssistantConversation.t),
      updateColumns: updateColumns?.call(AssistantConversation.t),
      updateWhere: updateWhere?.call(AssistantConversation.t),
      transaction: transaction,
    );
  }

  /// Updates all [AssistantConversation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantConversation>> update(
    _is.DatabaseSession session,
    List<AssistantConversation> rows, {
    _is.ColumnSelections<AssistantConversationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AssistantConversation>(
      rows,
      columns: columns?.call(AssistantConversation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AssistantConversation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AssistantConversation> updateRow(
    _is.DatabaseSession session,
    AssistantConversation row, {
    _is.ColumnSelections<AssistantConversationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AssistantConversation>(
      row,
      columns: columns?.call(AssistantConversation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AssistantConversation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AssistantConversation?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AssistantConversationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AssistantConversation>(
      id,
      columnValues: columnValues(AssistantConversation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AssistantConversation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantConversation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AssistantConversationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AssistantConversationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantConversationTable>? orderBy,
    _is.OrderByListBuilder<AssistantConversationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AssistantConversation>(
      columnValues: columnValues(AssistantConversation.t.updateTable),
      where: where(AssistantConversation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssistantConversation.t),
      orderByList: orderByList?.call(AssistantConversation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AssistantConversation]s in the list and returns the deleted rows.
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
  Future<List<AssistantConversation>> delete(
    _is.DatabaseSession session,
    List<AssistantConversation> rows, {
    _is.OrderByBuilder<AssistantConversationTable>? orderBy,
    _is.OrderByListBuilder<AssistantConversationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AssistantConversation>(
      rows,
      orderBy: orderBy?.call(AssistantConversation.t),
      orderByList: orderByList?.call(AssistantConversation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AssistantConversation].
  Future<AssistantConversation> deleteRow(
    _is.DatabaseSession session,
    AssistantConversation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AssistantConversation>(
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
  Future<List<AssistantConversation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssistantConversationTable> where,
    _is.OrderByBuilder<AssistantConversationTable>? orderBy,
    _is.OrderByListBuilder<AssistantConversationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AssistantConversation>(
      where: where(AssistantConversation.t),
      orderBy: orderBy?.call(AssistantConversation.t),
      orderByList: orderByList?.call(AssistantConversation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantConversationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AssistantConversation>(
      where: where?.call(AssistantConversation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AssistantConversation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssistantConversationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AssistantConversation>(
      where: where(AssistantConversation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
