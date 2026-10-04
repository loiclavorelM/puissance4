import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../auth/guest_upgrade.dart';
import '../game/enum_color_extensions.dart';
import '../generated/protocol.dart';
import '../live/live_notifier.dart';
import 'profile_photo.dart';
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

  /// Remplace la photo de profil par [photo] (E2, US2.1) : le serveur la
  /// vérifie et la réencode en miniature carrée (cf. [ProfilePhoto]), puis
  /// supprime l'ancienne. Lève [ProfileUpdateException] (`photoTooLarge`,
  /// `invalidPhoto`).
  Future<UserProfileDto> uploadProfilePhoto(
    Session session,
    ByteData photo,
  ) async {
    if (photo.lengthInBytes > ProfilePhoto.maxBytes) {
      throw ProfileUpdateException(
        reason: EnumProfileUpdateError.photoTooLarge,
      );
    }
    final Uint8List thumbnail;
    try {
      thumbnail = await ProfilePhoto.normalize(
        photo.buffer.asUint8List(photo.offsetInBytes, photo.lengthInBytes),
      );
    } on PhotoTooLargeException {
      throw ProfileUpdateException(
        reason: EnumProfileUpdateError.photoTooLarge,
      );
    } on Object {
      // Fichier illisible, quelle que soit la façon dont le décodeur échoue
      // (les fichiers corrompus lèvent parfois des `Error`).
      throw ProfileUpdateException(reason: EnumProfileUpdateError.invalidPhoto);
    }

    final user = await _requireUser(session);
    final path = ProfilePhoto.pathFor(user.id!);
    await session.storage.storeFile(
      storageId: ProfilePhoto.storageId,
      path: path,
      byteData: ByteData.sublistView(thumbnail),
    );
    return _replacePhoto(session, user, path);
  }

  /// Retire la photo de profil (retour aux initiales).
  Future<UserProfileDto> removeProfilePhoto(Session session) async {
    final user = await _requireUser(session);
    if (user.thumbnailPath == null) return _buildProfileDto(session, user);
    return _replacePhoto(session, user, null);
  }

  Future<User> _requireUser(Session session) async {
    final authUserId = session.authenticated!.authUserId;
    final user = await User.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (user == null) {
      throw StateError('Aucun User pour l\'AuthUser $authUserId');
    }
    return user;
  }

  /// Enregistre [path] comme photo du joueur, supprime l'ancienne et
  /// prévient ses appareils et le classement.
  Future<UserProfileDto> _replacePhoto(
    Session session,
    User user,
    String? path,
  ) async {
    final previous = user.thumbnailPath;
    final updated = await User.db.updateRow(
      session,
      user.copyWith(thumbnailPath: path, updatedAt: DateTime.now()),
    );
    if (previous != null && previous != path) {
      try {
        await session.storage.deleteFile(
          storageId: ProfilePhoto.storageId,
          path: previous,
        );
      } on Exception catch (e) {
        // Un fichier orphelin ne gêne personne : la photo est déjà changée.
        session.log(
          'Old profile photo not deleted: $e',
          level: LogLevel.warning,
        );
      }
    }
    await notifyUser(session, user.authUserId!, profile: true);
    await notifyLeaderboardChanged(session);
    return _buildProfileDto(session, updated);
  }

  /// 3 à 20 caractères, lettres/chiffres/`_`/`-` — mêmes règles que
  /// `checkUsername` côté Flutter (profile/model/username_rules.dart).
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
      thumbnailUrl: await ProfilePhoto.url(session, user.thumbnailPath),
      elo: user.elo,
      nbParties: parties.length,
      nbVictoires: victoires,
      isGuest:
          user.authUserId != null &&
          await isAnonymousAuthUser(session, user.authUserId!),
    );
  }
}
