import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given History endpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder alice;
    late Player alicePlayer;
    late Player bobPlayer;
    late Player botPlayer;

    Future<(TestSessionBuilder, Player)> player(String username) async {
      final session = sessionBuilder.build();
      final authUser = await const AuthUsers().create(session);
      final user = await User.db.insertRow(
        session,
        User(authUserId: authUser.id, username: username),
      );
      final player = await Player.db.insertRow(
        session,
        Player(userId: user.id),
      );
      return (
        sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            authUser.id.uuid,
            {},
          ),
        ),
        player,
      );
    }

    /// Partie d'alice (Rouge) contre [opponent], datée de [minutesAgo].
    Future<Partie> partie(
      Player opponent, {
      required EnumType type,
      required int minutesAgo,
      EnumOutcome? winner = EnumOutcome.rouge,
      EnumStatut status = EnumStatut.finished,
    }) => Partie.db.insertRow(
      sessionBuilder.build(),
      Partie(
        typePartie: type,
        playerRougeId: alicePlayer.id!,
        playerJauneId: opponent.id!,
        winner: winner,
        status: status,
        moves: const [3, 3, 4],
        createdAt: DateTime.now().toUtc().subtract(
          Duration(minutes: minutesAgo),
        ),
      ),
    );

    setUp(() async {
      (alice, alicePlayer) = await player('alice');
      (_, bobPlayer) = await player('bob');
      final bot = await Bot.db.insertRow(
        sessionBuilder.build(),
        Bot(botName: 'Medium', elo: 1200, pathModel: '', description: ''),
      );
      botPlayer = await Player.db.insertRow(
        sessionBuilder.build(),
        Player(botId: bot.id),
      );
    });

    test('when listing then finished games come newest first', () async {
      await partie(bobPlayer, type: EnumType.multi, minutesAgo: 30);
      await partie(
        botPlayer,
        type: EnumType.classe,
        minutesAgo: 10,
        winner: EnumOutcome.jaune,
      );
      await partie(
        bobPlayer,
        type: EnumType.multi,
        minutesAgo: 5,
        winner: null,
        status: EnumStatut.abandoned,
      );
      await partie(
        bobPlayer,
        type: EnumType.multi,
        minutesAgo: 1,
        winner: null,
        status: EnumStatut.inProgress,
      );

      final history = await endpoints.history.getListHistories(
        alice,
        limit: 50,
        offset: 0,
      );

      expect(history.map((h) => (h.adversaire, h.resultat)), [
        ('Medium', EnumMatchResult.loss),
        ('bob', EnumMatchResult.win),
      ]);
      expect(history.every((h) => h.playedAs == EnumColor.rouge), isTrue);
    });

    test('when filtering by mode then only that mode is returned', () async {
      await partie(bobPlayer, type: EnumType.multi, minutesAgo: 2);
      await partie(botPlayer, type: EnumType.classe, minutesAgo: 1);

      final multi = await endpoints.history.getListHistories(
        alice,
        typePartie: EnumType.multi,
        limit: 50,
        offset: 0,
      );
      final normal = await endpoints.history.getListHistories(
        alice,
        typePartie: EnumType.normal,
        limit: 50,
        offset: 0,
      );

      expect(multi.map((h) => h.typePartie), [EnumType.multi]);
      // Normal se lit côté client (OfflineMatchResult, base synchronisée).
      expect(normal, isEmpty);
    });

    test('when paging then pages follow each other', () async {
      for (var i = 0; i < 3; i++) {
        await partie(bobPlayer, type: EnumType.multi, minutesAgo: 10 - i);
      }

      final first = await endpoints.history.getListHistories(
        alice,
        limit: 2,
        offset: 0,
      );
      final second = await endpoints.history.getListHistories(
        alice,
        limit: 2,
        offset: 2,
      );

      expect(first, hasLength(2));
      expect(second, hasLength(1));
      expect(
        {...first.map((h) => h.id), ...second.map((h) => h.id)},
        hasLength(3),
      );
    });
  });
}
