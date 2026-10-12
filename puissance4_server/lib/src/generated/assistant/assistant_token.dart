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

abstract class AssistantToken
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  AssistantToken._({
    this.id,
    required this.conversationId,
    required this.token,
    required this.kind,
    required this.ref,
  });

  factory AssistantToken({
    _is.UuidValue? id,
    required _is.UuidValue conversationId,
    required String token,
    required String kind,
    required String ref,
  }) = _AssistantTokenImpl;

  factory AssistantToken.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssistantToken(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      conversationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['conversationId'],
      ),
      token: jsonSerialization['token'] as String,
      kind: jsonSerialization['kind'] as String,
      ref: jsonSerialization['ref'] as String,
    );
  }

  static final t = AssistantTokenTable();

  static const db = AssistantTokenRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue conversationId;

  String token;

  String kind;

  String ref;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AssistantToken]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AssistantToken copyWith({
    _is.UuidValue? id,
    _is.UuidValue? conversationId,
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

  static AssistantTokenInclude include() {
    return AssistantTokenInclude._();
  }

  static AssistantTokenIncludeList includeList({
    _is.WhereExpressionBuilder<AssistantTokenTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantTokenTable>? orderBy,
    _is.OrderByListBuilder<AssistantTokenTable>? orderByList,
    AssistantTokenInclude? include,
  }) {
    return AssistantTokenIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssistantToken.t),
      orderByList: orderByList?.call(AssistantToken.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssistantTokenImpl extends AssistantToken {
  _AssistantTokenImpl({
    _is.UuidValue? id,
    required _is.UuidValue conversationId,
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
  @_is.useResult
  @override
  AssistantToken copyWith({
    Object? id = _Undefined,
    _is.UuidValue? conversationId,
    String? token,
    String? kind,
    String? ref,
  }) {
    return AssistantToken(
      id: id is _is.UuidValue? ? id : this.id,
      conversationId: conversationId ?? this.conversationId,
      token: token ?? this.token,
      kind: kind ?? this.kind,
      ref: ref ?? this.ref,
    );
  }
}

class AssistantTokenUpdateTable extends _is.UpdateTable<AssistantTokenTable> {
  AssistantTokenUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> conversationId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.conversationId,
    value,
  );

  _is.ColumnValue<String, String> token(String value) => _is.ColumnValue(
    table.token,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> ref(String value) => _is.ColumnValue(
    table.ref,
    value,
  );
}

class AssistantTokenTable extends _is.Table<_is.UuidValue?> {
  AssistantTokenTable({super.tableRelation})
    : super(tableName: 'assistant_token') {
    updateTable = AssistantTokenUpdateTable(this);
    conversationId = _is.ColumnUuid(
      'conversationId',
      this,
    );
    token = _is.ColumnString(
      'token',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    ref = _is.ColumnString(
      'ref',
      this,
    );
  }

  late final AssistantTokenUpdateTable updateTable;

  late final _is.ColumnUuid conversationId;

  late final _is.ColumnString token;

  late final _is.ColumnString kind;

  late final _is.ColumnString ref;

  @override
  List<_is.Column> get columns => [
    id,
    conversationId,
    token,
    kind,
    ref,
  ];
}

class AssistantTokenInclude extends _is.IncludeObject {
  AssistantTokenInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => AssistantToken.t;
}

class AssistantTokenIncludeList extends _is.IncludeList {
  AssistantTokenIncludeList._({
    _is.WhereExpressionBuilder<AssistantTokenTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AssistantToken.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AssistantToken.t;
}

class AssistantTokenRepository {
  const AssistantTokenRepository._();

  /// Returns a list of [AssistantToken]s matching the given query parameters.
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
  Future<List<AssistantToken>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantTokenTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantTokenTable>? orderBy,
    _is.OrderByListBuilder<AssistantTokenTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AssistantToken>(
      where: where?.call(AssistantToken.t),
      orderBy: orderBy?.call(AssistantToken.t),
      orderByList: orderByList?.call(AssistantToken.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AssistantToken] matching the given query parameters.
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
  Future<AssistantToken?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantTokenTable>? where,
    int? offset,
    _is.OrderByBuilder<AssistantTokenTable>? orderBy,
    _is.OrderByListBuilder<AssistantTokenTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AssistantToken>(
      where: where?.call(AssistantToken.t),
      orderBy: orderBy?.call(AssistantToken.t),
      orderByList: orderByList?.call(AssistantToken.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AssistantToken] by its [id] or null if no such row exists.
  Future<AssistantToken?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AssistantToken>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AssistantToken]s in the list and returns the inserted rows.
  ///
  /// The returned [AssistantToken]s will have their `id` fields set.
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
  Future<List<AssistantToken>> insert(
    _is.DatabaseSession session,
    List<AssistantToken> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AssistantToken>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AssistantToken] and returns the inserted row.
  ///
  /// The returned [AssistantToken] will have its `id` field set.
  Future<AssistantToken> insertRow(
    _is.DatabaseSession session,
    AssistantToken row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AssistantToken>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AssistantToken]s in the list and returns the resulting rows.
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
  /// The returned [AssistantToken]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantToken>> upsert(
    _is.DatabaseSession session,
    List<AssistantToken> rows, {
    required _is.ColumnSelections<AssistantTokenTable> conflictColumns,
    _is.ColumnSelections<AssistantTokenTable>? updateColumns,
    _is.WhereExpressionBuilder<AssistantTokenTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AssistantToken>(
      rows,
      conflictColumns: conflictColumns(AssistantToken.t),
      updateColumns: updateColumns?.call(AssistantToken.t),
      updateWhere: updateWhere?.call(AssistantToken.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AssistantToken] and returns the resulting row.
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
  /// The returned [AssistantToken] will have its `id` field set.
  Future<AssistantToken?> upsertRow(
    _is.DatabaseSession session,
    AssistantToken row, {
    required _is.ColumnSelections<AssistantTokenTable> conflictColumns,
    _is.ColumnSelections<AssistantTokenTable>? updateColumns,
    _is.WhereExpressionBuilder<AssistantTokenTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AssistantToken>(
      row,
      conflictColumns: conflictColumns(AssistantToken.t),
      updateColumns: updateColumns?.call(AssistantToken.t),
      updateWhere: updateWhere?.call(AssistantToken.t),
      transaction: transaction,
    );
  }

  /// Updates all [AssistantToken]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantToken>> update(
    _is.DatabaseSession session,
    List<AssistantToken> rows, {
    _is.ColumnSelections<AssistantTokenTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AssistantToken>(
      rows,
      columns: columns?.call(AssistantToken.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AssistantToken]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AssistantToken> updateRow(
    _is.DatabaseSession session,
    AssistantToken row, {
    _is.ColumnSelections<AssistantTokenTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AssistantToken>(
      row,
      columns: columns?.call(AssistantToken.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AssistantToken] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AssistantToken?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AssistantTokenUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AssistantToken>(
      id,
      columnValues: columnValues(AssistantToken.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AssistantToken]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssistantToken>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AssistantTokenUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AssistantTokenTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssistantTokenTable>? orderBy,
    _is.OrderByListBuilder<AssistantTokenTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AssistantToken>(
      columnValues: columnValues(AssistantToken.t.updateTable),
      where: where(AssistantToken.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssistantToken.t),
      orderByList: orderByList?.call(AssistantToken.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AssistantToken]s in the list and returns the deleted rows.
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
  Future<List<AssistantToken>> delete(
    _is.DatabaseSession session,
    List<AssistantToken> rows, {
    _is.OrderByBuilder<AssistantTokenTable>? orderBy,
    _is.OrderByListBuilder<AssistantTokenTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AssistantToken>(
      rows,
      orderBy: orderBy?.call(AssistantToken.t),
      orderByList: orderByList?.call(AssistantToken.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AssistantToken].
  Future<AssistantToken> deleteRow(
    _is.DatabaseSession session,
    AssistantToken row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AssistantToken>(
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
  Future<List<AssistantToken>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssistantTokenTable> where,
    _is.OrderByBuilder<AssistantTokenTable>? orderBy,
    _is.OrderByListBuilder<AssistantTokenTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AssistantToken>(
      where: where(AssistantToken.t),
      orderBy: orderBy?.call(AssistantToken.t),
      orderByList: orderByList?.call(AssistantToken.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssistantTokenTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AssistantToken>(
      where: where?.call(AssistantToken.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AssistantToken] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssistantTokenTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AssistantToken>(
      where: where(AssistantToken.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
