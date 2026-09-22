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
import '../game/enum_outcome.dart' as _ilk7rg3u;
import '../game/enum_statut.dart' as _irc493lf;
import '../game/enum_type.dart' as _iu5mz6ho;

abstract class Partie
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Partie._({
    this.id,
    this.code,
    required this.typePartie,
    required this.playerRougeId,
    required this.playerJauneId,
    this.winner,
    required this.status,
    required this.moves,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Partie({
    _is.UuidValue? id,
    String? code,
    required _iu5mz6ho.EnumType typePartie,
    required _is.UuidValue playerRougeId,
    required _is.UuidValue playerJauneId,
    _ilk7rg3u.EnumOutcome? winner,
    required _irc493lf.EnumStatut status,
    required List<int> moves,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PartieImpl;

  factory Partie.fromJson(Map<String, dynamic> jsonSerialization) {
    return Partie(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      code: jsonSerialization['code'] as String?,
      typePartie: _iu5mz6ho.EnumType.fromJson(
        (jsonSerialization['typePartie'] as String),
      ),
      playerRougeId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['playerRougeId'],
      ),
      playerJauneId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['playerJauneId'],
      ),
      winner: jsonSerialization['winner'] == null
          ? null
          : _ilk7rg3u.EnumOutcome.fromJson(
              (jsonSerialization['winner'] as String),
            ),
      status: _irc493lf.EnumStatut.fromJson(
        (jsonSerialization['status'] as String),
      ),
      moves: _irho11n9.Protocol().deserialize<List<int>>(
        jsonSerialization['moves'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = PartieTable();

  static const db = PartieRepository._();

  @override
  _is.UuidValue? id;

  String? code;

  _iu5mz6ho.EnumType typePartie;

  _is.UuidValue playerRougeId;

  _is.UuidValue playerJauneId;

  _ilk7rg3u.EnumOutcome? winner;

  _irc493lf.EnumStatut status;

  List<int> moves;

  DateTime createdAt;

  DateTime? updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Partie]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Partie copyWith({
    _is.UuidValue? id,
    String? code,
    _iu5mz6ho.EnumType? typePartie,
    _is.UuidValue? playerRougeId,
    _is.UuidValue? playerJauneId,
    _ilk7rg3u.EnumOutcome? winner,
    _irc493lf.EnumStatut? status,
    List<int>? moves,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Partie',
      if (id != null) 'id': id?.toJson(),
      if (code != null) 'code': code,
      'typePartie': typePartie.toJson(),
      'playerRougeId': playerRougeId.toJson(),
      'playerJauneId': playerJauneId.toJson(),
      if (winner != null) 'winner': winner?.toJson(),
      'status': status.toJson(),
      'moves': moves.toJson(),
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Partie',
      if (id != null) 'id': id?.toJson(),
      if (code != null) 'code': code,
      'typePartie': typePartie.toJson(),
      'playerRougeId': playerRougeId.toJson(),
      'playerJauneId': playerJauneId.toJson(),
      if (winner != null) 'winner': winner?.toJson(),
      'status': status.toJson(),
      'moves': moves.toJson(),
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static PartieInclude include() {
    return PartieInclude._();
  }

  static PartieIncludeList includeList({
    _is.WhereExpressionBuilder<PartieTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PartieTable>? orderBy,
    _is.OrderByListBuilder<PartieTable>? orderByList,
    PartieInclude? include,
  }) {
    return PartieIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Partie.t),
      orderByList: orderByList?.call(Partie.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PartieImpl extends Partie {
  _PartieImpl({
    _is.UuidValue? id,
    String? code,
    required _iu5mz6ho.EnumType typePartie,
    required _is.UuidValue playerRougeId,
    required _is.UuidValue playerJauneId,
    _ilk7rg3u.EnumOutcome? winner,
    required _irc493lf.EnumStatut status,
    required List<int> moves,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         code: code,
         typePartie: typePartie,
         playerRougeId: playerRougeId,
         playerJauneId: playerJauneId,
         winner: winner,
         status: status,
         moves: moves,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Partie]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Partie copyWith({
    Object? id = _Undefined,
    Object? code = _Undefined,
    _iu5mz6ho.EnumType? typePartie,
    _is.UuidValue? playerRougeId,
    _is.UuidValue? playerJauneId,
    Object? winner = _Undefined,
    _irc493lf.EnumStatut? status,
    List<int>? moves,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return Partie(
      id: id is _is.UuidValue? ? id : this.id,
      code: code is String? ? code : this.code,
      typePartie: typePartie ?? this.typePartie,
      playerRougeId: playerRougeId ?? this.playerRougeId,
      playerJauneId: playerJauneId ?? this.playerJauneId,
      winner: winner is _ilk7rg3u.EnumOutcome? ? winner : this.winner,
      status: status ?? this.status,
      moves: moves ?? this.moves.map((e0) => e0).toList(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class PartieUpdateTable extends _is.UpdateTable<PartieTable> {
  PartieUpdateTable(super.table);

  _is.ColumnValue<String, String> code(String? value) => _is.ColumnValue(
    table.code,
    value,
  );

  _is.ColumnValue<_iu5mz6ho.EnumType, _iu5mz6ho.EnumType> typePartie(
    _iu5mz6ho.EnumType value,
  ) => _is.ColumnValue(
    table.typePartie,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> playerRougeId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.playerRougeId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> playerJauneId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.playerJauneId,
    value,
  );

  _is.ColumnValue<_ilk7rg3u.EnumOutcome, _ilk7rg3u.EnumOutcome> winner(
    _ilk7rg3u.EnumOutcome? value,
  ) => _is.ColumnValue(
    table.winner,
    value,
  );

  _is.ColumnValue<_irc493lf.EnumStatut, _irc493lf.EnumStatut> status(
    _irc493lf.EnumStatut value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<List<int>, List<int>> moves(List<int> value) =>
      _is.ColumnValue(
        table.moves,
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

class PartieTable extends _is.Table<_is.UuidValue?> {
  PartieTable({super.tableRelation}) : super(tableName: 'partie') {
    updateTable = PartieUpdateTable(this);
    code = _is.ColumnString(
      'code',
      this,
    );
    typePartie = _is.ColumnEnum(
      'typePartie',
      this,
      _is.EnumSerialization.byName,
    );
    playerRougeId = _is.ColumnUuid(
      'playerRougeId',
      this,
    );
    playerJauneId = _is.ColumnUuid(
      'playerJauneId',
      this,
    );
    winner = _is.ColumnEnum(
      'winner',
      this,
      _is.EnumSerialization.byName,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    moves = _is.ColumnSerializable<List<int>>(
      'moves',
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

  late final PartieUpdateTable updateTable;

  late final _is.ColumnString code;

  late final _is.ColumnEnum<_iu5mz6ho.EnumType> typePartie;

  late final _is.ColumnUuid playerRougeId;

  late final _is.ColumnUuid playerJauneId;

  late final _is.ColumnEnum<_ilk7rg3u.EnumOutcome> winner;

  late final _is.ColumnEnum<_irc493lf.EnumStatut> status;

  late final _is.ColumnSerializable<List<int>> moves;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    code,
    typePartie,
    playerRougeId,
    playerJauneId,
    winner,
    status,
    moves,
    createdAt,
    updatedAt,
  ];
}

class PartieInclude extends _is.IncludeObject {
  PartieInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Partie.t;
}

class PartieIncludeList extends _is.IncludeList {
  PartieIncludeList._({
    _is.WhereExpressionBuilder<PartieTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Partie.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Partie.t;
}

class PartieRepository {
  const PartieRepository._();

  /// Returns a list of [Partie]s matching the given query parameters.
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
  Future<List<Partie>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PartieTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PartieTable>? orderBy,
    _is.OrderByListBuilder<PartieTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Partie>(
      where: where?.call(Partie.t),
      orderBy: orderBy?.call(Partie.t),
      orderByList: orderByList?.call(Partie.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Partie] matching the given query parameters.
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
  Future<Partie?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PartieTable>? where,
    int? offset,
    _is.OrderByBuilder<PartieTable>? orderBy,
    _is.OrderByListBuilder<PartieTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Partie>(
      where: where?.call(Partie.t),
      orderBy: orderBy?.call(Partie.t),
      orderByList: orderByList?.call(Partie.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Partie] by its [id] or null if no such row exists.
  Future<Partie?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Partie>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Partie]s in the list and returns the inserted rows.
  ///
  /// The returned [Partie]s will have their `id` fields set.
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
  Future<List<Partie>> insert(
    _is.DatabaseSession session,
    List<Partie> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Partie>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Partie] and returns the inserted row.
  ///
  /// The returned [Partie] will have its `id` field set.
  Future<Partie> insertRow(
    _is.DatabaseSession session,
    Partie row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Partie>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Partie]s in the list and returns the resulting rows.
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
  /// The returned [Partie]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Partie>> upsert(
    _is.DatabaseSession session,
    List<Partie> rows, {
    required _is.ColumnSelections<PartieTable> conflictColumns,
    _is.ColumnSelections<PartieTable>? updateColumns,
    _is.WhereExpressionBuilder<PartieTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Partie>(
      rows,
      conflictColumns: conflictColumns(Partie.t),
      updateColumns: updateColumns?.call(Partie.t),
      updateWhere: updateWhere?.call(Partie.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Partie] and returns the resulting row.
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
  /// The returned [Partie] will have its `id` field set.
  Future<Partie?> upsertRow(
    _is.DatabaseSession session,
    Partie row, {
    required _is.ColumnSelections<PartieTable> conflictColumns,
    _is.ColumnSelections<PartieTable>? updateColumns,
    _is.WhereExpressionBuilder<PartieTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Partie>(
      row,
      conflictColumns: conflictColumns(Partie.t),
      updateColumns: updateColumns?.call(Partie.t),
      updateWhere: updateWhere?.call(Partie.t),
      transaction: transaction,
    );
  }

  /// Updates all [Partie]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Partie>> update(
    _is.DatabaseSession session,
    List<Partie> rows, {
    _is.ColumnSelections<PartieTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Partie>(
      rows,
      columns: columns?.call(Partie.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Partie]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Partie> updateRow(
    _is.DatabaseSession session,
    Partie row, {
    _is.ColumnSelections<PartieTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Partie>(
      row,
      columns: columns?.call(Partie.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Partie] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Partie?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<PartieUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Partie>(
      id,
      columnValues: columnValues(Partie.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Partie]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Partie>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PartieUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PartieTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PartieTable>? orderBy,
    _is.OrderByListBuilder<PartieTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Partie>(
      columnValues: columnValues(Partie.t.updateTable),
      where: where(Partie.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Partie.t),
      orderByList: orderByList?.call(Partie.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Partie]s in the list and returns the deleted rows.
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
  Future<List<Partie>> delete(
    _is.DatabaseSession session,
    List<Partie> rows, {
    _is.OrderByBuilder<PartieTable>? orderBy,
    _is.OrderByListBuilder<PartieTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Partie>(
      rows,
      orderBy: orderBy?.call(Partie.t),
      orderByList: orderByList?.call(Partie.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Partie].
  Future<Partie> deleteRow(
    _is.DatabaseSession session,
    Partie row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Partie>(
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
  Future<List<Partie>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PartieTable> where,
    _is.OrderByBuilder<PartieTable>? orderBy,
    _is.OrderByListBuilder<PartieTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Partie>(
      where: where(Partie.t),
      orderBy: orderBy?.call(Partie.t),
      orderByList: orderByList?.call(Partie.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PartieTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Partie>(
      where: where?.call(Partie.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Partie] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PartieTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Partie>(
      where: where(Partie.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
