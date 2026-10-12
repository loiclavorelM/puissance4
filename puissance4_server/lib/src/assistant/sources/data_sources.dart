import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'game_record.dart';
import 'game_record_repository.dart';
import 'opponents.dart';

/// Paramètres invalides : le message dit quoi corriger (il remonte tel quel
/// au LLM par les outils).
final class SourceQueryException implements Exception {
  const SourceQueryException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Les sources de données de `contracts/sources.json`. Chaque source lit
/// les parties du joueur via [GameRecordRepository] et renvoie un chiffre
/// clé ou des lignes typées, avec les vraies valeurs : le filtre de
/// confidentialité s'applique plus haut, dans l'orchestrateur.
abstract final class DataSources {
  static SourceCatalog get catalog => AssistantContracts.catalog;

  /// Interroge [sourceKey] pour [user]. [params] est déjà résolu (aucune
  /// valeur `$dashboard.xxx`). Lève [SourceQueryException].
  static Future<SourceData> query(
    Session session,
    User user,
    String sourceKey,
    Map<String, Object?> params, {
    DateTime? now,
  }) async {
    final source = catalog[sourceKey];
    if (source == null) {
      throw SourceQueryException(
        'Unknown source $sourceKey. Sources: ${catalog.sources.keys.join(', ')}.',
      );
    }
    final errors = catalog.checkParams(source, params);
    if (params.values.any(
      (v) => v is String && v.startsWith(dashboardPrefix),
    )) {
      errors.add('Dashboard references must be resolved before querying.');
    }
    if (errors.isNotEmpty) throw SourceQueryException(errors.join(' '));

    final query = await _SourceQuery.parse(
      session,
      params,
      now ?? DateTime.now(),
    );
    return switch (sourceKey) {
      'games.summary' => _summary(session, user, query),
      'games.byDay' => _byDay(await query.games(session, user)),
      'games.length' => _length(await query.games(session, user)),
      'moves.firstColumn' => _firstColumn(await query.games(session, user)),
      'moves.byCell' => _byCell(await query.games(session, user), query),
      'results.byOpponent' => _byOpponent(await query.games(session, user)),
      'games.recent' => _recent(await query.games(session, user), query),
      'elo.history' => _eloHistory(session, user, query),
      'streaks' => _streaks(await query.games(session, user)),
      _ => throw StateError('Source $sourceKey declared but not implemented'),
    };
  }

  static Future<KpiData> _summary(
    Session session,
    User user,
    _SourceQuery query,
  ) async {
    final games = await query.games(session, user);
    final rate = _winRate(games);
    num? delta;
    if (rate != null && query.previous != null && query.lastGames == null) {
      final (since, until) = query.previous!;
      final before = await GameRecordRepository.load(
        session,
        user,
        query.filter(since: since, until: until),
      );
      if (_winRate(before) case final previous?) delta = rate - previous;
    }
    return KpiData(
      value: rate,
      unit: '%',
      delta: delta,
      secondary: games.length,
    );
  }

  static int? _winRate(List<GameRecord> games) => games.isEmpty
      ? null
      : (100 *
                games.where((g) => g.result == EnumMatchResult.win).length /
                games.length)
            .round();

  static DataSet _byDay(List<GameRecord> games) {
    final counts = <(String, String), int>{};
    for (final game in games.reversed) {
      final key = (_day(game.playedAt), game.result.name);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return DataSet(
      fields: _fields(['day', 'result', 'count']),
      rows: [
        for (final MapEntry(key: (day, result), :value) in counts.entries)
          [day, result, value],
      ],
    );
  }

  static DataSet _length(List<GameRecord> games) {
    final counts = <int, int>{};
    for (final game in games) {
      counts[game.moves.length] = (counts[game.moves.length] ?? 0) + 1;
    }
    final lengths = counts.keys.toList()..sort();
    return DataSet(
      fields: _fields(['moves', 'count']),
      rows: [
        for (final length in lengths) ['$length', counts[length]],
      ],
    );
  }

  static DataSet _firstColumn(List<GameRecord> games) {
    final counts = List.filled(Connect4Rules.columns, 0);
    for (final game in games) {
      final index = game.playedAs == EnumColor.rouge ? 0 : 1;
      if (index < game.moves.length) counts[game.moves[index]]++;
    }
    return DataSet(
      fields: _fields(['column', 'count']),
      rows: [
        for (var c = 0; c < Connect4Rules.columns; c++) ['${c + 1}', counts[c]],
      ],
    );
  }

  static DataSet _byCell(List<GameRecord> games, _SourceQuery query) {
    final counts = List.generate(
      Connect4Rules.rows,
      (_) => List.filled(Connect4Rules.columns, 0),
    );
    for (final game in games) {
      final disc = query.who == 'opponent' ? game.myDisc.other : game.myDisc;
      final cells = query.only == 'winning'
          ? game.winningCellsOf(disc)
          : game.cellsOf(disc);
      for (final (column, row) in cells) {
        counts[row][column]++;
      }
    }
    return DataSet(
      fields: _fields(['row', 'column', 'discs']),
      rows: [
        for (var r = 0; r < Connect4Rules.rows; r++)
          for (var c = 0; c < Connect4Rules.columns; c++)
            ['${r + 1}', '${c + 1}', counts[r][c]],
      ],
    );
  }

  static DataSet _byOpponent(List<GameRecord> games) {
    final names = <String, (String, OpponentKind)>{};
    final counts = <String, Map<EnumMatchResult, int>>{};
    for (final game in games) {
      names[game.opponentRef] = (game.opponentName, game.opponentKind);
      final byResult = counts.putIfAbsent(game.opponentRef, () => {});
      byResult[game.result] = (byResult[game.result] ?? 0) + 1;
    }
    int total(String ref) => counts[ref]!.values.fold(0, (a, b) => a + b);
    final refs = counts.keys.toList()
      ..sort((a, b) => total(b).compareTo(total(a)));
    return DataSet(
      fields: _fields([
        'opponent',
        'opponentKind',
        'result',
        'count',
        'opponentRef',
      ]),
      rows: [
        for (final ref in refs)
          for (final result in EnumMatchResult.values)
            if (counts[ref]![result] case final count?)
              [names[ref]!.$1, names[ref]!.$2.name, result.name, count, ref],
      ].take(DataSet.maxRows).toList(),
    );
  }

  static DataSet _recent(List<GameRecord> games, _SourceQuery query) => DataSet(
    fields: _fields([
      'playedAt',
      'mode',
      'opponent',
      'opponentKind',
      'result',
      'moveCount',
      'eloDelta',
      'gameId',
      'opponentRef',
    ]),
    rows: [
      for (final game in games.take(query.limit ?? 10))
        [
          game.playedAt.toUtc().toIso8601String(),
          game.mode.name,
          game.opponentName,
          game.opponentKind.name,
          game.result.name,
          game.moves.length,
          game.eloDelta,
          game.id.uuid,
          game.opponentRef,
        ],
    ],
  );

  static Future<DataSet> _eloHistory(
    Session session,
    User user,
    _SourceQuery query,
  ) async {
    final rows = await EloHistory.db.find(
      session,
      where: (t) {
        var where = t.userId.equals(user.id);
        if (query.since case final since?) {
          where = where & (t.createdAt >= since);
        }
        return where;
      },
      orderBy: (t) => t.createdAt,
    );
    // Elo en fin de journée : la dernière valeur de chaque jour l'emporte.
    final byDay = <String, int>{};
    for (final row in rows) {
      byDay[_day(row.createdAt)] = row.newElo;
    }
    return DataSet(
      fields: _fields(['day', 'elo']),
      rows: [
        for (final MapEntry(:key, :value) in byDay.entries) [key, value],
      ].reversed.take(DataSet.maxRows).toList().reversed.toList(),
    );
  }

  static KpiData _streaks(List<GameRecord> games) {
    var current = 0;
    var best = 0;
    var run = 0;
    var counting = true;
    for (final game in games) {
      // Du plus récent au plus ancien.
      if (game.result == EnumMatchResult.win) {
        run++;
        if (counting) current = run;
      } else {
        counting = false;
        run = 0;
      }
      if (run > best) best = run;
    }
    return KpiData(value: games.isEmpty ? null : current, secondary: best);
  }

  static List<DataField> _fields(List<String> names) => [
    for (final name in names) DataField(name, catalog.fields[name]!.type),
  ];

  /// Jour UTC `yyyy-MM-dd`.
  static String _day(DateTime at) =>
      at.toUtc().toIso8601String().substring(0, 10);
}

/// Paramètres d'une requête, lus et vérifiés.
final class _SourceQuery {
  _SourceQuery._({
    this.since,
    this.previous,
    this.lastGames,
    this.mode,
    this.opponentRef,
    this.who,
    this.only,
    this.limit,
  });

  static Future<_SourceQuery> parse(
    Session session,
    Map<String, Object?> params,
    DateTime now,
  ) async {
    final range = switch (params['range']) {
      final String value => RelativeRange.tryParse(value),
      _ => null,
    };
    OpponentRef? opponentRef;
    if (params['opponent'] case final String opponent) {
      opponentRef = await Opponents.resolve(session, opponent);
      if (opponentRef == null) {
        throw SourceQueryException(
          'No opponent matches "$opponent": use a name from results.byOpponent.',
        );
      }
    }
    return _SourceQuery._(
      since: range?.start(now),
      previous: range?.previous(now),
      lastGames: params['lastGames'] as int?,
      mode: switch (params['mode']) {
        final String mode => EnumType.values.byName(mode),
        _ => null,
      },
      opponentRef: opponentRef,
      who: params['who'] as String?,
      only: params['only'] as String?,
      limit: params['limit'] as int?,
    );
  }

  final DateTime? since;
  final (DateTime, DateTime)? previous;
  final int? lastGames;
  final EnumType? mode;
  final OpponentRef? opponentRef;
  final String? who;
  final String? only;
  final int? limit;

  GameFilter filter({DateTime? since, DateTime? until}) => GameFilter(
    mode: mode,
    opponentRef: opponentRef,
    since: since ?? this.since,
    until: until,
    lastGames: lastGames,
  );

  Future<List<GameRecord>> games(Session session, User user) =>
      GameRecordRepository.load(session, user, filter());
}
