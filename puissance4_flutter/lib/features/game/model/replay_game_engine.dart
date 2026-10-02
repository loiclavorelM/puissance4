import 'dart:async';

import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

import '../../review/model/move_advisor.dart';

import 'game_engine.dart';
import 'game_participant.dart';
import 'game_snapshot.dart';

/// Rejoue une partie terminée à partir de sa liste de coups : le plateau ne
/// réagit pas au toucher, on avance/recule avec les [ReplayControls].
/// Avec un [MoveAdvisor], chaque coup affiché est accompagné de l'avis de
/// l'Expert (revue de partie, E14).
class ReplayGameEngine extends GameEngineBase implements ReplayControls {
  ReplayGameEngine({
    required List<int> moves,
    required GameParticipant rouge,
    required GameParticipant jaune,
    EnumColor? myColor,
    GameResult? result,
    int? startAt,
    this._advisor,
  }) : _allMoves = List.unmodifiable(moves),
       _finalResult = result,
       super(GameSnapshot(rouge: rouge, jaune: jaune, myColor: myColor)) {
    _show(startAt ?? 0);
  }

  static const autoPlayInterval = Duration(milliseconds: 700);

  final List<int> _allMoves;
  final GameResult? _finalResult;
  final MoveAdvisor? _advisor;
  Timer? _autoPlay;

  /// Avis déjà calculés, par indice de coup.
  final _analyses = <int, MoveAnalysis>{};

  int get _cursor => current.replay?.cursor ?? 0;

  @override
  ReplayControls get replay => this;

  @override
  Future<void> play(int column) async {}

  @override
  Future<void> abandon() async {}

  @override
  void first() => _show(0);

  @override
  void previous() => _show(_cursor - 1);

  @override
  void next() => _show(_cursor + 1);

  @override
  void last() => _show(_allMoves.length);

  @override
  void togglePlay() {
    if (_autoPlay != null) {
      _stopAutoPlay();
      _show(_cursor);
      return;
    }
    if (_cursor >= _allMoves.length) _show(0);
    _autoPlay = Timer.periodic(autoPlayInterval, (_) {
      if (_cursor >= _allMoves.length) {
        _stopAutoPlay();
        _show(_cursor);
      } else {
        _show(_cursor + 1);
      }
    });
    _show(_cursor);
  }

  void _stopAutoPlay() {
    _autoPlay?.cancel();
    _autoPlay = null;
  }

  void _show(int cursor) {
    final clamped = cursor.clamp(0, _allMoves.length);
    final atEnd = clamped == _allMoves.length;
    emit(
      GameSnapshot(
        rouge: current.rouge,
        jaune: current.jaune,
        myColor: current.myColor,
        moves: _allMoves.sublist(0, clamped),
        // Le résultat n'apparaît qu'une fois tous les coups rejoués.
        result: atEnd ? _finalResult : null,
        replay: ReplayPosition(
          cursor: clamped,
          total: _allMoves.length,
          isPlaying: _autoPlay != null,
          analysis: clamped == 0 ? null : _analyses[clamped - 1],
        ),
      ),
    );
    if (clamped > 0) unawaited(_analyze(clamped - 1));
  }

  /// Calcule l'avis sur le coup [index] puis réaffiche la position si elle
  /// est toujours à l'écran.
  Future<void> _analyze(int index) async {
    final advisor = _advisor;
    if (advisor == null || _analyses.containsKey(index)) return;
    final MoveAnalysis analysis;
    try {
      analysis = await advisor.analyze(_allMoves, index);
    } on Object {
      return; // Sans avis, le replay reste utilisable.
    }
    _analyses[index] = analysis;
    if (!isDisposed && _cursor == index + 1) _show(_cursor);
  }

  @override
  void dispose() {
    _stopAutoPlay();
    super.dispose();
  }
}
