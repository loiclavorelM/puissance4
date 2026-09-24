/// Couleur d'un jeton. Rouge commence toujours.
enum Disc {
  rouge,
  jaune;

  Disc get other => this == rouge ? jaune : rouge;
}

/// Issue d'une partie terminée.
enum Connect4Outcome { rouge, jaune, draw }

/// Règles du Puissance 4, sans état : une partie est entièrement décrite par
/// sa liste de coups (numéros de colonne 0..6), Rouge jouant les coups
/// d'indice pair.
abstract final class Connect4Rules {
  static const columns = 7;
  static const rows = 6;

  /// Couleur qui doit jouer après [moves].
  static Disc discToPlay(List<int> moves) =>
      moves.length.isEven ? Disc.rouge : Disc.jaune;

  /// `true` si [column] peut recevoir un jeton après [moves].
  static bool isValidMove(List<int> moves, int column) =>
      column >= 0 &&
      column < columns &&
      moves.where((c) => c == column).length < rows;

  /// Colonnes encore jouables après [moves].
  static List<int> validMoves(List<int> moves) => [
    for (var column = 0; column < columns; column++)
      if (isValidMove(moves, column)) column,
  ];

  /// Jetons de chaque colonne, du bas vers le haut.
  static List<List<Disc>> stacks(List<int> moves) {
    final stacks = List.generate(columns, (_) => <Disc>[]);
    for (var i = 0; i < moves.length; i++) {
      stacks[moves[i]].add(i.isEven ? Disc.rouge : Disc.jaune);
    }
    return stacks;
  }

  /// Résultat de la partie après [moves] : `null` tant qu'elle continue.
  ///
  /// Ne regarde que le dernier coup — seul lui peut avoir créé un
  /// alignement, les précédents ayant déjà été vérifiés.
  static Connect4Outcome? outcome(List<int> moves) {
    if (moves.isEmpty) return null;
    final board = stacks(moves);
    final lastColumn = moves.last;
    final lastRow = board[lastColumn].length - 1;
    final disc = board[lastColumn][lastRow];
    if (winningLine(board, lastColumn, lastRow) != null) {
      return disc == Disc.rouge ? Connect4Outcome.rouge : Connect4Outcome.jaune;
    }
    return moves.length == columns * rows ? Connect4Outcome.draw : null;
  }

  /// Cases `(colonne, rangée)` de l'alignement gagnant passant par le
  /// dernier coup, ou `null` — pour les mettre en évidence à l'écran.
  static List<(int, int)>? winningCells(List<int> moves) {
    if (moves.isEmpty) return null;
    final board = stacks(moves);
    final lastColumn = moves.last;
    return winningLine(board, lastColumn, board[lastColumn].length - 1);
  }

  /// Alignement d'au moins 4 jetons passant par `(column, row)`.
  static List<(int, int)>? winningLine(
    List<List<Disc>> board,
    int column,
    int row,
  ) {
    Disc? at(int c, int r) =>
        c < 0 || c >= columns || r < 0 || r >= board[c].length
        ? null
        : board[c][r];

    final disc = at(column, row);
    if (disc == null) return null;
    const directions = [(1, 0), (0, 1), (1, 1), (1, -1)];
    for (final (dc, dr) in directions) {
      final line = [(column, row)];
      for (final sign in const [1, -1]) {
        var c = column + dc * sign;
        var r = row + dr * sign;
        while (at(c, r) == disc) {
          line.add((c, r));
          c += dc * sign;
          r += dr * sign;
        }
      }
      if (line.length >= 4) return line;
    }
    return null;
  }

  /// Colonne où [disc] gagnerait immédiatement après [moves], ou `null`.
  /// Utilisé par les IA pour gagner ou bloquer.
  static int? winningMoveFor(List<int> moves, Disc disc) {
    final board = stacks(moves);
    for (final column in validMoves(moves)) {
      board[column].add(disc);
      final wins = winningLine(board, column, board[column].length - 1) != null;
      board[column].removeLast();
      if (wins) return column;
    }
    return null;
  }
}
