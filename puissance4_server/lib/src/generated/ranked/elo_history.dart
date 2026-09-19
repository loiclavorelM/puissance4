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

abstract class EloHistory
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  EloHistory._({
    this.id,
    required this.userId,
    required this.partieId,
    required this.eloVariation,
    required this.newElo,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory EloHistory({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required _is.UuidValue partieId,
    required int eloVariation,
    required int newElo,
    DateTime? createdAt,
  }) = _EloHistoryImpl;

  factory EloHistory.fromJson(Map<String, dynamic> jsonSerialization) {
    return EloHistory(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      partieId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['partieId'],
      ),
      eloVariation: jsonSerialization['eloVariation'] as int,
      newElo: jsonSerialization['newElo'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = EloHistoryTable();

  static const db = EloHistoryRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue userId;

  _is.UuidValue partieId;

  int eloVariation;

  int newElo;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [EloHistory]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  EloHistory copyWith({
    _is.UuidValue? id,
    _is.UuidValue? userId,
    _is.UuidValue? partieId,
    int? eloVariation,
    int? newElo,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EloHistory',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'partieId': partieId.toJson(),
      'eloVariation': eloVariation,
      'newElo': newElo,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EloHistory',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'partieId': partieId.toJson(),
      'eloVariation': eloVariation,
      'newElo': newElo,
      'createdAt': createdAt.toJson(),
    };
  }

  static EloHistoryInclude include() {
    return EloHistoryInclude._();
  }

  static EloHistoryIncludeList includeList({
    _is.WhereExpressionBuilder<EloHistoryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EloHistoryTable>? orderBy,
    _is.OrderByListBuilder<EloHistoryTable>? orderByList,
    EloHistoryInclude? include,
  }) {
    return EloHistoryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EloHistory.t),
      orderByList: orderByList?.call(EloHistory.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EloHistoryImpl extends EloHistory {
  _EloHistoryImpl({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required _is.UuidValue partieId,
    required int eloVariation,
    required int newElo,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         partieId: partieId,
         eloVariation: eloVariation,
         newElo: newElo,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [EloHistory]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  EloHistory copyWith({
    Object? id = _Undefined,
    _is.UuidValue? userId,
    _is.UuidValue? partieId,
    int? eloVariation,
    int? newElo,
    DateTime? createdAt,
  }) {
    return EloHistory(
      id: id is _is.UuidValue? ? id : this.id,
      userId: userId ?? this.userId,
      partieId: partieId ?? this.partieId,
      eloVariation: eloVariation ?? this.eloVariation,
      newElo: newElo ?? this.newElo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class EloHistoryUpdateTable extends _is.UpdateTable<EloHistoryTable> {
  EloHistoryUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.userId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> partieId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.partieId,
        value,
      );

  _is.ColumnValue<int, int> eloVariation(int value) => _is.ColumnValue(
    table.eloVariation,
    value,
  );

  _is.ColumnValue<int, int> newElo(int value) => _is.ColumnValue(
    table.newElo,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class EloHistoryTable extends _is.Table<_is.UuidValue?> {
  EloHistoryTable({super.tableRelation}) : super(tableName: 'elo_history') {
    updateTable = EloHistoryUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    partieId = _is.ColumnUuid(
      'partieId',
      this,
    );
    eloVariation = _is.ColumnInt(
      'eloVariation',
      this,
    );
    newElo = _is.ColumnInt(
      'newElo',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final EloHistoryUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  late final _is.ColumnUuid partieId;

  late final _is.ColumnInt eloVariation;

  late final _is.ColumnInt newElo;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    partieId,
    eloVariation,
    newElo,
    createdAt,
  ];
}

class EloHistoryInclude extends _is.IncludeObject {
  EloHistoryInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => EloHistory.t;
}

class EloHistoryIncludeList extends _is.IncludeList {
  EloHistoryIncludeList._({
    _is.WhereExpressionBuilder<EloHistoryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EloHistory.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => EloHistory.t;
}

class EloHistoryRepository {
  const EloHistoryRepository._();

  /// Returns a list of [EloHistory]s matching the given query parameters.
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
  Future<List<EloHistory>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EloHistoryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EloHistoryTable>? orderBy,
    _is.OrderByListBuilder<EloHistoryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<EloHistory>(
      where: where?.call(EloHistory.t),
      orderBy: orderBy?.call(EloHistory.t),
      orderByList: orderByList?.call(EloHistory.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [EloHistory] matching the given query parameters.
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
  Future<EloHistory?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EloHistoryTable>? where,
    int? offset,
    _is.OrderByBuilder<EloHistoryTable>? orderBy,
    _is.OrderByListBuilder<EloHistoryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<EloHistory>(
      where: where?.call(EloHistory.t),
      orderBy: orderBy?.call(EloHistory.t),
      orderByList: orderByList?.call(EloHistory.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [EloHistory] by its [id] or null if no such row exists.
  Future<EloHistory?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<EloHistory>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [EloHistory]s in the list and returns the inserted rows.
  ///
  /// The returned [EloHistory]s will have their `id` fields set.
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
  Future<List<EloHistory>> insert(
    _is.DatabaseSession session,
    List<EloHistory> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<EloHistory>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [EloHistory] and returns the inserted row.
  ///
  /// The returned [EloHistory] will have its `id` field set.
  Future<EloHistory> insertRow(
    _is.DatabaseSession session,
    EloHistory row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<EloHistory>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [EloHistory]s in the list and returns the resulting rows.
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
  /// The returned [EloHistory]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EloHistory>> upsert(
    _is.DatabaseSession session,
    List<EloHistory> rows, {
    required _is.ColumnSelections<EloHistoryTable> conflictColumns,
    _is.ColumnSelections<EloHistoryTable>? updateColumns,
    _is.WhereExpressionBuilder<EloHistoryTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<EloHistory>(
      rows,
      conflictColumns: conflictColumns(EloHistory.t),
      updateColumns: updateColumns?.call(EloHistory.t),
      updateWhere: updateWhere?.call(EloHistory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [EloHistory] and returns the resulting row.
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
  /// The returned [EloHistory] will have its `id` field set.
  Future<EloHistory?> upsertRow(
    _is.DatabaseSession session,
    EloHistory row, {
    required _is.ColumnSelections<EloHistoryTable> conflictColumns,
    _is.ColumnSelections<EloHistoryTable>? updateColumns,
    _is.WhereExpressionBuilder<EloHistoryTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<EloHistory>(
      row,
      conflictColumns: conflictColumns(EloHistory.t),
      updateColumns: updateColumns?.call(EloHistory.t),
      updateWhere: updateWhere?.call(EloHistory.t),
      transaction: transaction,
    );
  }

  /// Updates all [EloHistory]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EloHistory>> update(
    _is.DatabaseSession session,
    List<EloHistory> rows, {
    _is.ColumnSelections<EloHistoryTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<EloHistory>(
      rows,
      columns: columns?.call(EloHistory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [EloHistory]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EloHistory> updateRow(
    _is.DatabaseSession session,
    EloHistory row, {
    _is.ColumnSelections<EloHistoryTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<EloHistory>(
      row,
      columns: columns?.call(EloHistory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EloHistory] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<EloHistory?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<EloHistoryUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<EloHistory>(
      id,
      columnValues: columnValues(EloHistory.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [EloHistory]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EloHistory>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<EloHistoryUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<EloHistoryTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EloHistoryTable>? orderBy,
    _is.OrderByListBuilder<EloHistoryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<EloHistory>(
      columnValues: columnValues(EloHistory.t.updateTable),
      where: where(EloHistory.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EloHistory.t),
      orderByList: orderByList?.call(EloHistory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [EloHistory]s in the list and returns the deleted rows.
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
  Future<List<EloHistory>> delete(
    _is.DatabaseSession session,
    List<EloHistory> rows, {
    _is.OrderByBuilder<EloHistoryTable>? orderBy,
    _is.OrderByListBuilder<EloHistoryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<EloHistory>(
      rows,
      orderBy: orderBy?.call(EloHistory.t),
      orderByList: orderByList?.call(EloHistory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [EloHistory].
  Future<EloHistory> deleteRow(
    _is.DatabaseSession session,
    EloHistory row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EloHistory>(
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
  Future<List<EloHistory>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EloHistoryTable> where,
    _is.OrderByBuilder<EloHistoryTable>? orderBy,
    _is.OrderByListBuilder<EloHistoryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<EloHistory>(
      where: where(EloHistory.t),
      orderBy: orderBy?.call(EloHistory.t),
      orderByList: orderByList?.call(EloHistory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EloHistoryTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<EloHistory>(
      where: where?.call(EloHistory.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [EloHistory] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EloHistoryTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<EloHistory>(
      where: where(EloHistory.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
