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
import 'package:puissance4_client/src/protocol/protocol.dart' as _ixdd0t97;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_database/serverpod_database.dart' as _isd;
import '../bot/enum_bot_level.dart' as _ivcfpjgb;
import '../game/enum_match_result.dart' as _ib5rq0bj;

abstract class OfflineMatchResult
    implements _isd.TableRow<_isc.UuidValue?>, _isc.ProtocolSerialization {
  OfflineMatchResult._({
    this.id,
    this.spaceId,
    required this.result,
    required this.botLevel,
    required this.moves,
    required this.playedAt,
    bool? reconciled,
  }) : reconciled = reconciled ?? false;

  factory OfflineMatchResult({
    _isc.UuidValue? id,
    int? spaceId,
    required _ib5rq0bj.EnumMatchResult result,
    required _ivcfpjgb.EnumBotLevel botLevel,
    required List<int> moves,
    required DateTime playedAt,
    bool? reconciled,
  }) = _OfflineMatchResultImpl;

  factory OfflineMatchResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return OfflineMatchResult(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      spaceId: jsonSerialization['spaceId'] as int?,
      result: _ib5rq0bj.EnumMatchResult.fromJson(
        (jsonSerialization['result'] as String),
      ),
      botLevel: _ivcfpjgb.EnumBotLevel.fromJson(
        (jsonSerialization['botLevel'] as String),
      ),
      moves: _ixdd0t97.Protocol().deserialize<List<int>>(
        jsonSerialization['moves'],
      ),
      playedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['playedAt'],
      ),
      reconciled: jsonSerialization['reconciled'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['reconciled']),
    );
  }

  static final t = OfflineMatchResultTable();

  static const db = OfflineMatchResultRepository._();

  @override
  _isc.UuidValue? id;

  /// The space owning this row. Maintained by the sync engine.
  int? spaceId;

  _ib5rq0bj.EnumMatchResult result;

  _ivcfpjgb.EnumBotLevel botLevel;

  List<int> moves;

  DateTime playedAt;

  bool reconciled;

  @override
  _isd.Table<_isc.UuidValue?> get table => t;

  /// Returns a shallow copy of this [OfflineMatchResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  OfflineMatchResult copyWith({
    _isc.UuidValue? id,
    int? spaceId,
    _ib5rq0bj.EnumMatchResult? result,
    _ivcfpjgb.EnumBotLevel? botLevel,
    List<int>? moves,
    DateTime? playedAt,
    bool? reconciled,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OfflineMatchResult',
      if (id != null) 'id': id?.toJson(),
      if (spaceId != null) 'spaceId': spaceId,
      'result': result.toJson(),
      'botLevel': botLevel.toJson(),
      'moves': moves.toJson(),
      'playedAt': playedAt.toJson(),
      'reconciled': reconciled,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OfflineMatchResult',
      if (id != null) 'id': id?.toJson(),
      if (spaceId != null) 'spaceId': spaceId,
      'result': result.toJson(),
      'botLevel': botLevel.toJson(),
      'moves': moves.toJson(),
      'playedAt': playedAt.toJson(),
      'reconciled': reconciled,
    };
  }

  static OfflineMatchResultInclude include() {
    return OfflineMatchResultInclude._();
  }

  static OfflineMatchResultIncludeList includeList({
    _isd.WhereExpressionBuilder<OfflineMatchResultTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<OfflineMatchResultTable>? orderBy,
    _isd.OrderByListBuilder<OfflineMatchResultTable>? orderByList,
    OfflineMatchResultInclude? include,
  }) {
    return OfflineMatchResultIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OfflineMatchResult.t),
      orderByList: orderByList?.call(OfflineMatchResult.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OfflineMatchResultImpl extends OfflineMatchResult {
  _OfflineMatchResultImpl({
    _isc.UuidValue? id,
    int? spaceId,
    required _ib5rq0bj.EnumMatchResult result,
    required _ivcfpjgb.EnumBotLevel botLevel,
    required List<int> moves,
    required DateTime playedAt,
    bool? reconciled,
  }) : super._(
         id: id,
         spaceId: spaceId,
         result: result,
         botLevel: botLevel,
         moves: moves,
         playedAt: playedAt,
         reconciled: reconciled,
       );

  /// Returns a shallow copy of this [OfflineMatchResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  OfflineMatchResult copyWith({
    Object? id = _Undefined,
    Object? spaceId = _Undefined,
    _ib5rq0bj.EnumMatchResult? result,
    _ivcfpjgb.EnumBotLevel? botLevel,
    List<int>? moves,
    DateTime? playedAt,
    bool? reconciled,
  }) {
    return OfflineMatchResult(
      id: id is _isc.UuidValue? ? id : this.id,
      spaceId: spaceId is int? ? spaceId : this.spaceId,
      result: result ?? this.result,
      botLevel: botLevel ?? this.botLevel,
      moves: moves ?? this.moves.map((e0) => e0).toList(),
      playedAt: playedAt ?? this.playedAt,
      reconciled: reconciled ?? this.reconciled,
    );
  }
}

class OfflineMatchResultUpdateTable
    extends _isd.UpdateTable<OfflineMatchResultTable> {
  OfflineMatchResultUpdateTable(super.table);

  _isd.ColumnValue<int, int> spaceId(int? value) => _isd.ColumnValue(
    table.spaceId,
    value,
  );

  _isd.ColumnValue<_ib5rq0bj.EnumMatchResult, _ib5rq0bj.EnumMatchResult> result(
    _ib5rq0bj.EnumMatchResult value,
  ) => _isd.ColumnValue(
    table.result,
    value,
  );

  _isd.ColumnValue<_ivcfpjgb.EnumBotLevel, _ivcfpjgb.EnumBotLevel> botLevel(
    _ivcfpjgb.EnumBotLevel value,
  ) => _isd.ColumnValue(
    table.botLevel,
    value,
  );

  _isd.ColumnValue<List<int>, List<int>> moves(List<int> value) =>
      _isd.ColumnValue(
        table.moves,
        value,
      );

  _isd.ColumnValue<DateTime, DateTime> playedAt(DateTime value) =>
      _isd.ColumnValue(
        table.playedAt,
        value,
      );

  _isd.ColumnValue<bool, bool> reconciled(bool value) => _isd.ColumnValue(
    table.reconciled,
    value,
  );
}

class OfflineMatchResultTable extends _isd.Table<_isc.UuidValue?> {
  OfflineMatchResultTable({super.tableRelation})
    : super(tableName: 'offline_match_result') {
    updateTable = OfflineMatchResultUpdateTable(this);
    spaceId = _isd.ColumnInt(
      'spaceId',
      this,
    );
    result = _isd.ColumnEnum(
      'result',
      this,
      _isd.EnumSerialization.byName,
    );
    botLevel = _isd.ColumnEnum(
      'botLevel',
      this,
      _isd.EnumSerialization.byName,
    );
    moves = _isd.ColumnSerializable<List<int>>(
      'moves',
      this,
    );
    playedAt = _isd.ColumnDateTime(
      'playedAt',
      this,
    );
    reconciled = _isd.ColumnBool(
      'reconciled',
      this,
      hasDefault: true,
    );
  }

  late final OfflineMatchResultUpdateTable updateTable;

  /// The space owning this row. Maintained by the sync engine.
  late final _isd.ColumnInt spaceId;

  late final _isd.ColumnEnum<_ib5rq0bj.EnumMatchResult> result;

  late final _isd.ColumnEnum<_ivcfpjgb.EnumBotLevel> botLevel;

  late final _isd.ColumnSerializable<List<int>> moves;

  late final _isd.ColumnDateTime playedAt;

  late final _isd.ColumnBool reconciled;

  @override
  List<_isd.Column> get columns => [
    id,
    spaceId,
    result,
    botLevel,
    moves,
    playedAt,
    reconciled,
  ];
}

class OfflineMatchResultInclude extends _isd.IncludeObject {
  OfflineMatchResultInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue?> get table => OfflineMatchResult.t;
}

class OfflineMatchResultIncludeList extends _isd.IncludeList {
  OfflineMatchResultIncludeList._({
    _isd.WhereExpressionBuilder<OfflineMatchResultTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OfflineMatchResult.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue?> get table => OfflineMatchResult.t;
}

class OfflineMatchResultRepository {
  const OfflineMatchResultRepository._();

  /// Returns a list of [OfflineMatchResult]s matching the given query parameters.
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
  Future<List<OfflineMatchResult>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<OfflineMatchResultTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<OfflineMatchResultTable>? orderBy,
    _isd.OrderByListBuilder<OfflineMatchResultTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<OfflineMatchResult>(
      where: where?.call(OfflineMatchResult.t),
      orderBy: orderBy?.call(OfflineMatchResult.t),
      orderByList: orderByList?.call(OfflineMatchResult.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [OfflineMatchResult] matching the given query parameters.
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
  Future<OfflineMatchResult?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<OfflineMatchResultTable>? where,
    int? offset,
    _isd.OrderByBuilder<OfflineMatchResultTable>? orderBy,
    _isd.OrderByListBuilder<OfflineMatchResultTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<OfflineMatchResult>(
      where: where?.call(OfflineMatchResult.t),
      orderBy: orderBy?.call(OfflineMatchResult.t),
      orderByList: orderByList?.call(OfflineMatchResult.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [OfflineMatchResult] by its [id] or null if no such row exists.
  Future<OfflineMatchResult?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<OfflineMatchResult>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [OfflineMatchResult]s in the list and returns the inserted rows.
  ///
  /// The returned [OfflineMatchResult]s will have their `id` fields set.
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
  Future<List<OfflineMatchResult>> insert(
    _isd.DatabaseSession session,
    List<OfflineMatchResult> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<OfflineMatchResult>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [OfflineMatchResult] and returns the inserted row.
  ///
  /// The returned [OfflineMatchResult] will have its `id` field set.
  Future<OfflineMatchResult> insertRow(
    _isd.DatabaseSession session,
    OfflineMatchResult row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<OfflineMatchResult>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [OfflineMatchResult]s in the list and returns the resulting rows.
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
  /// The returned [OfflineMatchResult]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OfflineMatchResult>> upsert(
    _isd.DatabaseSession session,
    List<OfflineMatchResult> rows, {
    required _isd.ColumnSelections<OfflineMatchResultTable> conflictColumns,
    _isd.ColumnSelections<OfflineMatchResultTable>? updateColumns,
    _isd.WhereExpressionBuilder<OfflineMatchResultTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<OfflineMatchResult>(
      rows,
      conflictColumns: conflictColumns(OfflineMatchResult.t),
      updateColumns: updateColumns?.call(OfflineMatchResult.t),
      updateWhere: updateWhere?.call(OfflineMatchResult.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [OfflineMatchResult] and returns the resulting row.
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
  /// The returned [OfflineMatchResult] will have its `id` field set.
  Future<OfflineMatchResult?> upsertRow(
    _isd.DatabaseSession session,
    OfflineMatchResult row, {
    required _isd.ColumnSelections<OfflineMatchResultTable> conflictColumns,
    _isd.ColumnSelections<OfflineMatchResultTable>? updateColumns,
    _isd.WhereExpressionBuilder<OfflineMatchResultTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<OfflineMatchResult>(
      row,
      conflictColumns: conflictColumns(OfflineMatchResult.t),
      updateColumns: updateColumns?.call(OfflineMatchResult.t),
      updateWhere: updateWhere?.call(OfflineMatchResult.t),
      transaction: transaction,
    );
  }

  /// Updates all [OfflineMatchResult]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OfflineMatchResult>> update(
    _isd.DatabaseSession session,
    List<OfflineMatchResult> rows, {
    _isd.ColumnSelections<OfflineMatchResultTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<OfflineMatchResult>(
      rows,
      columns: columns?.call(OfflineMatchResult.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [OfflineMatchResult]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<OfflineMatchResult> updateRow(
    _isd.DatabaseSession session,
    OfflineMatchResult row, {
    _isd.ColumnSelections<OfflineMatchResultTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<OfflineMatchResult>(
      row,
      columns: columns?.call(OfflineMatchResult.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OfflineMatchResult] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<OfflineMatchResult?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<OfflineMatchResultUpdateTable>
    columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<OfflineMatchResult>(
      id,
      columnValues: columnValues(OfflineMatchResult.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [OfflineMatchResult]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OfflineMatchResult>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<OfflineMatchResultUpdateTable>
    columnValues,
    required _isd.WhereExpressionBuilder<OfflineMatchResultTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<OfflineMatchResultTable>? orderBy,
    _isd.OrderByListBuilder<OfflineMatchResultTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<OfflineMatchResult>(
      columnValues: columnValues(OfflineMatchResult.t.updateTable),
      where: where(OfflineMatchResult.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OfflineMatchResult.t),
      orderByList: orderByList?.call(OfflineMatchResult.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [OfflineMatchResult]s in the list and returns the deleted rows.
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
  Future<List<OfflineMatchResult>> delete(
    _isd.DatabaseSession session,
    List<OfflineMatchResult> rows, {
    _isd.OrderByBuilder<OfflineMatchResultTable>? orderBy,
    _isd.OrderByListBuilder<OfflineMatchResultTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<OfflineMatchResult>(
      rows,
      orderBy: orderBy?.call(OfflineMatchResult.t),
      orderByList: orderByList?.call(OfflineMatchResult.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [OfflineMatchResult].
  Future<OfflineMatchResult> deleteRow(
    _isd.DatabaseSession session,
    OfflineMatchResult row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<OfflineMatchResult>(
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
  Future<List<OfflineMatchResult>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<OfflineMatchResultTable> where,
    _isd.OrderByBuilder<OfflineMatchResultTable>? orderBy,
    _isd.OrderByListBuilder<OfflineMatchResultTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<OfflineMatchResult>(
      where: where(OfflineMatchResult.t),
      orderBy: orderBy?.call(OfflineMatchResult.t),
      orderByList: orderByList?.call(OfflineMatchResult.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<OfflineMatchResultTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<OfflineMatchResult>(
      where: where?.call(OfflineMatchResult.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [OfflineMatchResult] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<OfflineMatchResultTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<OfflineMatchResult>(
      where: where(OfflineMatchResult.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
