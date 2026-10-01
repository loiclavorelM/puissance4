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
import 'package:puissance4_server/src/generated/protocol.dart' as _irho11n9;
import 'package:serverpod/serverpod.dart' as _is;
import '../game/enum_color.dart' as _ik9tqcac;
import '../game/enum_match_result.dart' as _ib5rq0bj;
import '../game/enum_statut.dart' as _irc493lf;

abstract class OfflineMatchResult
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  OfflineMatchResult._({
    this.id,
    this.spaceId,
    required this.status,
    this.result,
    required this.botId,
    required this.botName,
    required this.playedAs,
    required this.moves,
    required this.playedAt,
    bool? reconciled,
  }) : reconciled = reconciled ?? false;

  factory OfflineMatchResult({
    _is.UuidValue? id,
    int? spaceId,
    required _irc493lf.EnumStatut status,
    _ib5rq0bj.EnumMatchResult? result,
    required _is.UuidValue botId,
    required String botName,
    required _ik9tqcac.EnumColor playedAs,
    required List<int> moves,
    required DateTime playedAt,
    bool? reconciled,
  }) = _OfflineMatchResultImpl;

  factory OfflineMatchResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return OfflineMatchResult(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      spaceId: jsonSerialization['spaceId'] as int?,
      status: _irc493lf.EnumStatut.fromJson(
        (jsonSerialization['status'] as String),
      ),
      result: jsonSerialization['result'] == null
          ? null
          : _ib5rq0bj.EnumMatchResult.fromJson(
              (jsonSerialization['result'] as String),
            ),
      botId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['botId']),
      botName: jsonSerialization['botName'] as String,
      playedAs: _ik9tqcac.EnumColor.fromJson(
        (jsonSerialization['playedAs'] as String),
      ),
      moves: _irho11n9.Protocol().deserialize<List<int>>(
        jsonSerialization['moves'],
      ),
      playedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['playedAt'],
      ),
      reconciled: jsonSerialization['reconciled'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['reconciled']),
    );
  }

  static final t = OfflineMatchResultTable();

  static const db = OfflineMatchResultRepository._();

  @override
  _is.UuidValue? id;

  /// The space owning this row. Maintained by the sync engine.
  int? spaceId;

  _irc493lf.EnumStatut status;

  _ib5rq0bj.EnumMatchResult? result;

  _is.UuidValue botId;

  String botName;

  _ik9tqcac.EnumColor playedAs;

  List<int> moves;

  DateTime playedAt;

  bool reconciled;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [OfflineMatchResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  OfflineMatchResult copyWith({
    _is.UuidValue? id,
    int? spaceId,
    _irc493lf.EnumStatut? status,
    _ib5rq0bj.EnumMatchResult? result,
    _is.UuidValue? botId,
    String? botName,
    _ik9tqcac.EnumColor? playedAs,
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
      'status': status.toJson(),
      if (result != null) 'result': result?.toJson(),
      'botId': botId.toJson(),
      'botName': botName,
      'playedAs': playedAs.toJson(),
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
      'status': status.toJson(),
      if (result != null) 'result': result?.toJson(),
      'botId': botId.toJson(),
      'botName': botName,
      'playedAs': playedAs.toJson(),
      'moves': moves.toJson(),
      'playedAt': playedAt.toJson(),
      'reconciled': reconciled,
    };
  }

  static OfflineMatchResultInclude include() {
    return OfflineMatchResultInclude._();
  }

  static OfflineMatchResultIncludeList includeList({
    _is.WhereExpressionBuilder<OfflineMatchResultTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OfflineMatchResultTable>? orderBy,
    _is.OrderByListBuilder<OfflineMatchResultTable>? orderByList,
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
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OfflineMatchResultImpl extends OfflineMatchResult {
  _OfflineMatchResultImpl({
    _is.UuidValue? id,
    int? spaceId,
    required _irc493lf.EnumStatut status,
    _ib5rq0bj.EnumMatchResult? result,
    required _is.UuidValue botId,
    required String botName,
    required _ik9tqcac.EnumColor playedAs,
    required List<int> moves,
    required DateTime playedAt,
    bool? reconciled,
  }) : super._(
         id: id,
         spaceId: spaceId,
         status: status,
         result: result,
         botId: botId,
         botName: botName,
         playedAs: playedAs,
         moves: moves,
         playedAt: playedAt,
         reconciled: reconciled,
       );

  /// Returns a shallow copy of this [OfflineMatchResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  OfflineMatchResult copyWith({
    Object? id = _Undefined,
    Object? spaceId = _Undefined,
    _irc493lf.EnumStatut? status,
    Object? result = _Undefined,
    _is.UuidValue? botId,
    String? botName,
    _ik9tqcac.EnumColor? playedAs,
    List<int>? moves,
    DateTime? playedAt,
    bool? reconciled,
  }) {
    return OfflineMatchResult(
      id: id is _is.UuidValue? ? id : this.id,
      spaceId: spaceId is int? ? spaceId : this.spaceId,
      status: status ?? this.status,
      result: result is _ib5rq0bj.EnumMatchResult? ? result : this.result,
      botId: botId ?? this.botId,
      botName: botName ?? this.botName,
      playedAs: playedAs ?? this.playedAs,
      moves: moves ?? this.moves.map((e0) => e0).toList(),
      playedAt: playedAt ?? this.playedAt,
      reconciled: reconciled ?? this.reconciled,
    );
  }
}

class OfflineMatchResultUpdateTable
    extends _is.UpdateTable<OfflineMatchResultTable> {
  OfflineMatchResultUpdateTable(super.table);

  _is.ColumnValue<int, int> spaceId(int? value) => _is.ColumnValue(
    table.spaceId,
    value,
  );

  _is.ColumnValue<_irc493lf.EnumStatut, _irc493lf.EnumStatut> status(
    _irc493lf.EnumStatut value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<_ib5rq0bj.EnumMatchResult, _ib5rq0bj.EnumMatchResult> result(
    _ib5rq0bj.EnumMatchResult? value,
  ) => _is.ColumnValue(
    table.result,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> botId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.botId,
        value,
      );

  _is.ColumnValue<String, String> botName(String value) => _is.ColumnValue(
    table.botName,
    value,
  );

  _is.ColumnValue<_ik9tqcac.EnumColor, _ik9tqcac.EnumColor> playedAs(
    _ik9tqcac.EnumColor value,
  ) => _is.ColumnValue(
    table.playedAs,
    value,
  );

  _is.ColumnValue<List<int>, List<int>> moves(List<int> value) =>
      _is.ColumnValue(
        table.moves,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> playedAt(DateTime value) =>
      _is.ColumnValue(
        table.playedAt,
        value,
      );

  _is.ColumnValue<bool, bool> reconciled(bool value) => _is.ColumnValue(
    table.reconciled,
    value,
  );
}

class OfflineMatchResultTable extends _is.Table<_is.UuidValue?> {
  OfflineMatchResultTable({super.tableRelation})
    : super(tableName: 'offline_match_result') {
    updateTable = OfflineMatchResultUpdateTable(this);
    spaceId = _is.ColumnInt(
      'spaceId',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    result = _is.ColumnEnum(
      'result',
      this,
      _is.EnumSerialization.byName,
    );
    botId = _is.ColumnUuid(
      'botId',
      this,
    );
    botName = _is.ColumnString(
      'botName',
      this,
    );
    playedAs = _is.ColumnEnum(
      'playedAs',
      this,
      _is.EnumSerialization.byName,
    );
    moves = _is.ColumnSerializable<List<int>>(
      'moves',
      this,
    );
    playedAt = _is.ColumnDateTime(
      'playedAt',
      this,
    );
    reconciled = _is.ColumnBool(
      'reconciled',
      this,
      hasDefault: true,
    );
  }

  late final OfflineMatchResultUpdateTable updateTable;

  /// The space owning this row. Maintained by the sync engine.
  late final _is.ColumnInt spaceId;

  late final _is.ColumnEnum<_irc493lf.EnumStatut> status;

  late final _is.ColumnEnum<_ib5rq0bj.EnumMatchResult> result;

  late final _is.ColumnUuid botId;

  late final _is.ColumnString botName;

  late final _is.ColumnEnum<_ik9tqcac.EnumColor> playedAs;

  late final _is.ColumnSerializable<List<int>> moves;

  late final _is.ColumnDateTime playedAt;

  late final _is.ColumnBool reconciled;

  @override
  List<_is.Column> get columns => [
    id,
    spaceId,
    status,
    result,
    botId,
    botName,
    playedAs,
    moves,
    playedAt,
    reconciled,
  ];
}

class OfflineMatchResultInclude extends _is.IncludeObject {
  OfflineMatchResultInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => OfflineMatchResult.t;
}

class OfflineMatchResultIncludeList extends _is.IncludeList {
  OfflineMatchResultIncludeList._({
    _is.WhereExpressionBuilder<OfflineMatchResultTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OfflineMatchResult.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => OfflineMatchResult.t;
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OfflineMatchResultTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OfflineMatchResultTable>? orderBy,
    _is.OrderByListBuilder<OfflineMatchResultTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OfflineMatchResultTable>? where,
    int? offset,
    _is.OrderByBuilder<OfflineMatchResultTable>? orderBy,
    _is.OrderByListBuilder<OfflineMatchResultTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session,
    List<OfflineMatchResult> rows, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    OfflineMatchResult row, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<OfflineMatchResult> rows, {
    required _is.ColumnSelections<OfflineMatchResultTable> conflictColumns,
    _is.ColumnSelections<OfflineMatchResultTable>? updateColumns,
    _is.WhereExpressionBuilder<OfflineMatchResultTable>? updateWhere,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    OfflineMatchResult row, {
    required _is.ColumnSelections<OfflineMatchResultTable> conflictColumns,
    _is.ColumnSelections<OfflineMatchResultTable>? updateColumns,
    _is.WhereExpressionBuilder<OfflineMatchResultTable>? updateWhere,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<OfflineMatchResult> rows, {
    _is.ColumnSelections<OfflineMatchResultTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    OfflineMatchResult row, {
    _is.ColumnSelections<OfflineMatchResultTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<OfflineMatchResultUpdateTable>
    columnValues,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<OfflineMatchResultUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<OfflineMatchResultTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OfflineMatchResultTable>? orderBy,
    _is.OrderByListBuilder<OfflineMatchResultTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<OfflineMatchResult> rows, {
    _is.OrderByBuilder<OfflineMatchResultTable>? orderBy,
    _is.OrderByListBuilder<OfflineMatchResultTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    OfflineMatchResult row, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OfflineMatchResultTable> where,
    _is.OrderByBuilder<OfflineMatchResultTable>? orderBy,
    _is.OrderByListBuilder<OfflineMatchResultTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OfflineMatchResultTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<OfflineMatchResult>(
      where: where?.call(OfflineMatchResult.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [OfflineMatchResult] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OfflineMatchResultTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<OfflineMatchResult>(
      where: where(OfflineMatchResult.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
