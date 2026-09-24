import 'package:puissance4_server/src/ranked/elo.dart';
import 'package:test/test.dart';

void main() {
  group('Given Elo.delta', () {
    test('when 1000 beats 1200 then it gains 24 (cahier des charges)', () {
      expect(Elo.delta(1000, 1200, 1), 24);
    });

    test('when 1000 loses to 1200 then it loses 8 (cahier des charges)', () {
      expect(Elo.delta(1000, 1200, 0), -8);
    });

    test('when equal players draw then nothing changes', () {
      expect(Elo.delta(1000, 1000, 0.5), 0);
    });
  });
}
