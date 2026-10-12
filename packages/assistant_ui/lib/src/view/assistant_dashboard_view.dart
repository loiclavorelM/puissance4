import 'dart:async';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/chat_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../export/widget_export.dart';
import '../l10n/assistant_ui_localizations.dart';
import '../labels.dart';
import '../ports/ports.dart';
import '../theme/dashboard_tokens.dart';
import 'chart_editor.dart';
import 'chat_panel.dart';
import 'dashboard_grid.dart';
import 'filter_bar.dart';
import 'widget_frame.dart';

/// Le tableau de bord complet : filtres, grille, actions (annuler, ajouter ;
/// modifier, exporter en PDF ou CSV par widget) et chat de l'assistant — en
/// feuille sur téléphone, en panneau à droite au-delà de [sidePanelFrom] de
/// large.
class AssistantDashboardView extends StatelessWidget {
  const AssistantDashboardView({
    super.key,
    required this.dashboard,
    required this.data,
    this.chat,
    this.sidePanelFrom = 1000,
  });

  final DashboardController dashboard;
  final DataSourceClient data;

  /// `null` : pas d'assistant (tableau de bord seul).
  final ChatController? chat;
  final double sidePanelFrom;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final side = chat != null && constraints.maxWidth >= sidePanelFrom;
      final board = _Board(
        dashboard: dashboard,
        data: data,
        chat: side ? null : chat,
      );
      if (!side) return board;
      return Row(
        children: [
          Expanded(child: board),
          VerticalDivider(width: 1, color: context.dashboardTokens.grid),
          SizedBox(
            width: 380,
            child: ListenableBuilder(
              listenable: dashboard,
              builder: (context, _) => _ChatSheet(
                chat: chat!,
                data: data,
                dashboard: dashboard,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _Board extends StatefulWidget {
  const _Board({
    required this.dashboard,
    required this.data,
    required this.chat,
  });

  final DashboardController dashboard;
  final DataSourceClient data;
  final ChatController? chat;

  @override
  State<_Board> createState() => _BoardState();
}

class _BoardState extends State<_Board> {
  final _captures = WidgetCaptures();

  DashboardController get dashboard => widget.dashboard;
  DataSourceClient get data => widget.data;
  ChatController? get chat => widget.chat;

  /// Exporte un seul widget, avec ses données du moment (mêmes filtres qu'à
  /// l'écran) : PDF mis en page ou CSV, puis feuille de partage
  /// (téléchargement sur le web).
  Future<void> _export(
    BuildContext context,
    WidgetDefinition definition, {
    required bool pdf,
  }) async {
    final l10n = AssistantUiLocalizations.of(context);
    final labels = DashboardLabels.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final filters = dashboard.dashboard!.filters;
    final params = filters.resolve(definition.query.params);
    final scope = [
      labels.range(params['range'] as String?),
      if (params['lastGames'] case final int last) l10n.exportLastGames(last),
      if (params['mode'] case final String mode) labels.value('mode', mode),
      if (filters.opponentLabel case final opponent?
          when params['opponent'] != null)
        opponent,
    ].join(' · ');
    try {
      final export = WidgetExport(
        definition: definition,
        data: await data.query(definition.query.source, params),
        labels: labels,
        scope: scope,
        chartImage: pdf && definition.type == WidgetType.chart
            ? await _captures.png(definition.id!)
            : null,
      );
      final (bytes, mime, name) = pdf
          ? (await export.pdf(), 'application/pdf', export.fileName('pdf'))
          : (export.csv(), 'text/csv', export.fileName('csv'));
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: mime, name: name)],
          fileNameOverrides: [name],
          downloadFallbackEnabled: true,
        ),
      );
    } on Object {
      messenger?.showSnackBar(SnackBar(content: Text(l10n.exportFailed)));
    }
  }

  Future<void> _guard(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(AssistantUiLocalizations.of(context).widgetLoadError),
          ),
        );
      }
    }
  }

  Future<void> _rename(BuildContext context, WidgetDefinition widget) async {
    final l10n = AssistantUiLocalizations.of(context);
    final controller = TextEditingController(text: widget.title);
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (title != null && title.isNotEmpty && context.mounted) {
      await _guard(context, () => dashboard.rename(widget, title));
    }
  }

  void _onMenu(
    BuildContext context,
    WidgetDefinition widget,
    WidgetMenuAction action,
  ) {
    switch (action) {
      case WidgetMenuAction.edit:
        unawaited(
          ChartEditor.show(
            context,
            initial: widget,
            onSave: (edited) =>
                _guard(context, () => dashboard.saveWidget(edited)),
          ),
        );
      case WidgetMenuAction.rename:
        unawaited(_rename(context, widget));
      case WidgetMenuAction.remove:
        unawaited(_guard(context, () => dashboard.removeWidget(widget.id!)));
      case WidgetMenuAction.exportPdf:
        unawaited(_export(context, widget, pdf: true));
      case WidgetMenuAction.exportCsv:
        unawaited(_export(context, widget, pdf: false));
    }
  }

  /// Clic sur une valeur : le drilldown du widget s'il en a un, sinon un
  /// adversaire filtre tout le tableau de bord.
  void _onSelect(
    BuildContext context,
    WidgetDefinition widget,
    String field,
    Object? value,
    SourceData source,
  ) {
    final ref = _opponentRef(field, value, source);
    if (ref == null) return;
    final drilldown = widget.drilldown;
    if (drilldown != null) {
      unawaited(
        showModalBottomSheet<void>(
          context: context,
          useSafeArea: true,
          builder: (_) => SizedBox(
            height: 360,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LiveWidget(
                definition: WidgetDefinition(
                  type: WidgetType.table,
                  title: '${value ?? ''}',
                  query: DataQuery(drilldown.source, {'opponent': ref.ref}),
                ),
                filters: DashboardFilters.none,
                client: data,
                builder: (context, body) =>
                    WidgetFrame(title: ref.label, child: body),
              ),
            ),
          ),
        ),
      );
      return;
    }
    final filters = dashboard.dashboard!.filters;
    unawaited(
      _guard(
        context,
        () => dashboard.setFilters(
          filters.copyWith(
            opponent: () => ref.ref,
            opponentLabel: () => ref.label,
          ),
        ),
      ),
    );
  }

  /// La référence de l'adversaire cliqué : la ligne porte `opponentRef`.
  ({String ref, String label})? _opponentRef(
    String field,
    Object? value,
    SourceData source,
  ) {
    if (source is! DataSet) return null;
    final refIndex = source.indexOf('opponentRef');
    final nameIndex = source.indexOf('opponent');
    if (refIndex < 0 || nameIndex < 0) return null;
    final row = source.rows
        .where(
          (r) => field == 'opponentRef'
              ? r[refIndex] == value
              : r[nameIndex] == value,
        )
        .firstOrNull;
    return row == null
        ? null
        : (ref: row[refIndex] as String, label: '${row[nameIndex]}');
  }

  void _openChat(BuildContext context) => unawaited(
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        child: _ChatSheet(chat: chat!, data: data, dashboard: dashboard),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AssistantUiLocalizations.of(context);
    final tokens = context.dashboardTokens;
    return ListenableBuilder(
      listenable: dashboard,
      builder: (context, _) {
        final current = dashboard.dashboard;
        if (current == null) {
          return Center(
            child: dashboard.error == null
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: dashboard.reload,
                    child: Text(l10n.retry),
                  ),
          );
        }
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: chat == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openChat(context),
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(l10n.chatTitle),
                ),
          body: RefreshIndicator(
            onRefresh: dashboard.reload,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DashboardFilterBar(
                        filters: current.filters,
                        onChanged: (filters) => _guard(
                          context,
                          () => dashboard.setFilters(filters),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.undo,
                      onPressed: current.version == 0
                          ? null
                          : () => _guard(context, () => dashboard.undo()),
                      icon: const Icon(Icons.undo),
                    ),
                    IconButton(
                      tooltip: l10n.addWidget,
                      onPressed: () => ChartEditor.show(
                        context,
                        onSave: (widget) =>
                            _guard(context, () => dashboard.saveWidget(widget)),
                      ),
                      icon: const Icon(Icons.add_chart),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (current.widgets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 48,
                      horizontal: 24,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.dashboard_customize_outlined,
                          size: 48,
                          color: tokens.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.dashboardEmptyTitle,
                          style: TextStyle(fontSize: 16, color: tokens.text),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.dashboardEmptyBody,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: tokens.textMuted),
                        ),
                      ],
                    ),
                  )
                else
                  DashboardGrid(
                    dashboard: current,
                    itemBuilder: (context, widget) => LiveWidget(
                      key: ValueKey(widget.id),
                      definition: widget,
                      filters: current.filters,
                      client: data,
                      onSelect: (field, value, source) =>
                          _onSelect(context, widget, field, value, source),
                      builder: (context, body) => WidgetFrame(
                        title: widget.title,
                        onMenu: (action) => _onMenu(context, widget, action),
                        // Fond plein : l'image du graphique exporté reste
                        // lisible sur une page blanche.
                        child: _captures.capture(
                          widget.id!,
                          ColoredBox(color: tokens.surface, child: body),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChatSheet extends StatelessWidget {
  const _ChatSheet({
    required this.chat,
    required this.data,
    required this.dashboard,
  });

  final ChatController chat;
  final DataSourceClient data;
  final DashboardController dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AssistantUiLocalizations.of(context);
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.auto_awesome),
          title: Text(l10n.chatTitle),
          trailing: IconButton(
            tooltip: l10n.chatNewConversation,
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: chat.reset,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ChatPanel(
            controller: chat,
            data: data,
            filters: dashboard.dashboard?.filters ?? DashboardFilters.none,
            onPin: (definition) async {
              await dashboard.saveWidget(definition);
              if (context.mounted) {
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                  SnackBar(content: Text(l10n.widgetPinned)),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
