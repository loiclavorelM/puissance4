import 'dart:async';

import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

import 'color_mapping.dart';
import 'game_engine.dart';
import 'game_participant.dart';
import 'game_snapshot.dart';

/// Qui choisit la colonne pour un camp d'une partie locale.
sealed class LocalSeat {
  const LocalSeat();
}

/// Le joueur de cet appareil, au toucher.
class HumanSeat extends LocalSeat {
  const HumanSeat();
}

/// Une IA qui tourne sur le téléphone.
class BotSeat extends LocalSeat {
  const BotSeat(
    this.chooseColumn, {
    this.thinkingTime = const Duration(milliseconds: 500),
  });

  /// Une position → une colonne (voir `BotBrain`).
  final Future<int> Function(List<int> moves) chooseColumn;

  /// Pause minimale avant de jouer, pour que le coup humain se voie.
  final Duration thinkingTime;
}

/// Sauvegarde d'une partie locale au fil de l'eau (Normal : base locale
/// synchronisée).
abstract interface class LocalGameRecorder {
  Future<void> onMove(List<int> moves);
  Future<void> onEnd(List<int> moves, GameResult result);
}

/// Partie dont les règles tournent sur le téléphone (`puissance4_rules`) :
/// Normal (humain contre IA locale), ou deux humains sur le même appareil.
class LocalGameEngine extends GameEngineBase {
  LocalGameEngine({
    required this.rougeSeat,
    required this.jauneSeat,
    required GameParticipant rouge,
    required GameParticipant jaune,
    EnumColor? myColor,
    this.recorder,
  }) : super(
         GameSnapshot(
           rouge: rouge,
           jaune: jaune,
           myColor: myColor,
           acceptsInput: rougeSeat is HumanSeat,
         ),
       ) {
    unawaited(_playBotIfItsTurn());
  }

  final LocalSeat rougeSeat;
  final LocalSeat jauneSeat;
  final LocalGameRecorder? recorder;

  LocalSeat _seat(EnumColor color) =>
      color == EnumColor.rouge ? rougeSeat : jauneSeat;

  @override
  Future<void> play(int column) async {
    final snapshot = current;
    if (!snapshot.acceptsInput ||
        _seat(snapshot.colorToPlay) is! HumanSeat ||
        !Connect4Rules.isValidMove(snapshot.moves, column)) {
      return;
    }
    await _apply(column);
  }

  @override
  Future<void> abandon() async {
    final snapshot = current;
    if (snapshot.isOver) return;
    // Deux joueurs sur l'appareil : c'est le joueur au trait qui abandonne.
    final quitter = snapshot.myColor ?? snapshot.colorToPlay;
    final humanPlayed = [
      for (var i = 0; i < snapshot.moves.length; i++)
        if (_seat(i.isEven ? EnumColor.rouge : EnumColor.jaune) is HumanSeat) i,
    ].isNotEmpty;
    final result = GameResult(
      winner: humanPlayed ? quitter.other.asOutcome : null,
      endReason: humanPlayed
          ? EnumGameEndReason.forfeit
          : EnumGameEndReason.cancelled,
    );
    emit(snapshot.copyWith(result: result, acceptsInput: false));
    await _record(() => recorder?.onEnd(snapshot.moves, result));
  }

  Future<void> _apply(int column) async {
    final moves = [...current.moves, column];
    final outcome = Connect4Rules.outcome(moves);
    final result = outcome == null
        ? null
        : GameResult(
            winner: outcome.asOutcome,
            endReason: outcome == Connect4Outcome.draw
                ? EnumGameEndReason.boardFull
                : EnumGameEndReason.connectFour,
          );
    final next = Connect4Rules.discToPlay(moves).color;
    emit(
      current.copyWith(
        moves: moves,
        result: result,
        acceptsInput: result == null && _seat(next) is HumanSeat,
      ),
    );
    if (result != null) {
      await _record(() => recorder?.onEnd(moves, result));
    } else {
      await _record(() => recorder?.onMove(moves));
      await _playBotIfItsTurn();
    }
  }

  Future<void> _playBotIfItsTurn() async {
    final snapshot = current;
    final seat = _seat(snapshot.colorToPlay);
    if (snapshot.isOver || seat is! BotSeat) return;
    final (column, _) = await (
      seat.chooseColumn(snapshot.moves),
      Future<void>.delayed(seat.thinkingTime),
    ).wait;
    // Partie abandonnée ou écran fermé pendant la réflexion.
    if (isDisposed || current.isOver || current.moves != snapshot.moves) {
      return;
    }
    await _apply(column);
  }

  Future<void> _record(Future<void>? Function() write) async {
    try {
      await write();
    } catch (_) {
      notice("La partie n'a pas pu être enregistrée sur l'appareil.");
    }
  }
}
