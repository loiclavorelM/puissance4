import 'package:puissance4_server/src/assistant/orchestrator/answer_text.dart';
import 'package:test/test.dart';

void main() {
  test('a markdown table copied by the model is removed', () {
    const answer =
        '**Win rate by mode and month**\n'
        '\n'
        '| mode | month | win rate |\n'
        '|------|-------|----------|\n'
        '| normal | — | … |\n'
        '\n'
        'The exact numbers are in the widget.';
    expect(
      withoutMarkdownTables(answer),
      '**Win rate by mode and month**\n\nThe exact numbers are in the widget.',
    );
  });

  test('an answer without a table is unchanged', () {
    const answer = 'You won **7** games.\n\n- 4 in Normal\n- 3 in Ranked';
    expect(withoutMarkdownTables(answer), answer);
  });
}
