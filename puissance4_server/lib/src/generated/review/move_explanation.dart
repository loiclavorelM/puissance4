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

abstract class MoveExplanation
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  MoveExplanation._({
    this.id,
    required this.positionKey,
    required this.language,
    required this.explanation,
    required this.model,
    required this.requestedBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MoveExplanation({
    _is.UuidValue? id,
    required String positionKey,
    required String language,
    required String explanation,
    required String model,
    required _is.UuidValue requestedBy,
    DateTime? createdAt,
  }) = _MoveExplanationImpl;

  factory MoveExplanation.fromJson(Map<String, dynamic> jsonSerialization) {
    return MoveExplanation(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      positionKey: jsonSerialization['positionKey'] as String,
      language: jsonSerialization['language'] as String,
      explanation: jsonSerialization['explanation'] as String,
      model: jsonSerialization['model'] as String,
      requestedBy: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['requestedBy'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = MoveExplanationTable();

  static const db = MoveExplanationRepository._();

  @override
  _is.UuidValue? id;

  String positionKey;

  String language;

  String explanation;

  String model;

  _is.UuidValue requestedBy;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [MoveExplanation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MoveExplanation copyWith({
    _is.UuidValue? id,
    String? positionKey,
    String? language,
    String? explanation,
    String? model,
    _is.UuidValue? requestedBy,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MoveExplanation',
      if (id != null) 'id': id?.toJson(),
      'positionKey': positionKey,
      'language': language,
      'explanation': explanation,
      'model': model,
      'requestedBy': requestedBy.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MoveExplanation',
      if (id != null) 'id': id?.toJson(),
      'positionKey': positionKey,
      'language': language,
      'explanation': explanation,
      'model': model,
      'requestedBy': requestedBy.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static MoveExplanationInclude include() {
    return MoveExplanationInclude._();
  }

  static MoveExplanationIncludeList includeList({
    _is.WhereExpressionBuilder<MoveExplanationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MoveExplanationTable>? orderBy,
    _is.OrderByListBuilder<MoveExplanationTable>? orderByList,
    MoveExplanationInclude? include,
  }) {
    return MoveExplanationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MoveExplanation.t),
      orderByList: orderByList?.call(MoveExplanation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MoveExplanationImpl extends MoveExplanation {
  _MoveExplanationImpl({
    _is.UuidValue? id,
    required String positionKey,
    required String language,
    required String explanation,
    required String model,
    required _is.UuidValue requestedBy,
    DateTime? createdAt,
  }) : super._(
         id: id,
         positionKey: positionKey,
         language: language,
         explanation: explanation,
         model: model,
         requestedBy: requestedBy,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MoveExplanation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MoveExplanation copyWith({
    Object? id = _Undefined,
    String? positionKey,
    String? language,
    String? explanation,
    String? model,
    _is.UuidValue? requestedBy,
    DateTime? createdAt,
  }) {
    return MoveExplanation(
      id: id is _is.UuidValue? ? id : this.id,
      positionKey: positionKey ?? this.positionKey,
      language: language ?? this.language,
      explanation: explanation ?? this.explanation,
      model: model ?? this.model,
      requestedBy: requestedBy ?? this.requestedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MoveExplanationUpdateTable extends _is.UpdateTable<MoveExplanationTable> {
  MoveExplanationUpdateTable(super.table);

  _is.ColumnValue<String, String> positionKey(String value) => _is.ColumnValue(
    table.positionKey,
    value,
  );

  _is.ColumnValue<String, String> language(String value) => _is.ColumnValue(
    table.language,
    value,
  );

  _is.ColumnValue<String, String> explanation(String value) => _is.ColumnValue(
    table.explanation,
    value,
  );

  _is.ColumnValue<String, String> model(String value) => _is.ColumnValue(
    table.model,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> requestedBy(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.requestedBy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class MoveExplanationTable extends _is.Table<_is.UuidValue?> {
  MoveExplanationTable({super.tableRelation})
    : super(tableName: 'move_explanation') {
    updateTable = MoveExplanationUpdateTable(this);
    positionKey = _is.ColumnString(
      'positionKey',
      this,
    );
    language = _is.ColumnString(
      'language',
      this,
    );
    explanation = _is.ColumnString(
      'explanation',
      this,
    );
    model = _is.ColumnString(
      'model',
      this,
    );
    requestedBy = _is.ColumnUuid(
      'requestedBy',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final MoveExplanationUpdateTable updateTable;

  late final _is.ColumnString positionKey;

  late final _is.ColumnString language;

  late final _is.ColumnString explanation;

  late final _is.ColumnString model;

  late final _is.ColumnUuid requestedBy;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    positionKey,
    language,
    explanation,
    model,
    requestedBy,
    createdAt,
  ];
}

class MoveExplanationInclude extends _is.IncludeObject {
  MoveExplanationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => MoveExplanation.t;
}

class MoveExplanationIncludeList extends _is.IncludeList {
  MoveExplanationIncludeList._({
    _is.WhereExpressionBuilder<MoveExplanationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MoveExplanation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => MoveExplanation.t;
}

class MoveExplanationRepository {
  const MoveExplanationRepository._();

  /// Returns a list of [MoveExplanation]s matching the given query parameters.
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
  Future<List<MoveExplanation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MoveExplanationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MoveExplanationTable>? orderBy,
    _is.OrderByListBuilder<MoveExplanationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MoveExplanation>(
      where: where?.call(MoveExplanation.t),
      orderBy: orderBy?.call(MoveExplanation.t),
      orderByList: orderByList?.call(MoveExplanation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MoveExplanation] matching the given query parameters.
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
  Future<MoveExplanation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MoveExplanationTable>? where,
    int? offset,
    _is.OrderByBuilder<MoveExplanationTable>? orderBy,
    _is.OrderByListBuilder<MoveExplanationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MoveExplanation>(
      where: where?.call(MoveExplanation.t),
      orderBy: orderBy?.call(MoveExplanation.t),
      orderByList: orderByList?.call(MoveExplanation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MoveExplanation] by its [id] or null if no such row exists.
  Future<MoveExplanation?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MoveExplanation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MoveExplanation]s in the list and returns the inserted rows.
  ///
  /// The returned [MoveExplanation]s will have their `id` fields set.
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
  Future<List<MoveExplanation>> insert(
    _is.DatabaseSession session,
    List<MoveExplanation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<MoveExplanation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [MoveExplanation] and returns the inserted row.
  ///
  /// The returned [MoveExplanation] will have its `id` field set.
  Future<MoveExplanation> insertRow(
    _is.DatabaseSession session,
    MoveExplanation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<MoveExplanation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [MoveExplanation]s in the list and returns the resulting rows.
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
  /// The returned [MoveExplanation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MoveExplanation>> upsert(
    _is.DatabaseSession session,
    List<MoveExplanation> rows, {
    required _is.ColumnSelections<MoveExplanationTable> conflictColumns,
    _is.ColumnSelections<MoveExplanationTable>? updateColumns,
    _is.WhereExpressionBuilder<MoveExplanationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<MoveExplanation>(
      rows,
      conflictColumns: conflictColumns(MoveExplanation.t),
      updateColumns: updateColumns?.call(MoveExplanation.t),
      updateWhere: updateWhere?.call(MoveExplanation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [MoveExplanation] and returns the resulting row.
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
  /// The returned [MoveExplanation] will have its `id` field set.
  Future<MoveExplanation?> upsertRow(
    _is.DatabaseSession session,
    MoveExplanation row, {
    required _is.ColumnSelections<MoveExplanationTable> conflictColumns,
    _is.ColumnSelections<MoveExplanationTable>? updateColumns,
    _is.WhereExpressionBuilder<MoveExplanationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<MoveExplanation>(
      row,
      conflictColumns: conflictColumns(MoveExplanation.t),
      updateColumns: updateColumns?.call(MoveExplanation.t),
      updateWhere: updateWhere?.call(MoveExplanation.t),
      transaction: transaction,
    );
  }

  /// Updates all [MoveExplanation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MoveExplanation>> update(
    _is.DatabaseSession session,
    List<MoveExplanation> rows, {
    _is.ColumnSelections<MoveExplanationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<MoveExplanation>(
      rows,
      columns: columns?.call(MoveExplanation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [MoveExplanation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MoveExplanation> updateRow(
    _is.DatabaseSession session,
    MoveExplanation row, {
    _is.ColumnSelections<MoveExplanationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<MoveExplanation>(
      row,
      columns: columns?.call(MoveExplanation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MoveExplanation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MoveExplanation?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<MoveExplanationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<MoveExplanation>(
      id,
      columnValues: columnValues(MoveExplanation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MoveExplanation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MoveExplanation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MoveExplanationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<MoveExplanationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MoveExplanationTable>? orderBy,
    _is.OrderByListBuilder<MoveExplanationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<MoveExplanation>(
      columnValues: columnValues(MoveExplanation.t.updateTable),
      where: where(MoveExplanation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MoveExplanation.t),
      orderByList: orderByList?.call(MoveExplanation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [MoveExplanation]s in the list and returns the deleted rows.
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
  Future<List<MoveExplanation>> delete(
    _is.DatabaseSession session,
    List<MoveExplanation> rows, {
    _is.OrderByBuilder<MoveExplanationTable>? orderBy,
    _is.OrderByListBuilder<MoveExplanationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<MoveExplanation>(
      rows,
      orderBy: orderBy?.call(MoveExplanation.t),
      orderByList: orderByList?.call(MoveExplanation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [MoveExplanation].
  Future<MoveExplanation> deleteRow(
    _is.DatabaseSession session,
    MoveExplanation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MoveExplanation>(
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
  Future<List<MoveExplanation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MoveExplanationTable> where,
    _is.OrderByBuilder<MoveExplanationTable>? orderBy,
    _is.OrderByListBuilder<MoveExplanationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<MoveExplanation>(
      where: where(MoveExplanation.t),
      orderBy: orderBy?.call(MoveExplanation.t),
      orderByList: orderByList?.call(MoveExplanation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MoveExplanationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<MoveExplanation>(
      where: where?.call(MoveExplanation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MoveExplanation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MoveExplanationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MoveExplanation>(
      where: where(MoveExplanation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
