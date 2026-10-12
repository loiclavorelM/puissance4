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

abstract class AssistantRequestLog
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
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
    _is.UuidValue? id,
    required _is.UuidValue userId,
    _is.UuidValue? conversationId,
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
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      conversationId: jsonSerialization['conversationId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
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
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = AssistantRequestLogTable();

  static const db = AssistantRequestLogRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue userId;

  _is.UuidValue? conversationId;

  String model;

  int inputTokens;

  int outputTokens;

  String toolsJson;

  int turns;

  int durationMs;

  String? errorCode;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AssistantRequestLog]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AssistantRequestLog copyWith({
    _is.UuidValue? id,
    _is.UuidValue? userId,
    _is.UuidValue? conversationId,
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

  static AssistantRequestLogInclude include() {
    return AssistantRequestLogInclude._();
  }

  static AssistantRequestLogIncludeList includeList({
    _is.WhereExpressionBuilder<AssistantRequestLogTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantRequestLogTable>? orderBy,
    _is.OrderByListBuilder<AssistantRequestLogTable>? orderByList,
    AssistantRequestLogInclude? include,
  }) {
    return AssistantRequestLogIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssistantRequestLog.t),
      orderByList: orderByList?.call(AssistantRequestLog.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssistantRequestLogImpl extends AssistantRequestLog {
  _AssistantRequestLogImpl({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    _is.UuidValue? conversationId,
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
  @_is.useResult
  @override
  AssistantRequestLog copyWith({
    Object? id = _Undefined,
    _is.UuidValue? userId,
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
      id: id is _is.UuidValue? ? id : this.id,
      userId: userId ?? this.userId,
      conversationId: conversationId is _is.UuidValue?
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

class AssistantRequestLogUpdateTable
    extends _is.UpdateTable<AssistantRequestLogTable> {
  AssistantRequestLogUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.userId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> conversationId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.conversationId,
    value,
  );

  _is.ColumnValue<String, String> model(String value) => _is.ColumnValue(
    table.model,
    value,
  );

  _is.ColumnValue<int, int> inputTokens(int value) => _is.ColumnValue(
    table.inputTokens,
    value,
  );

  _is.ColumnValue<int, int> outputTokens(int value) => _is.ColumnValue(
    table.outputTokens,
    value,
  );

  _is.ColumnValue<String, String> toolsJson(String value) => _is.ColumnValue(
    table.toolsJson,
    value,
  );

  _is.ColumnValue<int, int> turns(int value) => _is.ColumnValue(
    table.turns,
    value,
  );

  _is.ColumnValue<int, int> durationMs(int value) => _is.ColumnValue(
    table.durationMs,
    value,
  );

  _is.ColumnValue<String, String> errorCode(String? value) => _is.ColumnValue(
    table.errorCode,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class AssistantRequestLogTable extends _is.Table<_is.UuidValue?> {
  AssistantRequestLogTable({super.tableRelation})
    : super(tableName: 'assistant_request_log') {
    updateTable = AssistantRequestLogUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    conversationId = _is.ColumnUuid(
      'conversationId',
      this,
    );
    model = _is.ColumnString(
      'model',
      this,
    );
    inputTokens = _is.ColumnInt(
      'inputTokens',
      this,
    );
    outputTokens = _is.ColumnInt(
      'outputTokens',
      this,
    );
    toolsJson = _is.ColumnString(
      'toolsJson',
      this,
    );
    turns = _is.ColumnInt(
      'turns',
      this,
    );
    durationMs = _is.ColumnInt(
      'durationMs',
      this,
    );
    errorCode = _is.ColumnString(
      'errorCode',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final AssistantRequestLogUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  late final _is.ColumnUuid conversationId;

  late final _is.ColumnString model;

  late final _is.ColumnInt inputTokens;

  late final _is.ColumnInt outputTokens;

  late final _is.ColumnString toolsJson;

  late final _is.ColumnInt turns;

  late final _is.ColumnInt durationMs;

  late final _is.ColumnString errorCode;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    conversationId,
    model,
    inputTokens,
    outputTokens,
    toolsJson,
    turns,
    durationMs,
    errorCode,
    createdAt,
  ];
}

class AssistantRequestLogInclude extends _is.IncludeObject {
  AssistantRequestLogInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => AssistantRequestLog.t;
}

class AssistantRequestLogIncludeList extends _is.IncludeList {
  AssistantRequestLogIncludeList._({
    _is.WhereExpressionBuilder<AssistantRequestLogTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AssistantRequestLog.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AssistantRequestLog.t;
}

class AssistantRequestLogRepository {
  const AssistantRequestLogRepository._();

  /// Returns a list of [AssistantRequestLog]s matching the given query parameters.
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
  Future<List<AssistantRequestLog>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantRequestLogTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantRequestLogTable>? orderBy,
    _is.OrderByListBuilder<AssistantRequestLogTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AssistantRequestLog>(
      where: where?.call(AssistantRequestLog.t),
      orderBy: orderBy?.call(AssistantRequestLog.t),
      orderByList: orderByList?.call(AssistantRequestLog.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AssistantRequestLog] matching the given query parameters.
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
  Future<AssistantRequestLog?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantRequestLogTable>? where,
    int? offset,
    _is.OrderByBuilder<AssistantRequestLogTable>? orderBy,
    _is.OrderByListBuilder<AssistantRequestLogTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AssistantRequestLog>(
      where: where?.call(AssistantRequestLog.t),
      orderBy: orderBy?.call(AssistantRequestLog.t),
      orderByList: orderByList?.call(AssistantRequestLog.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AssistantRequestLog] by its [id] or null if no such row exists.
  Future<AssistantRequestLog?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AssistantRequestLog>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AssistantRequestLog]s in the list and returns the inserted rows.
  ///
  /// The returned [AssistantRequestLog]s will have their `id` fields set.
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
  Future<List<AssistantRequestLog>> insert(
    _is.DatabaseSession session,
    List<AssistantRequestLog> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AssistantRequestLog>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AssistantRequestLog] and returns the inserted row.
  ///
  /// The returned [AssistantRequestLog] will have its `id` field set.
  Future<AssistantRequestLog> insertRow(
    _is.DatabaseSession session,
    AssistantRequestLog row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AssistantRequestLog>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AssistantRequestLog]s in the list and returns the resulting rows.
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
  /// The returned [AssistantRequestLog]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantRequestLog>> upsert(
    _is.DatabaseSession session,
    List<AssistantRequestLog> rows, {
    required _is.ColumnSelections<AssistantRequestLogTable> conflictColumns,
    _is.ColumnSelections<AssistantRequestLogTable>? updateColumns,
    _is.WhereExpressionBuilder<AssistantRequestLogTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AssistantRequestLog>(
      rows,
      conflictColumns: conflictColumns(AssistantRequestLog.t),
      updateColumns: updateColumns?.call(AssistantRequestLog.t),
      updateWhere: updateWhere?.call(AssistantRequestLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AssistantRequestLog] and returns the resulting row.
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
  /// The returned [AssistantRequestLog] will have its `id` field set.
  Future<AssistantRequestLog?> upsertRow(
    _is.DatabaseSession session,
    AssistantRequestLog row, {
    required _is.ColumnSelections<AssistantRequestLogTable> conflictColumns,
    _is.ColumnSelections<AssistantRequestLogTable>? updateColumns,
    _is.WhereExpressionBuilder<AssistantRequestLogTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AssistantRequestLog>(
      row,
      conflictColumns: conflictColumns(AssistantRequestLog.t),
      updateColumns: updateColumns?.call(AssistantRequestLog.t),
      updateWhere: updateWhere?.call(AssistantRequestLog.t),
      transaction: transaction,
    );
  }

  /// Updates all [AssistantRequestLog]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantRequestLog>> update(
    _is.DatabaseSession session,
    List<AssistantRequestLog> rows, {
    _is.ColumnSelections<AssistantRequestLogTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AssistantRequestLog>(
      rows,
      columns: columns?.call(AssistantRequestLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AssistantRequestLog]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AssistantRequestLog> updateRow(
    _is.DatabaseSession session,
    AssistantRequestLog row, {
    _is.ColumnSelections<AssistantRequestLogTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AssistantRequestLog>(
      row,
      columns: columns?.call(AssistantRequestLog.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AssistantRequestLog] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AssistantRequestLog?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AssistantRequestLogUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AssistantRequestLog>(
      id,
      columnValues: columnValues(AssistantRequestLog.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AssistantRequestLog]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantRequestLog>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AssistantRequestLogUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AssistantRequestLogTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantRequestLogTable>? orderBy,
    _is.OrderByListBuilder<AssistantRequestLogTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AssistantRequestLog>(
      columnValues: columnValues(AssistantRequestLog.t.updateTable),
      where: where(AssistantRequestLog.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssistantRequestLog.t),
      orderByList: orderByList?.call(AssistantRequestLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AssistantRequestLog]s in the list and returns the deleted rows.
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
  Future<List<AssistantRequestLog>> delete(
    _is.DatabaseSession session,
    List<AssistantRequestLog> rows, {
    _is.OrderByBuilder<AssistantRequestLogTable>? orderBy,
    _is.OrderByListBuilder<AssistantRequestLogTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AssistantRequestLog>(
      rows,
      orderBy: orderBy?.call(AssistantRequestLog.t),
      orderByList: orderByList?.call(AssistantRequestLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AssistantRequestLog].
  Future<AssistantRequestLog> deleteRow(
    _is.DatabaseSession session,
    AssistantRequestLog row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AssistantRequestLog>(
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
  Future<List<AssistantRequestLog>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssistantRequestLogTable> where,
    _is.OrderByBuilder<AssistantRequestLogTable>? orderBy,
    _is.OrderByListBuilder<AssistantRequestLogTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AssistantRequestLog>(
      where: where(AssistantRequestLog.t),
      orderBy: orderBy?.call(AssistantRequestLog.t),
      orderByList: orderByList?.call(AssistantRequestLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantRequestLogTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AssistantRequestLog>(
      where: where?.call(AssistantRequestLog.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AssistantRequestLog] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssistantRequestLogTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AssistantRequestLog>(
      where: where(AssistantRequestLog.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
