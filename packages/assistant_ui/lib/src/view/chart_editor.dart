import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:flutter/material.dart';

import '../labels.dart';
import '../theme/dashboard_tokens.dart';

/// Panneau « Modifier », comme un graphique croisé dynamique : source,
/// type, axes, mesure, séries, top N, période. Il ne propose que des choix
/// valides d'après `chart-rules.json` et les types des champs, et travaille
/// sur les mêmes arguments à plat que l'assistant ([WidgetArgs]) : les deux
/// modifient le même objet, avec les mêmes règles.
class ChartEditor extends StatefulWidget {
  const ChartEditor({super.key, this.initial, required this.onSave});

  /// `null` pour un nouveau widget.
  final WidgetDefinition? initial;
  final ValueChanged<WidgetDefinition> onSave;

  static Future<void> show(
    BuildContext context, {
    WidgetDefinition? initial,
    required ValueChanged<WidgetDefinition> onSave,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ChartEditor(initial: initial, onSave: onSave),
  );

  @override
  State<ChartEditor> createState() => _ChartEditorState();
}

class _ChartEditorState extends State<ChartEditor> {
  static final _catalog = AssistantContracts.catalog;
  static final _rules = AssistantContracts.chartRules;
  static final _args = WidgetArgs(_catalog, _rules);

  late Json _state = widget.initial == null
      ? {'type': 'chart', 'title': '', 'source': 'games.byDay'}
      : _args.toArgs(widget.initial!);
  late final _title = TextEditingController(text: _state['title'] as String?);

  WidgetDefinition get _definition {
    final (definition, _) = _args.build({
      ..._state,
      'title': _title.text.trim(),
    });
    final initial = widget.initial;
    return initial == null
        ? definition
        : definition.copyWith(id: initial.id, layout: initial.layout);
  }

  /// Comme `update_widget` : changer de source ou de type de graphique
  /// repart des valeurs par défaut pour les axes.
  void _change(Json changes, {List<String> clear = const []}) => setState(() {
    final (updated, _) = _args.update(_definition, changes, clear: clear);
    _state = _args.toArgs(updated);
  });

  void _set(String key, Object? value) => setState(() {
    if (value == null) {
      _state.remove(key);
    } else {
      _state[key] = value;
    }
  });

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = DashboardLabels.of(context);
    final l10n = labels.l10n;
    final tokens = context.dashboardTokens;
    final definition = _definition;
    final source = _catalog[definition.query.source]!;
    final chart = definition.chart;
    final errors = [
      ..._rules.validate(definition, _catalog),
      if (_title.text.trim().isEmpty) '',
    ];

    List<DropdownMenuItem<String?>> fields(
      ChartChannel channel, {
      bool none = false,
    }) => [
      if (none)
        DropdownMenuItem(value: null, child: Text(l10n.editorColorNone)),
      if (chart != null)
        for (final field in _rules.allowedFields(
          chart.mark,
          channel,
          source,
          _catalog,
        ))
          DropdownMenuItem(
            value: field.name,
            child: Text(labels.field(field.name)),
          ),
    ];

    final markRule = chart == null ? null : _rules.marks[chart.mark]!;
    final types = source.kind == SourceKind.kpi
        ? [WidgetType.kpi]
        : [WidgetType.chart, WidgetType.table];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.initial == null ? l10n.editorNewTitle : l10n.editorTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              maxLength: 60,
              decoration: InputDecoration(labelText: l10n.editorTitleField),
              onChanged: (_) => setState(() {}),
            ),
            _Row(
              label: l10n.editorSource,
              child: DropdownButton<String>(
                isExpanded: true,
                value: source.key,
                items: [
                  for (final s in _catalog.sources.values)
                    DropdownMenuItem(
                      value: s.key,
                      child: Text(labels.source(s.key)),
                    ),
                ],
                onChanged: (key) {
                  if (key == null || key == source.key) return;
                  final kind = _catalog[key]!.kind;
                  _change({
                    'source': key,
                    'type': kind == SourceKind.kpi
                        ? 'kpi'
                        : (definition.type == WidgetType.kpi
                              ? 'chart'
                              : definition.type.name),
                  });
                },
              ),
            ),
            if (types.length > 1)
              _Row(
                label: l10n.editorType,
                child: SegmentedButton<WidgetType>(
                  segments: [
                    for (final type in types)
                      ButtonSegment(
                        value: type,
                        label: Text(labels.type(type)),
                      ),
                  ],
                  selected: {definition.type},
                  onSelectionChanged: (s) => _set('type', s.single.name),
                ),
              ),
            if (chart != null) ...[
              _Row(
                label: l10n.editorMark,
                child: DropdownButton<ChartMark>(
                  isExpanded: true,
                  value: chart.mark,
                  items: [
                    for (final mark in ChartMark.values)
                      DropdownMenuItem(
                        value: mark,
                        child: Text(labels.mark(mark)),
                      ),
                  ],
                  onChanged: (mark) {
                    if (mark != null && mark != chart.mark) {
                      _change({'mark': mark.name});
                    }
                  },
                ),
              ),
              if (markRule!.channels.containsKey(ChartChannel.x))
                _Row(
                  label: l10n.editorX,
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: chart.x?.field,
                    items: fields(ChartChannel.x),
                    onChanged: (f) => _set('x', f),
                  ),
                ),
              if (markRule.channels.containsKey(ChartChannel.y))
                _Row(
                  label: l10n.editorY,
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: chart.y?.field,
                    items: fields(ChartChannel.y),
                    onChanged: (f) => _set('y', f),
                  ),
                ),
              if (markRule.channels.containsKey(ChartChannel.value))
                _Row(
                  label: l10n.editorValue,
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: chart.value?.field,
                    items: fields(ChartChannel.value),
                    onChanged: (f) => _set('value', f),
                  ),
                ),
              _Row(
                label: l10n.editorAggregate,
                child: DropdownButton<Aggregate>(
                  isExpanded: true,
                  value: (chart.y ?? chart.value)?.aggregate ?? Aggregate.sum,
                  items: [
                    for (final aggregate in Aggregate.values)
                      DropdownMenuItem(
                        value: aggregate,
                        child: Text(labels.aggregate(aggregate)),
                      ),
                  ],
                  onChanged: (a) =>
                      _set('aggregate', a == Aggregate.sum ? null : a?.name),
                ),
              ),
              if (markRule.channels.containsKey(ChartChannel.color)) ...[
                _Row(
                  label: l10n.editorColor,
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: chart.color?.field,
                    items: fields(ChartChannel.color, none: true),
                    onChanged: (f) {
                      _set('color', f);
                      if (f == null) _set('stack', null);
                    },
                  ),
                ),
                if (chart.color != null)
                  _Row(
                    label: l10n.editorTopN,
                    child: DropdownButton<int?>(
                      isExpanded: true,
                      value: chart.color!.limit,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('–')),
                        for (var n = 1; n <= 10; n++)
                          DropdownMenuItem(value: n, child: Text('$n')),
                      ],
                      onChanged: (n) => _set('colorLimit', n),
                    ),
                  ),
              ],
              if (markRule.options.contains('stack') && chart.color != null)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.editorStack),
                  value: chart.stack,
                  onChanged: (v) => _set('stack', v ? true : null),
                ),
              if (markRule.options.contains('horizontal'))
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.editorHorizontal),
                  value: chart.horizontal,
                  onChanged: (v) => _set('horizontal', v ? true : null),
                ),
            ],
            if (source.params.contains('range'))
              _Row(
                label: l10n.editorPeriod,
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: switch (definition.query.params['range']) {
                    final String range
                        when !range.startsWith(dashboardPrefix) =>
                      range,
                    _ => null,
                  },
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.editorFollowDashboard),
                    ),
                    for (final range in RelativeRange.values)
                      DropdownMenuItem(
                        value: range,
                        child: Text(labels.range(range)),
                      ),
                  ],
                  onChanged: (range) {
                    _set('range', range);
                    if (range != null) _set('lastGames', null);
                  },
                ),
              ),
            if (errors.any((e) => e.isNotEmpty)) ...[
              const SizedBox(height: 8),
              Text(
                errors.where((e) => e.isNotEmpty).join('\n'),
                style: TextStyle(color: tokens.danger, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: errors.isEmpty
                      ? () {
                          widget.onSave(definition);
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Text(l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(color: context.dashboardTokens.textMuted),
          ),
        ),
        Expanded(child: child),
      ],
    ),
  );
}
