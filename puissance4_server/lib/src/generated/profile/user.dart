/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:puissance4_server/src/generated/protocol.dart' as _irho11n9;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;

abstract class User
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  User._({
    this.id,
    this.authUserId,
    this.authUser,
    required this.username,
    this.thumbnailPath,
    int? elo,
    this.friendCode,
    DateTime? createdAt,
    this.updatedAt,
  }) : elo = elo ?? 1000,
       createdAt = createdAt ?? DateTime.now();

  factory User({
    _is.UuidValue? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    required String username,
    String? thumbnailPath,
    int? elo,
    String? friendCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserImpl;

  factory User.fromJson(Map<String, dynamic> jsonSerialization) {
    return User(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authUserId: jsonSerialization['authUserId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['authUserId'],
            ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _irho11n9.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      username: jsonSerialization['username'] as String,
      thumbnailPath: jsonSerialization['thumbnailPath'] as String?,
      elo: jsonSerialization['elo'] as int?,
      friendCode: jsonSerialization['friendCode'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = UserTable();

  static const db = UserRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue? authUserId;

  _iacs.AuthUser? authUser;

  String username;

  String? thumbnailPath;

  int elo;

  String? friendCode;

  DateTime createdAt;

  DateTime? updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  User copyWith({
    _is.UuidValue? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? username,
    String? thumbnailPath,
    int? elo,
    String? friendCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'User',
      if (id != null) 'id': id?.toJson(),
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'username': username,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
      'elo': elo,
      if (friendCode != null) 'friendCode': friendCode,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'User',
      if (id != null) 'id': id?.toJson(),
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'username': username,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
      'elo': elo,
      if (friendCode != null) 'friendCode': friendCode,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static UserInclude include({_iacs.AuthUserInclude? authUser}) {
    return UserInclude._(authUser: authUser);
  }

  static UserIncludeList includeList({
    _is.WhereExpressionBuilder<UserTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserTable>? orderBy,
    _is.OrderByListBuilder<UserTable>? orderByList,
    UserInclude? include,
  }) {
    return UserIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(User.t),
      orderByList: orderByList?.call(User.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserImpl extends User {
  _UserImpl({
    _is.UuidValue? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    required String username,
    String? thumbnailPath,
    int? elo,
    String? friendCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         username: username,
         thumbnailPath: thumbnailPath,
         elo: elo,
         friendCode: friendCode,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  User copyWith({
    Object? id = _Undefined,
    Object? authUserId = _Undefined,
    Object? authUser = _Undefined,
    String? username,
    Object? thumbnailPath = _Undefined,
    int? elo,
    Object? friendCode = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return User(
      id: id is _is.UuidValue? ? id : this.id,
      authUserId: authUserId is _is.UuidValue? ? authUserId : this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      username: username ?? this.username,
      thumbnailPath: thumbnailPath is String?
          ? thumbnailPath
          : this.thumbnailPath,
      elo: elo ?? this.elo,
      friendCode: friendCode is String? ? friendCode : this.friendCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class UserUpdateTable extends _is.UpdateTable<UserTable> {
  UserUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> username(String value) => _is.ColumnValue(
    table.username,
    value,
  );

  _is.ColumnValue<String, String> thumbnailPath(String? value) =>
      _is.ColumnValue(
        table.thumbnailPath,
        value,
      );

  _is.ColumnValue<int, int> elo(int value) => _is.ColumnValue(
    table.elo,
    value,
  );

  _is.ColumnValue<String, String> friendCode(String? value) => _is.ColumnValue(
    table.friendCode,
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

class UserTable extends _is.Table<_is.UuidValue?> {
  UserTable({super.tableRelation}) : super(tableName: 'user') {
    updateTable = UserUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    username = _is.ColumnString(
      'username',
      this,
    );
    thumbnailPath = _is.ColumnString(
      'thumbnailPath',
      this,
    );
    elo = _is.ColumnInt(
      'elo',
      this,
      hasDefault: true,
    );
    friendCode = _is.ColumnString(
      'friendCode',
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

  late final UserUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString username;

  late final _is.ColumnString thumbnailPath;

  late final _is.ColumnInt elo;

  late final _is.ColumnString friendCode;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: User.t.authUserId,
      foreignField: _iacs.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iacs.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _authUser!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    authUserId,
    username,
    thumbnailPath,
    elo,
    friendCode,
    createdAt,
    updatedAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class UserInclude extends _is.IncludeObject {
  UserInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<_is.UuidValue?> get table => User.t;
}

class UserIncludeList extends _is.IncludeList {
  UserIncludeList._({
    _is.WhereExpressionBuilder<UserTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(User.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => User.t;
}

class UserRepository {
  const UserRepository._();

  final attachRow = const UserAttachRowRepository._();

  final detachRow = const UserDetachRowRepository._();

  /// Returns a list of [User]s matching the given query parameters.
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
  Future<List<User>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserTable>? orderBy,
    _is.OrderByListBuilder<UserTable>? orderByList,
    _is.Transaction? transaction,
    UserInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<User>(
      where: where?.call(User.t),
      orderBy: orderBy?.call(User.t),
      orderByList: orderByList?.call(User.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [User] matching the given query parameters.
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
  Future<User?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserTable>? where,
    int? offset,
    _is.OrderByBuilder<UserTable>? orderBy,
    _is.OrderByListBuilder<UserTable>? orderByList,
    _is.Transaction? transaction,
    UserInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<User>(
      where: where?.call(User.t),
      orderBy: orderBy?.call(User.t),
      orderByList: orderByList?.call(User.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [User] by its [id] or null if no such row exists.
  Future<User?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    UserInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<User>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [User]s in the list and returns the inserted rows.
  ///
  /// The returned [User]s will have their `id` fields set.
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
  Future<List<User>> insert(
    _is.DatabaseSession session,
    List<User> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<User>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [User] and returns the inserted row.
  ///
  /// The returned [User] will have its `id` field set.
  Future<User> insertRow(
    _is.DatabaseSession session,
    User row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<User>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [User]s in the list and returns the resulting rows.
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
  /// The returned [User]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<User>> upsert(
    _is.DatabaseSession session,
    List<User> rows, {
    required _is.ColumnSelections<UserTable> conflictColumns,
    _is.ColumnSelections<UserTable>? updateColumns,
    _is.WhereExpressionBuilder<UserTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<User>(
      rows,
      conflictColumns: conflictColumns(User.t),
      updateColumns: updateColumns?.call(User.t),
      updateWhere: updateWhere?.call(User.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [User] and returns the resulting row.
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
  /// The returned [User] will have its `id` field set.
  Future<User?> upsertRow(
    _is.DatabaseSession session,
    User row, {
    required _is.ColumnSelections<UserTable> conflictColumns,
    _is.ColumnSelections<UserTable>? updateColumns,
    _is.WhereExpressionBuilder<UserTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<User>(
      row,
      conflictColumns: conflictColumns(User.t),
      updateColumns: updateColumns?.call(User.t),
      updateWhere: updateWhere?.call(User.t),
      transaction: transaction,
    );
  }

  /// Updates all [User]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<User>> update(
    _is.DatabaseSession session,
    List<User> rows, {
    _is.ColumnSelections<UserTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<User>(
      rows,
      columns: columns?.call(User.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [User]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<User> updateRow(
    _is.DatabaseSession session,
    User row, {
    _is.ColumnSelections<UserTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<User>(
      row,
      columns: columns?.call(User.t),
      transaction: transaction,
    );
  }

  /// Updates a single [User] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<User?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<UserUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<User>(
      id,
      columnValues: columnValues(User.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [User]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<User>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<UserUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<UserTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserTable>? orderBy,
    _is.OrderByListBuilder<UserTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<User>(
      columnValues: columnValues(User.t.updateTable),
      where: where(User.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(User.t),
      orderByList: orderByList?.call(User.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [User]s in the list and returns the deleted rows.
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
  Future<List<User>> delete(
    _is.DatabaseSession session,
    List<User> rows, {
    _is.OrderByBuilder<UserTable>? orderBy,
    _is.OrderByListBuilder<UserTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<User>(
      rows,
      orderBy: orderBy?.call(User.t),
      orderByList: orderByList?.call(User.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [User].
  Future<User> deleteRow(
    _is.DatabaseSession session,
    User row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<User>(
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
  Future<List<User>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserTable> where,
    _is.OrderByBuilder<UserTable>? orderBy,
    _is.OrderByListBuilder<UserTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<User>(
      where: where(User.t),
      orderBy: orderBy?.call(User.t),
      orderByList: orderByList?.call(User.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<User>(
      where: where?.call(User.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [User] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<User>(
      where: where(User.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class UserAttachRowRepository {
  const UserAttachRowRepository._();

  /// Creates a relation between the given [User] and [AuthUser]
  /// by setting the [User]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    User user,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $user = user.copyWith(authUserId: authUser.id);
    await session.db.updateRow<User>(
      $user,
      columns: [User.t.authUserId],
      transaction: transaction,
    );
  }
}

class UserDetachRowRepository {
  const UserDetachRowRepository._();

  /// Detaches the relation between this [User] and the [AuthUser] set in `authUser`
  /// by setting the [User]'s foreign key `authUserId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> authUser(
    _is.DatabaseSession session,
    User user, {
    _is.Transaction? transaction,
  }) async {
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }

    var $user = user.copyWith(authUserId: null);
    await session.db.updateRow<User>(
      $user,
      columns: [User.t.authUserId],
      transaction: transaction,
    );
  }
}
