import 'package:flutter_test/flutter_test.dart';
import 'package:puissance4_flutter/features/friends/view/rivalries_tab.dart';

void main() {
  test('a streak shows from two games in a row', () {
    expect(rivalryStreakLabel(3), '🔥 3');
    expect(rivalryStreakLabel(-2), '❄️ 2');
    expect(rivalryStreakLabel(1), isNull);
    expect(rivalryStreakLabel(-1), isNull);
    expect(rivalryStreakLabel(0), isNull);
  });
}
