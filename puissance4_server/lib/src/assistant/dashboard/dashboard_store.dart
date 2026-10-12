import 'dart:convert';
import 'dart:math';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../live/live_notifier.dart';
import '../sources/opponents.dart';

/// Le tableau de bord d'un joueur : une version courante (`UserDashboard`)
/// et les précédentes pour l'annulation (`UserDashboardVersion`).
///
/// Chaque modification passe par [mutate], sous verrou de ligne : deux
/// écritures concurrentes (l'assistant et le joueur sur un autre appareil)
/// produisent deux versions successives, jamais une écriture perdue.
abstract final class DashboardStore {
  /// Versions précédentes gardées pour l'annulation.
  static int keptVersions = 50;

  static final _random = Random.secure();
  static const _idAlphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';

  /// Nouvel id de widget, `w_` + 8 caractères.
  static String newWidgetId() =>
      'w_${List.generate(8, (_) => _idAlphabet[_random.nextInt(_idAlphabet.length)]).join()}';

  /// Le tableau de bord de [user] (vide s'il n'en a jamais eu), avec le nom
  /// de l'adversaire filtré résolu.
  static Future<Dashboard> load(Session session, User user) async {
    final row = await UserDashboard.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(user.id),
    );
    return withLabels(session, row == null ? Dashboard.empty : _decode(row));
  }

  /// Applique [change] au tableau de bord courant et l'enregistre comme une
  /// nouvelle version. [change] peut lever une exception pour tout annuler.
  /// Prévient les appareils du joueur (`dashboardChanged`) après commit.
  static Future<Dashboard> mutate(
    Session session,
    User user,
    EnumDashboardAuthor author,
    Dashboard Function(Dashboard current) change,
  ) async {
    final saved = await session.db.transaction((transaction) async {
      final row = await _lockedRow(session, user, transaction);
      final current = _decode(row);
      final next = change(current).copyWith(version: current.version + 1);
      await UserDashboardVersion.db.insertRow(
        session,
        UserDashboardVersion(
          dashboardId: row.id!,
          version: current.version,
          definitionJson: row.definitionJson,
          author: author,
        ),
        transaction: transaction,
      );
      await _write(session, row, next, transaction);
      await _prune(session, row.id!, transaction);
      return next;
    });
    await notifyUser(session, user.authUserId!, dashboard: true);
    return withLabels(session, saved);
  }

  /// Revient à la version précédente, enregistrée comme une nouvelle
  /// version (les numéros ne reculent jamais). `null` s'il n'y a rien à
  /// annuler.
  static Future<Dashboard?> undo(Session session, User user) async {
    final restored = await session.db.transaction((transaction) async {
      final row = await _lockedRow(session, user, transaction);
      final previous = await UserDashboardVersion.db.findFirstRow(
        session,
        where: (t) => t.dashboardId.equals(row.id),
        orderBy: (t) => t.version.desc(),
        transaction: transaction,
      );
      if (previous == null) return null;
      final current = _decode(row);
      final next = Dashboard.fromJson(
        (jsonDecode(previous.definitionJson) as Map).cast(),
      ).copyWith(version: current.version + 1);
      await UserDashboardVersion.db.deleteRow(
        session,
        previous,
        transaction: transaction,
      );
      await _write(session, row, next, transaction);
      return next;
    });
    if (restored == null) return null;
    await notifyUser(session, user.authUserId!, dashboard: true);
    return withLabels(session, restored);
  }

  /// [dashboard] avec `opponentLabel` résolu (jamais stocké : le pseudo
  /// peut changer).
  static Future<Dashboard> withLabels(
    Session session,
    Dashboard dashboard,
  ) async {
    final opponent = dashboard.filters.opponent;
    if (opponent == null) return dashboard;
    final label = await Opponents.label(session, opponent);
    return dashboard.copyWith(
      filters: dashboard.filters.copyWith(opponentLabel: () => label),
    );
  }

  static Dashboard _decode(UserDashboard row) => Dashboard.fromJson(
    (jsonDecode(row.definitionJson) as Map).cast(),
  ).copyWith(version: row.version);

  static Future<UserDashboard> _lockedRow(
    Session session,
    User user,
    Transaction transaction,
  ) async {
    Future<UserDashboard?> find() => UserDashboard.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(user.id),
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    final existing = await find();
    if (existing != null) return existing;
    // Premier tableau de bord : l'index unique sur userId départage deux
    // créations simultanées, la perdante relit la ligne de la gagnante.
    await session.db.unsafeExecute(
      'INSERT INTO "user_dashboard" ("id", "userId", "version", "definitionJson", "updatedAt") '
      'VALUES (gen_random_uuid(), @userId, 0, @json, now()) ON CONFLICT ("userId") DO NOTHING',
      parameters: QueryParameters.named({
        'userId': user.id!.uuid,
        'json': jsonEncode(Dashboard.empty.toJson(withLabels: false)),
      }),
      transaction: transaction,
    );
    return (await find())!;
  }

  static Future<void> _write(
    Session session,
    UserDashboard row,
    Dashboard dashboard,
    Transaction transaction,
  ) => UserDashboard.db.updateRow(
    session,
    row.copyWith(
      version: dashboard.version,
      definitionJson: jsonEncode(dashboard.toJson(withLabels: false)),
      updatedAt: DateTime.now().toUtc(),
    ),
    transaction: transaction,
  );

  static Future<void> _prune(
    Session session,
    UuidValue dashboardId,
    Transaction transaction,
  ) async {
    final old = await UserDashboardVersion.db.find(
      session,
      where: (t) => t.dashboardId.equals(dashboardId),
      orderBy: (t) => t.version.desc(),
      offset: keptVersions,
      transaction: transaction,
    );
    if (old.isNotEmpty) {
      await UserDashboardVersion.db.delete(
        session,
        old,
        transaction: transaction,
      );
    }
  }
}
