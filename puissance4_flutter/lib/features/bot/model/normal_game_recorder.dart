import 'package:puissance4_client/puissance4_client.dart';

import '../../game/model/game_snapshot.dart';
import '../../game/model/local_game_engine.dart';
import '../../offline/model/offline_game_repository.dart';

/// Sauvegarde d'une partie Normal dans la base locale synchronisée : coups
/// au fil de l'eau, résultat (du point de vue du joueur) à la fin.
class NormalGameRecorder implements LocalGameRecorder {
  NormalGameRecorder(
    this._repository,
    this._partieId,
    this._playedAs, {
    this.onFinished,
  });

  final OfflineGameRepository _repository;
  final UuidValue _partieId;
  final EnumColor _playedAs;

  /// Appelé une fois la partie close en base (ex. rafraîchir l'Historique).
  final void Function()? onFinished;

  @override
  Future<void> onMove(List<int> moves) =>
      _repository.recordMoves(_partieId, moves);

  @override
  Future<void> onEnd(List<int> moves, GameResult result) async {
    await _repository.finishGame(_partieId, _resultFor(result.winner), moves);
    onFinished?.call();
  }

  EnumMatchResult? _resultFor(EnumOutcome? winner) => switch (winner) {
    null => null,
    EnumOutcome.draw => EnumMatchResult.draw,
    EnumOutcome.rouge =>
      _playedAs == EnumColor.rouge ? EnumMatchResult.win : EnumMatchResult.loss,
    EnumOutcome.jaune =>
      _playedAs == EnumColor.jaune ? EnumMatchResult.win : EnumMatchResult.loss,
  };
}
