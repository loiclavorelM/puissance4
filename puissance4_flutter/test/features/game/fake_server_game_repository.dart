import 'dart:async';

import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_flutter/features/game/model/server_game_repository.dart';

/// Streams de partie pilotés à la main par les tests.
class FakeServerGameRepository implements ServerGameRepository {
  final watches = <StreamController<GameEvent>>[];
  final played = <int>[];
  var abandoned = 0;
  UuidValue? activePartie;

  /// Erreur levée par le prochain `playMove` (après avoir, ou non, joué).
  Object? nextPlayError;

  StreamController<GameEvent> get lastWatch => watches.last;

  @override
  Stream<GameEvent> watchPartie(UuidValue partieId) {
    final controller = StreamController<GameEvent>();
    watches.add(controller);
    return controller.stream;
  }

  @override
  Future<UuidValue?> getActivePartie() async => activePartie;

  @override
  Future<void> playMove(UuidValue partieId, int column) async {
    final error = nextPlayError;
    nextPlayError = null;
    if (error != null) throw error;
    played.add(column);
  }

  @override
  Future<void> abandon(UuidValue partieId) async => abandoned++;

  @override
  Future<ReplayDto> getReplay(UuidValue partieId) => throw UnimplementedError();
}

final testPartieId = UuidValue.fromString(
  '0190a8f0-0000-7000-8000-000000000001',
);

GameEvent gameEvent(
  EnumGameEventType type,
  List<int> moves, {
  EnumColor yourColor = EnumColor.rouge,
  bool opponentIsBot = false,
  bool? opponentConnected,
}) => GameEvent(
  type: type,
  partieId: testPartieId,
  yourColor: yourColor,
  rouge: GamePlayerInfo(username: 'alice', elo: 1000),
  jaune: GamePlayerInfo(username: 'bob', elo: 1200, isBot: opponentIsBot),
  moves: moves,
  turnDeadline: DateTime.now().add(const Duration(seconds: 60)),
  opponentConnected: opponentConnected,
);
