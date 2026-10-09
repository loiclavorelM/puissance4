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

abstract class AssistantMessage
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  AssistantMessage._({
    this.id,
    required this.conversationId,
    required this.position,
    required this.contentJson,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AssistantMessage({
    _is.UuidValue? id,
    required _is.UuidValue conversationId,
    required int position,
    required String contentJson,
    DateTime? createdAt,
  }) = _AssistantMessageImpl;

  factory AssistantMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssistantMessage(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      conversationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['conversationId'],
      ),
      position: jsonSerialization['position'] as int,
      contentJson: jsonSerialization['contentJson'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = AssistantMessageTable();

  static const db = AssistantMessageRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue conversationId;

  int position;

  String contentJson;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AssistantMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AssistantMessage copyWith({
    _is.UuidValue? id,
    _is.UuidValue? conversationId,
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

  static AssistantMessageInclude include() {
    return AssistantMessageInclude._();
  }

  static AssistantMessageIncludeList includeList({
    _is.WhereExpressionBuilder<AssistantMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantMessageTable>? orderBy,
    _is.OrderByListBuilder<AssistantMessageTable>? orderByList,
    AssistantMessageInclude? include,
  }) {
    return AssistantMessageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssistantMessage.t),
      orderByList: orderByList?.call(AssistantMessage.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssistantMessageImpl extends AssistantMessage {
  _AssistantMessageImpl({
    _is.UuidValue? id,
    required _is.UuidValue conversationId,
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
  @_is.useResult
  @override
  AssistantMessage copyWith({
    Object? id = _Undefined,
    _is.UuidValue? conversationId,
    int? position,
    String? contentJson,
    DateTime? createdAt,
  }) {
    return AssistantMessage(
      id: id is _is.UuidValue? ? id : this.id,
      conversationId: conversationId ?? this.conversationId,
      position: position ?? this.position,
      contentJson: contentJson ?? this.contentJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AssistantMessageUpdateTable
    extends _is.UpdateTable<AssistantMessageTable> {
  AssistantMessageUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> conversationId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.conversationId,
    value,
  );

  _is.ColumnValue<int, int> position(int value) => _is.ColumnValue(
    table.position,
    value,
  );

  _is.ColumnValue<String, String> contentJson(String value) => _is.ColumnValue(
    table.contentJson,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class AssistantMessageTable extends _is.Table<_is.UuidValue?> {
  AssistantMessageTable({super.tableRelation})
    : super(tableName: 'assistant_message') {
    updateTable = AssistantMessageUpdateTable(this);
    conversationId = _is.ColumnUuid(
      'conversationId',
      this,
    );
    position = _is.ColumnInt(
      'position',
      this,
    );
    contentJson = _is.ColumnString(
      'contentJson',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final AssistantMessageUpdateTable updateTable;

  late final _is.ColumnUuid conversationId;

  late final _is.ColumnInt position;

  late final _is.ColumnString contentJson;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    conversationId,
    position,
    contentJson,
    createdAt,
  ];
}

class AssistantMessageInclude extends _is.IncludeObject {
  AssistantMessageInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => AssistantMessage.t;
}

class AssistantMessageIncludeList extends _is.IncludeList {
  AssistantMessageIncludeList._({
    _is.WhereExpressionBuilder<AssistantMessageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AssistantMessage.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AssistantMessage.t;
}

class AssistantMessageRepository {
  const AssistantMessageRepository._();

  /// Returns a list of [AssistantMessage]s matching the given query parameters.
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
  Future<List<AssistantMessage>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantMessageTable>? orderBy,
    _is.OrderByListBuilder<AssistantMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AssistantMessage>(
      where: where?.call(AssistantMessage.t),
      orderBy: orderBy?.call(AssistantMessage.t),
      orderByList: orderByList?.call(AssistantMessage.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AssistantMessage] matching the given query parameters.
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
  Future<AssistantMessage?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantMessageTable>? where,
    int? offset,
    _is.OrderByBuilder<AssistantMessageTable>? orderBy,
    _is.OrderByListBuilder<AssistantMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AssistantMessage>(
      where: where?.call(AssistantMessage.t),
      orderBy: orderBy?.call(AssistantMessage.t),
      orderByList: orderByList?.call(AssistantMessage.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AssistantMessage] by its [id] or null if no such row exists.
  Future<AssistantMessage?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AssistantMessage>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AssistantMessage]s in the list and returns the inserted rows.
  ///
  /// The returned [AssistantMessage]s will have their `id` fields set.
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
  Future<List<AssistantMessage>> insert(
    _is.DatabaseSession session,
    List<AssistantMessage> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AssistantMessage>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AssistantMessage] and returns the inserted row.
  ///
  /// The returned [AssistantMessage] will have its `id` field set.
  Future<AssistantMessage> insertRow(
    _is.DatabaseSession session,
    AssistantMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AssistantMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AssistantMessage]s in the list and returns the resulting rows.
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
  /// The returned [AssistantMessage]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantMessage>> upsert(
    _is.DatabaseSession session,
    List<AssistantMessage> rows, {
    required _is.ColumnSelections<AssistantMessageTable> conflictColumns,
    _is.ColumnSelections<AssistantMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<AssistantMessageTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AssistantMessage>(
      rows,
      conflictColumns: conflictColumns(AssistantMessage.t),
      updateColumns: updateColumns?.call(AssistantMessage.t),
      updateWhere: updateWhere?.call(AssistantMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AssistantMessage] and returns the resulting row.
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
  /// The returned [AssistantMessage] will have its `id` field set.
  Future<AssistantMessage?> upsertRow(
    _is.DatabaseSession session,
    AssistantMessage row, {
    required _is.ColumnSelections<AssistantMessageTable> conflictColumns,
    _is.ColumnSelections<AssistantMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<AssistantMessageTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AssistantMessage>(
      row,
      conflictColumns: conflictColumns(AssistantMessage.t),
      updateColumns: updateColumns?.call(AssistantMessage.t),
      updateWhere: updateWhere?.call(AssistantMessage.t),
      transaction: transaction,
    );
  }

  /// Updates all [AssistantMessage]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantMessage>> update(
    _is.DatabaseSession session,
    List<AssistantMessage> rows, {
    _is.ColumnSelections<AssistantMessageTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AssistantMessage>(
      rows,
      columns: columns?.call(AssistantMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AssistantMessage]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AssistantMessage> updateRow(
    _is.DatabaseSession session,
    AssistantMessage row, {
    _is.ColumnSelections<AssistantMessageTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AssistantMessage>(
      row,
      columns: columns?.call(AssistantMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AssistantMessage] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AssistantMessage?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AssistantMessageUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AssistantMessage>(
      id,
      columnValues: columnValues(AssistantMessage.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AssistantMessage]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantMessage>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AssistantMessageUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AssistantMessageTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantMessageTable>? orderBy,
    _is.OrderByListBuilder<AssistantMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AssistantMessage>(
      columnValues: columnValues(AssistantMessage.t.updateTable),
      where: where(AssistantMessage.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssistantMessage.t),
      orderByList: orderByList?.call(AssistantMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AssistantMessage]s in the list and returns the deleted rows.
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
  Future<List<AssistantMessage>> delete(
    _is.DatabaseSession session,
    List<AssistantMessage> rows, {
    _is.OrderByBuilder<AssistantMessageTable>? orderBy,
    _is.OrderByListBuilder<AssistantMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AssistantMessage>(
      rows,
      orderBy: orderBy?.call(AssistantMessage.t),
      orderByList: orderByList?.call(AssistantMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AssistantMessage].
  Future<AssistantMessage> deleteRow(
    _is.DatabaseSession session,
    AssistantMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AssistantMessage>(
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
  Future<List<AssistantMessage>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssistantMessageTable> where,
    _is.OrderByBuilder<AssistantMessageTable>? orderBy,
    _is.OrderByListBuilder<AssistantMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AssistantMessage>(
      where: where(AssistantMessage.t),
      orderBy: orderBy?.call(AssistantMessage.t),
      orderByList: orderByList?.call(AssistantMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantMessageTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AssistantMessage>(
      where: where?.call(AssistantMessage.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AssistantMessage] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssistantMessageTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AssistantMessage>(
      where: where(AssistantMessage.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
