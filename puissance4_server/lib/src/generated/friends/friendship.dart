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
import '../friends/enum_friendship_status.dart' as _ipfdbv44;

abstract class Friendship
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Friendship._({
    this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.pairKey,
    required this.status,
    DateTime? createdAt,
    this.respondedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Friendship({
    _is.UuidValue? id,
    required _is.UuidValue requesterId,
    required _is.UuidValue addresseeId,
    required String pairKey,
    required _ipfdbv44.EnumFriendshipStatus status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) = _FriendshipImpl;

  factory Friendship.fromJson(Map<String, dynamic> jsonSerialization) {
    return Friendship(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      requesterId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['requesterId'],
      ),
      addresseeId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['addresseeId'],
      ),
      pairKey: jsonSerialization['pairKey'] as String,
      status: _ipfdbv44.EnumFriendshipStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      respondedAt: jsonSerialization['respondedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['respondedAt'],
            ),
    );
  }

  static final t = FriendshipTable();

  static const db = FriendshipRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue requesterId;

  _is.UuidValue addresseeId;

  String pairKey;

  _ipfdbv44.EnumFriendshipStatus status;

  DateTime createdAt;

  DateTime? respondedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Friendship]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Friendship copyWith({
    _is.UuidValue? id,
    _is.UuidValue? requesterId,
    _is.UuidValue? addresseeId,
    String? pairKey,
    _ipfdbv44.EnumFriendshipStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Friendship',
      if (id != null) 'id': id?.toJson(),
      'requesterId': requesterId.toJson(),
      'addresseeId': addresseeId.toJson(),
      'pairKey': pairKey,
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
      if (respondedAt != null) 'respondedAt': respondedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Friendship',
      if (id != null) 'id': id?.toJson(),
      'requesterId': requesterId.toJson(),
      'addresseeId': addresseeId.toJson(),
      'pairKey': pairKey,
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
      if (respondedAt != null) 'respondedAt': respondedAt?.toJson(),
    };
  }

  static FriendshipInclude include() {
    return FriendshipInclude._();
  }

  static FriendshipIncludeList includeList({
    _is.WhereExpressionBuilder<FriendshipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FriendshipTable>? orderBy,
    _is.OrderByListBuilder<FriendshipTable>? orderByList,
    FriendshipInclude? include,
  }) {
    return FriendshipIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Friendship.t),
      orderByList: orderByList?.call(Friendship.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FriendshipImpl extends Friendship {
  _FriendshipImpl({
    _is.UuidValue? id,
    required _is.UuidValue requesterId,
    required _is.UuidValue addresseeId,
    required String pairKey,
    required _ipfdbv44.EnumFriendshipStatus status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) : super._(
         id: id,
         requesterId: requesterId,
         addresseeId: addresseeId,
         pairKey: pairKey,
         status: status,
         createdAt: createdAt,
         respondedAt: respondedAt,
       );

  /// Returns a shallow copy of this [Friendship]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Friendship copyWith({
    Object? id = _Undefined,
    _is.UuidValue? requesterId,
    _is.UuidValue? addresseeId,
    String? pairKey,
    _ipfdbv44.EnumFriendshipStatus? status,
    DateTime? createdAt,
    Object? respondedAt = _Undefined,
  }) {
    return Friendship(
      id: id is _is.UuidValue? ? id : this.id,
      requesterId: requesterId ?? this.requesterId,
      addresseeId: addresseeId ?? this.addresseeId,
      pairKey: pairKey ?? this.pairKey,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt is DateTime? ? respondedAt : this.respondedAt,
    );
  }
}

class FriendshipUpdateTable extends _is.UpdateTable<FriendshipTable> {
  FriendshipUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> requesterId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.requesterId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> addresseeId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.addresseeId,
    value,
  );

  _is.ColumnValue<String, String> pairKey(String value) => _is.ColumnValue(
    table.pairKey,
    value,
  );

  _is.ColumnValue<
    _ipfdbv44.EnumFriendshipStatus,
    _ipfdbv44.EnumFriendshipStatus
  >
  status(_ipfdbv44.EnumFriendshipStatus value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> respondedAt(DateTime? value) =>
      _is.ColumnValue(
        table.respondedAt,
        value,
      );
}

class FriendshipTable extends _is.Table<_is.UuidValue?> {
  FriendshipTable({super.tableRelation}) : super(tableName: 'friendship') {
    updateTable = FriendshipUpdateTable(this);
    requesterId = _is.ColumnUuid(
      'requesterId',
      this,
    );
    addresseeId = _is.ColumnUuid(
      'addresseeId',
      this,
    );
    pairKey = _is.ColumnString(
      'pairKey',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    respondedAt = _is.ColumnDateTime(
      'respondedAt',
      this,
    );
  }

  late final FriendshipUpdateTable updateTable;

  late final _is.ColumnUuid requesterId;

  late final _is.ColumnUuid addresseeId;

  late final _is.ColumnString pairKey;

  late final _is.ColumnEnum<_ipfdbv44.EnumFriendshipStatus> status;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime respondedAt;

  @override
  List<_is.Column> get columns => [
    id,
    requesterId,
    addresseeId,
    pairKey,
    status,
    createdAt,
    respondedAt,
  ];
}

class FriendshipInclude extends _is.IncludeObject {
  FriendshipInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Friendship.t;
}

class FriendshipIncludeList extends _is.IncludeList {
  FriendshipIncludeList._({
    _is.WhereExpressionBuilder<FriendshipTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Friendship.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Friendship.t;
}

class FriendshipRepository {
  const FriendshipRepository._();

  /// Returns a list of [Friendship]s matching the given query parameters.
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
  Future<List<Friendship>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FriendshipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FriendshipTable>? orderBy,
    _is.OrderByListBuilder<FriendshipTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Friendship>(
      where: where?.call(Friendship.t),
      orderBy: orderBy?.call(Friendship.t),
      orderByList: orderByList?.call(Friendship.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Friendship] matching the given query parameters.
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
  Future<Friendship?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FriendshipTable>? where,
    int? offset,
    _is.OrderByBuilder<FriendshipTable>? orderBy,
    _is.OrderByListBuilder<FriendshipTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Friendship>(
      where: where?.call(Friendship.t),
      orderBy: orderBy?.call(Friendship.t),
      orderByList: orderByList?.call(Friendship.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Friendship] by its [id] or null if no such row exists.
  Future<Friendship?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Friendship>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Friendship]s in the list and returns the inserted rows.
  ///
  /// The returned [Friendship]s will have their `id` fields set.
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
  Future<List<Friendship>> insert(
    _is.DatabaseSession session,
    List<Friendship> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Friendship>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Friendship] and returns the inserted row.
  ///
  /// The returned [Friendship] will have its `id` field set.
  Future<Friendship> insertRow(
    _is.DatabaseSession session,
    Friendship row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Friendship>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Friendship]s in the list and returns the resulting rows.
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
  /// The returned [Friendship]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Friendship>> upsert(
    _is.DatabaseSession session,
    List<Friendship> rows, {
    required _is.ColumnSelections<FriendshipTable> conflictColumns,
    _is.ColumnSelections<FriendshipTable>? updateColumns,
    _is.WhereExpressionBuilder<FriendshipTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Friendship>(
      rows,
      conflictColumns: conflictColumns(Friendship.t),
      updateColumns: updateColumns?.call(Friendship.t),
      updateWhere: updateWhere?.call(Friendship.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Friendship] and returns the resulting row.
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
  /// The returned [Friendship] will have its `id` field set.
  Future<Friendship?> upsertRow(
    _is.DatabaseSession session,
    Friendship row, {
    required _is.ColumnSelections<FriendshipTable> conflictColumns,
    _is.ColumnSelections<FriendshipTable>? updateColumns,
    _is.WhereExpressionBuilder<FriendshipTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Friendship>(
      row,
      conflictColumns: conflictColumns(Friendship.t),
      updateColumns: updateColumns?.call(Friendship.t),
      updateWhere: updateWhere?.call(Friendship.t),
      transaction: transaction,
    );
  }

  /// Updates all [Friendship]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Friendship>> update(
    _is.DatabaseSession session,
    List<Friendship> rows, {
    _is.ColumnSelections<FriendshipTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Friendship>(
      rows,
      columns: columns?.call(Friendship.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Friendship]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Friendship> updateRow(
    _is.DatabaseSession session,
    Friendship row, {
    _is.ColumnSelections<FriendshipTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Friendship>(
      row,
      columns: columns?.call(Friendship.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Friendship] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Friendship?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<FriendshipUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Friendship>(
      id,
      columnValues: columnValues(Friendship.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Friendship]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Friendship>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FriendshipUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<FriendshipTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FriendshipTable>? orderBy,
    _is.OrderByListBuilder<FriendshipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Friendship>(
      columnValues: columnValues(Friendship.t.updateTable),
      where: where(Friendship.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Friendship.t),
      orderByList: orderByList?.call(Friendship.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Friendship]s in the list and returns the deleted rows.
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
  Future<List<Friendship>> delete(
    _is.DatabaseSession session,
    List<Friendship> rows, {
    _is.OrderByBuilder<FriendshipTable>? orderBy,
    _is.OrderByListBuilder<FriendshipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Friendship>(
      rows,
      orderBy: orderBy?.call(Friendship.t),
      orderByList: orderByList?.call(Friendship.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Friendship].
  Future<Friendship> deleteRow(
    _is.DatabaseSession session,
    Friendship row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Friendship>(
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
  Future<List<Friendship>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FriendshipTable> where,
    _is.OrderByBuilder<FriendshipTable>? orderBy,
    _is.OrderByListBuilder<FriendshipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Friendship>(
      where: where(Friendship.t),
      orderBy: orderBy?.call(Friendship.t),
      orderByList: orderByList?.call(Friendship.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FriendshipTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Friendship>(
      where: where?.call(Friendship.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Friendship] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FriendshipTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Friendship>(
      where: where(Friendship.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
