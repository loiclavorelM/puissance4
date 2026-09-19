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

abstract class Bot
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Bot._({
    this.id,
    required this.botName,
    required this.elo,
    required this.pathModel,
    required this.description,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Bot({
    _is.UuidValue? id,
    required String botName,
    required int elo,
    required String pathModel,
    required String description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BotImpl;

  factory Bot.fromJson(Map<String, dynamic> jsonSerialization) {
    return Bot(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      botName: jsonSerialization['botName'] as String,
      elo: jsonSerialization['elo'] as int,
      pathModel: jsonSerialization['pathModel'] as String,
      description: jsonSerialization['description'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = BotTable();

  static const db = BotRepository._();

  @override
  _is.UuidValue? id;

  String botName;

  int elo;

  String pathModel;

  String description;

  DateTime createdAt;

  DateTime? updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Bot]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Bot copyWith({
    _is.UuidValue? id,
    String? botName,
    int? elo,
    String? pathModel,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Bot',
      if (id != null) 'id': id?.toJson(),
      'botName': botName,
      'elo': elo,
      'pathModel': pathModel,
      'description': description,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Bot',
      if (id != null) 'id': id?.toJson(),
      'botName': botName,
      'elo': elo,
      'pathModel': pathModel,
      'description': description,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static BotInclude include() {
    return BotInclude._();
  }

  static BotIncludeList includeList({
    _is.WhereExpressionBuilder<BotTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BotTable>? orderBy,
    _is.OrderByListBuilder<BotTable>? orderByList,
    BotInclude? include,
  }) {
    return BotIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Bot.t),
      orderByList: orderByList?.call(Bot.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BotImpl extends Bot {
  _BotImpl({
    _is.UuidValue? id,
    required String botName,
    required int elo,
    required String pathModel,
    required String description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         botName: botName,
         elo: elo,
         pathModel: pathModel,
         description: description,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Bot]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Bot copyWith({
    Object? id = _Undefined,
    String? botName,
    int? elo,
    String? pathModel,
    String? description,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return Bot(
      id: id is _is.UuidValue? ? id : this.id,
      botName: botName ?? this.botName,
      elo: elo ?? this.elo,
      pathModel: pathModel ?? this.pathModel,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class BotUpdateTable extends _is.UpdateTable<BotTable> {
  BotUpdateTable(super.table);

  _is.ColumnValue<String, String> botName(String value) => _is.ColumnValue(
    table.botName,
    value,
  );

  _is.ColumnValue<int, int> elo(int value) => _is.ColumnValue(
    table.elo,
    value,
  );

  _is.ColumnValue<String, String> pathModel(String value) => _is.ColumnValue(
    table.pathModel,
    value,
  );

  _is.ColumnValue<String, String> description(String value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime? value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class BotTable extends _is.Table<_is.UuidValue?> {
  BotTable({super.tableRelation}) : super(tableName: 'bot') {
    updateTable = BotUpdateTable(this);
    botName = _is.ColumnString(
      'botName',
      this,
    );
    elo = _is.ColumnInt(
      'elo',
      this,
    );
    pathModel = _is.ColumnString(
      'pathModel',
      this,
    );
    description = _is.ColumnString(
      'description',
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
    );
  }

  late final BotUpdateTable updateTable;

  late final _is.ColumnString botName;

  late final _is.ColumnInt elo;

  late final _is.ColumnString pathModel;

  late final _is.ColumnString description;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    botName,
    elo,
    pathModel,
    description,
    createdAt,
    updatedAt,
  ];
}

class BotInclude extends _is.IncludeObject {
  BotInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Bot.t;
}

class BotIncludeList extends _is.IncludeList {
  BotIncludeList._({
    _is.WhereExpressionBuilder<BotTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Bot.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Bot.t;
}

class BotRepository {
  const BotRepository._();

  /// Returns a list of [Bot]s matching the given query parameters.
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
  Future<List<Bot>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BotTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BotTable>? orderBy,
    _is.OrderByListBuilder<BotTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Bot>(
      where: where?.call(Bot.t),
      orderBy: orderBy?.call(Bot.t),
      orderByList: orderByList?.call(Bot.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Bot] matching the given query parameters.
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
  Future<Bot?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BotTable>? where,
    int? offset,
    _is.OrderByBuilder<BotTable>? orderBy,
    _is.OrderByListBuilder<BotTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Bot>(
      where: where?.call(Bot.t),
      orderBy: orderBy?.call(Bot.t),
      orderByList: orderByList?.call(Bot.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Bot] by its [id] or null if no such row exists.
  Future<Bot?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Bot>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Bot]s in the list and returns the inserted rows.
  ///
  /// The returned [Bot]s will have their `id` fields set.
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
  Future<List<Bot>> insert(
    _is.DatabaseSession session,
    List<Bot> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Bot>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Bot] and returns the inserted row.
  ///
  /// The returned [Bot] will have its `id` field set.
  Future<Bot> insertRow(
    _is.DatabaseSession session,
    Bot row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Bot>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Bot]s in the list and returns the resulting rows.
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
  /// The returned [Bot]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Bot>> upsert(
    _is.DatabaseSession session,
    List<Bot> rows, {
    required _is.ColumnSelections<BotTable> conflictColumns,
    _is.ColumnSelections<BotTable>? updateColumns,
    _is.WhereExpressionBuilder<BotTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Bot>(
      rows,
      conflictColumns: conflictColumns(Bot.t),
      updateColumns: updateColumns?.call(Bot.t),
      updateWhere: updateWhere?.call(Bot.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Bot] and returns the resulting row.
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
  /// The returned [Bot] will have its `id` field set.
  Future<Bot?> upsertRow(
    _is.DatabaseSession session,
    Bot row, {
    required _is.ColumnSelections<BotTable> conflictColumns,
    _is.ColumnSelections<BotTable>? updateColumns,
    _is.WhereExpressionBuilder<BotTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Bot>(
      row,
      conflictColumns: conflictColumns(Bot.t),
      updateColumns: updateColumns?.call(Bot.t),
      updateWhere: updateWhere?.call(Bot.t),
      transaction: transaction,
    );
  }

  /// Updates all [Bot]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Bot>> update(
    _is.DatabaseSession session,
    List<Bot> rows, {
    _is.ColumnSelections<BotTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Bot>(
      rows,
      columns: columns?.call(Bot.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Bot]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Bot> updateRow(
    _is.DatabaseSession session,
    Bot row, {
    _is.ColumnSelections<BotTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Bot>(
      row,
      columns: columns?.call(Bot.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Bot] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Bot?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<BotUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Bot>(
      id,
      columnValues: columnValues(Bot.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Bot]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Bot>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<BotUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<BotTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BotTable>? orderBy,
    _is.OrderByListBuilder<BotTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Bot>(
      columnValues: columnValues(Bot.t.updateTable),
      where: where(Bot.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Bot.t),
      orderByList: orderByList?.call(Bot.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Bot]s in the list and returns the deleted rows.
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
  Future<List<Bot>> delete(
    _is.DatabaseSession session,
    List<Bot> rows, {
    _is.OrderByBuilder<BotTable>? orderBy,
    _is.OrderByListBuilder<BotTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Bot>(
      rows,
      orderBy: orderBy?.call(Bot.t),
      orderByList: orderByList?.call(Bot.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Bot].
  Future<Bot> deleteRow(
    _is.DatabaseSession session,
    Bot row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Bot>(
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
  Future<List<Bot>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BotTable> where,
    _is.OrderByBuilder<BotTable>? orderBy,
    _is.OrderByListBuilder<BotTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Bot>(
      where: where(Bot.t),
      orderBy: orderBy?.call(Bot.t),
      orderByList: orderByList?.call(Bot.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BotTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Bot>(
      where: where?.call(Bot.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Bot] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BotTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Bot>(
      where: where(Bot.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
