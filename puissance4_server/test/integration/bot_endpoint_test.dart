import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Bot endpoint', (sessionBuilder, endpoints) {
    test('when listing bots then they are sorted by elo', () async {
      final session = sessionBuilder.build();
      for (final (name, elo) in [('Expert', 1600), ('Débutant', 800)]) {
        await Bot.db.insertRow(
          session,
          Bot(botName: name, elo: elo, pathModel: '', description: ''),
        );
      }

      final bots = await endpoints.bot.getBots(sessionBuilder);

      expect(bots.map((b) => b.botName), ['Débutant', 'Expert']);
    });
  });
}
