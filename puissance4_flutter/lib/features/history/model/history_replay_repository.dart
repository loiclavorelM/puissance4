import 'package:puissance4_client/puissance4_client.dart';

import '../../game/model/game_launch.dart';
import '../../game/model/game_participant.dart';
import '../../game/model/game_snapshot.dart';
import '../../game/model/server_game_repository.dart';
import '../../offline/model/offline_game_repository.dart';
import 'history_item.dart';

/// Retrouve les coups d'une partie de l'Historique pour la rejouer (E14) :
/// en local pour une partie Normal (marche hors-ligne), auprès du serveur
/// pour une partie Multi/Classé.
class HistoryReplayRepository {
  HistoryReplayRepository(this._server, this._offline);

  final ServerGameRepository _server;
  final OfflineGameRepository _offline;

  /// `null` si la partie n'a pas de coups enregistrés (partie jouée avant
  /// l'enregistrement des coups).
  Future<GameLaunch?> launchFor(
    HistoryItem item, {
    required String myUsername,
  }) async {
    final id = UuidValue.fromString(item.id);
    switch (item.source) {
      case HistorySource.offline:
        final row = await _offline.findGame(id);
        if (row == null || row.moves.isEmpty) return null;
        final me = HumanParticipant(username: myUsername);
        final bot = BotParticipant(name: row.botName);
        final meRouge = row.playedAs == EnumColor.rouge;
        return GameLaunch.replay(
          moves: row.moves,
          rouge: meRouge ? me : bot,
          jaune: meRouge ? bot : me,
          myColor: row.playedAs,
          result: GameResult(winner: _winner(row.result, row.playedAs)),
        );
      case HistorySource.server:
        final replay = await _server.getReplay(id);
        if (replay.moves.isEmpty) return null;
        return GameLaunch.replay(
          moves: replay.moves,
          rouge: GameParticipant.fromInfo(replay.rouge),
          jaune: GameParticipant.fromInfo(replay.jaune),
          myColor: replay.playedAs,
          result: GameResult(
            winner: replay.winner,
            endReason: replay.endReason,
          ),
        );
    }
  }

  static EnumOutcome? _winner(EnumMatchResult? result, EnumColor playedAs) {
    final mine = playedAs == EnumColor.rouge
        ? EnumOutcome.rouge
        : EnumOutcome.jaune;
    final theirs = playedAs == EnumColor.rouge
        ? EnumOutcome.jaune
        : EnumOutcome.rouge;
    return switch (result) {
      null => null,
      EnumMatchResult.win => mine,
      EnumMatchResult.loss => theirs,
      EnumMatchResult.draw => EnumOutcome.draw,
    };
  }
}
