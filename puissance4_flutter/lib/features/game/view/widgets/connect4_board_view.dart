import 'package:flutter/material.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_rules/puissance4_rules.dart';

import '../../../../core/theme/app_palette.dart';

/// Plateau 7×6 dessiné à partir de la liste de coups : le dernier jeton
/// tombe (animation), l'alignement gagnant est cerclé, et un appui sur une
/// colonne appelle [onColumnTap] (désactivé si `null`). [hint] dessine un
/// jeton fantôme (coup recommandé par l'Expert dans un replay).
class Connect4BoardView extends StatelessWidget {
  const Connect4BoardView({
    super.key,
    required this.moves,
    this.onColumnTap,
    this.highlighted,
    this.hint,
  });

  final List<int> moves;
  final ValueChanged<int>? onColumnTap;

  /// Cases `(colonne, rangée)` à mettre en évidence (alignement gagnant).
  final List<(int, int)>? highlighted;

  /// Case `(colonne, rangée)` et couleur d'un jeton fantôme.
  final (int, int, EnumColor)? hint;

  /// Le plateau garde les couleurs du thème sombre dans les deux thèmes,
  /// comme un vrai plateau : le jaune vif des jetons ne se verrait pas sur
  /// un plateau blanc.
  static const _board = AppPalette.dark;

  /// Couleur d'un jeton (vive, quel que soit le thème).
  static Color colorOf(EnumColor color) =>
      color == EnumColor.rouge ? _board.primary : _board.yellow;

  static Color _discColor(Disc disc) =>
      disc == Disc.rouge ? _board.primary : _board.yellow;

  @override
  Widget build(BuildContext context) {
    final stacks = Connect4Rules.stacks(moves);
    final lastColumn = moves.isEmpty ? null : moves.last;
    final highlight = {...?highlighted};

    return AspectRatio(
      aspectRatio: Connect4Rules.columns / Connect4Rules.rows,
      child: Container(
        padding: const EdgeInsets.all(6),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: _board.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _board.divider),
        ),
        child: Row(
          children: [
            for (var column = 0; column < Connect4Rules.columns; column++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onColumnTap == null
                      ? null
                      : () => onColumnTap!(column),
                  child: Column(
                    children: [
                      // Rangée du haut en premier : on parcourt de 5 à 0.
                      for (var row = Connect4Rules.rows - 1; row >= 0; row--)
                        Expanded(
                          child: _Cell(
                            color: row < stacks[column].length
                                ? _discColor(stacks[column][row])
                                : null,
                            highlighted: highlight.contains((column, row)),
                            dropFrom:
                                column == lastColumn &&
                                    row == stacks[column].length - 1
                                ? Connect4Rules.rows - row
                                : null,
                            dropKey: moves.length,
                            hintColor:
                                hint != null &&
                                    hint!.$1 == column &&
                                    hint!.$2 == row
                                ? colorOf(hint!.$3)
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.color,
    required this.highlighted,
    required this.dropFrom,
    required this.dropKey,
    this.hintColor,
  });

  final Color? color;
  final bool highlighted;

  /// Dernier jeton posé : nombre de cases dont il tombe.
  final int? dropFrom;

  /// Rejoue l'animation à chaque nouveau coup.
  final int dropKey;

  /// Couleur du jeton fantôme à dessiner dans cette case vide.
  final Color? hintColor;

  @override
  Widget build(BuildContext context) {
    final disc = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: highlighted
            ? Border.all(color: Connect4BoardView._board.text, width: 3)
            : null,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Connect4BoardView._board.background,
            ),
          ),
          if (hintColor case final hint?)
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hint.withValues(alpha: 0.25),
                border: Border.all(color: hint, width: 2.5),
              ),
            ),
          if (color != null)
            dropFrom == null
                ? disc
                : TweenAnimationBuilder<double>(
                    key: ValueKey(dropKey),
                    tween: Tween(begin: -dropFrom!.toDouble(), end: 0),
                    duration: Duration(milliseconds: 120 + 45 * dropFrom!),
                    curve: Curves.bounceOut,
                    builder: (_, offset, child) => FractionalTranslation(
                      // Une case = hauteur du jeton + ses marges.
                      translation: Offset(0, offset * 1.18),
                      child: child,
                    ),
                    child: disc,
                  ),
        ],
      ),
    );
  }
}
