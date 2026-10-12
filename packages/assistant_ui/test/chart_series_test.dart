import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:assistant_ui/assistant_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DataSet rows(List<List<Object?>> rows) => DataSet(
    fields: const [
      DataField('opponent', FieldType.category),
      DataField('result', FieldType.category),
      DataField('count', FieldType.number),
    ],
    rows: rows,
  );

  test('series split by color, missing cells stay null', () {
    final chart = PreparedChart.prepare(
      rows([
        ['A', 'win', 2],
        ['A', 'loss', 1],
        ['B', 'win', 3],
      ]),
      const ChartSpec(
        mark: ChartMark.bar,
        x: Encoding('opponent'),
        y: Encoding('count'),
        color: ColorEncoding('result'),
      ),
    );
    expect(chart.categories, ['A', 'B']);
    expect(chart.series.map((s) => s.key), ['win', 'loss']);
    expect(chart.series.map((s) => s.values), [
      [2.0, 3.0],
      [1.0, null],
    ]);
    expect(chart.maxStacked, 3);
  });

  test('without color, rows sharing x are aggregated', () {
    final data = rows([
      ['A', 'win', 2],
      ['A', 'loss', 1],
    ]);
    PreparedChart prepare(Aggregate aggregate) => PreparedChart.prepare(
      data,
      ChartSpec(
        mark: ChartMark.bar,
        x: const Encoding('opponent'),
        y: Encoding('count', aggregate: aggregate),
      ),
    );
    expect(prepare(Aggregate.sum).series.single.values, [3]);
    expect(prepare(Aggregate.avg).series.single.values, [1.5]);
    expect(prepare(Aggregate.count).series.single.values, [2]);
  });

  test('top N keeps the biggest series and groups the rest as Others', () {
    final chart = PreparedChart.prepare(
      rows([
        ['A', 'win', 5],
        ['A', 'loss', 1],
        ['A', 'draw', 2],
      ]),
      const ChartSpec(
        mark: ChartMark.bar,
        x: Encoding('opponent'),
        y: Encoding('count'),
        color: ColorEncoding('result', limit: 1),
      ),
    );
    expect(chart.series.map((s) => s.key), ['win', othersKey]);
    expect(chart.series.map((s) => s.values), [
      [5.0],
      [3.0],
    ]);
  });

  test('horizontal bars are sorted by total, biggest first', () {
    final chart = PreparedChart.prepare(
      rows([
        ['A', 'win', 1],
        ['B', 'win', 4],
        ['C', 'win', 2],
      ]),
      const ChartSpec(
        mark: ChartMark.bar,
        x: Encoding('opponent'),
        y: Encoding('count'),
        horizontal: true,
      ),
    );
    expect(chart.categories, ['B', 'C', 'A']);
  });

  test('a heatmap is a numeric grid, bottom row first', () {
    final data =
        SourceData.fromJson(AssistantContracts.fixture('data.moves.byCell'))
            as DataSet;
    final heatmap = PreparedHeatmap.prepare(
      data,
      const ChartSpec(
        mark: ChartMark.heatmap,
        x: Encoding('column'),
        y: Encoding('row'),
        value: Encoding('discs'),
      ),
    );
    expect(heatmap.xs, ['1', '2', '3', '4', '5', '6', '7']);
    expect(heatmap.ys.first, '1');
    expect(heatmap.values, hasLength(6));
  });

  test('assistant text never carries links or images', () {
    expect(
      MiniMarkdown.sanitize(
        'Voir ![x](http://a/b.png) [ici](https://evil.test) ou https://x.y',
      ),
      'Voir  ici ou ',
    );
  });
}
