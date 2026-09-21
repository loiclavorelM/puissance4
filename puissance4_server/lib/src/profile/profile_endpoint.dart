import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import '../generated/protocol.dart';

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
        username: 'Joueur-${authUserId.toString().substring(0, 8)}',
      ),
    );

    final myPlayers = await Player.db.find(
      session,
      where: (t) => t.userId.equals(user!.id),
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
          ? EnumPlayer.rouge
          : EnumPlayer.jaune;
      return partie.winner == mine;
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
