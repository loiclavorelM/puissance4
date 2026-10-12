import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Un joueur de test : sa session authentifiée, son `User` et son `Player`.
typedef TestPlayer = ({TestSessionBuilder session, User user, Player player});

Future<TestPlayer> createTestPlayer(
  TestSessionBuilder sessionBuilder,
  String username,
) async {
  final session = sessionBuilder.build();
  final authUser = await const AuthUsers().create(session);
  final user = await User.db.insertRow(
    session,
    User(authUserId: authUser.id, username: username),
  );
  final player = await Player.db.insertRow(session, Player(userId: user.id));
  return (
    session: sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        authUser.id.uuid,
        {},
      ),
    ),
    user: user,
    player: player,
  );
}

/// Partie terminée de [me] (Rouge) contre [opponent].
Future<Partie> createFinishedPartie(
  TestSessionBuilder sessionBuilder, {
  required Player me,
  required Player opponent,
  required EnumType type,
  required EnumOutcome winner,
  List<int> moves = const [3, 4, 3, 4, 3, 4, 3],
}) => Partie.db.insertRow(
  sessionBuilder.build(),
  Partie(
    typePartie: type,
    playerRougeId: me.id!,
    playerJauneId: opponent.id!,
    winner: winner,
    status: EnumStatut.finished,
    moves: moves,
  ),
);
