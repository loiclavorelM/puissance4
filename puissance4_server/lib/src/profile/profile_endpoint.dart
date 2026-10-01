import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../game/enum_color_extensions.dart';
import '../generated/protocol.dart';
import '../live/live_notifier.dart';
import 'user_provisioning.dart';

class ProfileEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<UserProfileDto> getMyProfile(Session session) async {
    final authUserId = session.authenticated!.authUserId;

    // Filet de sécurité : `createUserForAuthUser` (user_provisioning.dart)
    // crée déjà systématiquement le User à la création de l'AuthUser, donc
    // cette branche est normalement inatteignable — gardée pour respecter
    // le contrat documenté ("crée au premier appel si besoin",
    // doc/05-endpoints.md).
    var user = await User.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    user ??= await User.db.insertRow(
      session,
      User(
        authUserId: authUserId,
        username: defaultUsernameFor(authUserId),
      ),
    );

    return _buildProfileDto(session, user);
  }

  /// Change le pseudo du User authentifié (seule modification de profil
  /// pour l'instant — la photo passera par un endpoint d'upload séparé,
  /// cf. T2.1.3). Lève [ProfileUpdateException] si [username] ne respecte
  /// pas [_usernamePattern] ou est déjà pris (insensible à la casse).
  Future<UserProfileDto> updateUsername(
    Session session,
    String username,
  ) async {
    final authUserId = session.authenticated!.authUserId;
    final trimmed = username.trim();
    if (!_usernamePattern.hasMatch(trimmed)) {
      throw ProfileUpdateException(
        reason: EnumProfileUpdateError.invalidUsername,
      );
    }

    final user = await User.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (user == null) {
      throw StateError('Aucun User pour l\'AuthUser $authUserId');
    }
    if (user.username == trimmed) return _buildProfileDto(session, user);

    // `_` est un joker ILIKE : l'échapper pour une comparaison exacte.
    final escaped = trimmed.replaceAll('_', r'\_');
    final taken = await User.db.findFirstRow(
      session,
      where: (t) => t.username.ilike(escaped) & t.id.notEquals(user.id),
    );
    if (taken != null) {
      throw ProfileUpdateException(
        reason: EnumProfileUpdateError.usernameTaken,
      );
    }

    final User updated;
    try {
      updated = await User.db.updateRow(
        session,
        user.copyWith(username: trimmed, updatedAt: DateTime.now()),
      );
    } on DatabaseUniqueViolationException {
      // Un autre joueur a pris ce pseudo entre la vérification et l'écriture.
      throw ProfileUpdateException(
        reason: EnumProfileUpdateError.usernameTaken,
      );
    }
    await notifyUser(session, authUserId, profile: true);
    await notifyLeaderboardChanged(session);
    return _buildProfileDto(session, updated);
  }

  /// 3 à 20 caractères, lettres/chiffres/`_`/`-` — mêmes règles que
  /// `validateUsername` côté Flutter (profile/model/username_rules.dart).
  static final _usernamePattern = RegExp(r'^[A-Za-z0-9_-]{3,20}$');

  Future<UserProfileDto> _buildProfileDto(Session session, User user) async {
    final myPlayers = await Player.db.find(
      session,
      where: (t) => t.userId.equals(user.id),
    );
    final myPlayerIds = myPlayers.map((p) => p.id!).toSet();

    // Seuls Classé et Multi comptent (cf. UserProfileDto) — le mode Normal
    // ne fait pas gagner/perdre de statistiques de classement.
    final parties = myPlayerIds.isEmpty
        ? <Partie>[]
        : await Partie.db.find(
            session,
            where: (t) =>
                (t.playerRougeId.inSet(myPlayerIds) |
                    t.playerJauneId.inSet(myPlayerIds)) &
                t.status.equals(EnumStatut.finished) &
                t.typePartie.inSet({EnumType.multi, EnumType.classe}),
          );

    final victoires = parties.where((partie) {
      final mine = myPlayerIds.contains(partie.playerRougeId)
          ? EnumColor.rouge
          : EnumColor.jaune;
      return partie.winner == mine.asOutcome;
    }).length;

    return UserProfileDto(
      id: user.id!,
      username: user.username,
      thumbnailUrl: user.thumbnailPath,
      elo: user.elo,
      nbParties: parties.length,
      nbVictoires: victoires,
    );
  }
}
