import 'package:puissance4_rules/puissance4_rules.dart';
import 'package:serverpod/serverpod.dart';

import '../../game/enum_color_extensions.dart';
import '../../generated/protocol.dart';

enum OpponentKind { bot, human }

/// Une partie terminée du joueur, quel que soit le mode : la seule forme
/// que voient les sources de données (`Partie` pour Multi et Classé,
/// `OfflineMatchResult` pour Normal).
final class GameRecord {
  const GameRecord({
    required this.id,
    required this.mode,
    required this.playedAt,
    required this.result,
    required this.playedAs,
    required this.moves,
    required this.opponentKind,
    required this.opponentRef,
    required this.opponentName,
    this.eloDelta,
  });

  final UuidValue id;
  final EnumType mode;
  final DateTime playedAt;
  final EnumMatchResult result;
  final EnumColor playedAs;
  final List<int> moves;
  final OpponentKind opponentKind;

  /// `user:<uuid>` ou `bot:<uuid>` : identité stable, pour filtrer.
  final String opponentRef;
  final String opponentName;
  final int? eloDelta;

  Disc get myDisc => playedAs.disc;

  /// Cases `(colonne, rangée)`, 0-indexées, des pions de [disc].
  Iterable<(int, int)> cellsOf(Disc disc) sync* {
    final heights = List.filled(Connect4Rules.columns, 0);
    for (var i = 0; i < moves.length; i++) {
      final column = moves[i];
      final row = heights[column]++;
      if ((i.isEven ? Disc.rouge : Disc.jaune) == disc) yield (column, row);
    }
  }

  /// Cases de l'alignement gagnant, s'il appartient à [disc].
  List<(int, int)> winningCellsOf(Disc disc) {
    final cells = Connect4Rules.winningCells(moves);
    if (cells == null) return const [];
    final winner = moves.length.isOdd ? Disc.rouge : Disc.jaune;
    return winner == disc ? cells : const [];
  }
}
