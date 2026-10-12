import 'package:puissance4_rules/puissance4_rules.dart';

/// Prompt d'explication d'un coup (E14). Le LLM ne calcule rien : tout ce
/// qui est vérifiable (coup recommandé, victoires immédiates, menaces) est
/// calculé ici par les règles et l'Expert, il n'a qu'à le mettre en mots.
abstract final class MovePrompt {
  static String system(String language) {
    final lang = language == 'en' ? 'English' : 'French';
    return 'You are a friendly Connect Four coach reviewing a finished game '
        'with a player. You are given a position, the move that was played '
        'and the move recommended by an engine, plus facts computed by the '
        'engine. Explain in $lang, in 2 to 4 short sentences, why the '
        'recommended move is better (or, if the played move was already the '
        'best, why it was a good move). Rely only on the given facts and on '
        'the board: never contradict them and never invent threats. Refer '
        'to columns by their number (1 to 7, left to right). Plain text, no '
        'markdown, no heading.';
  }

  /// Message utilisateur pour le coup d'indice [index] de [moves].
  static String user(List<int> moves, int index, MoveAnalysis analysis) {
    final before = moves.sublist(0, index);
    final me = MoveAnalysis.playerOf(index);
    final them = me.other;
    final played = analysis.played;
    final recommended = analysis.recommended;
    final threatFor = Connect4Rules.winningMoveFor(before, them);
    final winFor = Connect4Rules.winningMoveFor(before, me);
    final opponentWinAfterPlayed =
        Connect4Rules.outcome([...before, played]) == null
        ? Connect4Rules.winningMoveFor([...before, played], them)
        : null;

    String col(int c) => '${c + 1}';
    String name(Disc d) => d == Disc.rouge ? 'Red (X)' : 'Yellow (O)';
    String verdict(MoveVerdict v) => switch (v) {
      MoveVerdict.forcedWin => 'leads to a forced win for ${name(me)}',
      MoveVerdict.forcedLoss => 'leads to a forced loss for ${name(me)}',
      MoveVerdict.open => 'nothing forced within the engine horizon',
    };

    return [
      'Board before the move (row 6 at the top, columns 1 to 7):',
      _board(before),
      '',
      'Player to move: ${name(me)} (move number ${index + 1}).',
      'Played: column ${col(played)} — ${verdict(analysis.playedVerdict)}.',
      if (analysis.isBest)
        'The played move is as good as the engine choice '
            '(column ${col(recommended)}).'
      else
        'Engine recommendation: column ${col(recommended)} — '
            '${verdict(analysis.recommendedVerdict)}.',
      'Facts:',
      if (winFor != null)
        '- ${name(me)} could win immediately in column ${col(winFor)}.',
      if (threatFor != null)
        '- ${name(them)} threatened to win immediately in column '
            '${col(threatFor)}.',
      if (opponentWinAfterPlayed != null)
        '- After the played move, ${name(them)} can win immediately in '
            'column ${col(opponentWinAfterPlayed)}.',
      if (winFor == null && threatFor == null && opponentWinAfterPlayed == null)
        '- No immediate win or threat on this move.',
    ].join('\n');
  }

  static String _board(List<int> moves) {
    final stacks = Connect4Rules.stacks(moves);
    final lines = <String>[];
    for (var row = Connect4Rules.rows - 1; row >= 0; row--) {
      lines.add(
        [
          for (var c = 0; c < Connect4Rules.columns; c++)
            row < stacks[c].length
                ? (stacks[c][row] == Disc.rouge ? 'X' : 'O')
                : '.',
        ].join(' '),
      );
    }
    lines.add('1 2 3 4 5 6 7');
    return lines.join('\n');
  }
}
