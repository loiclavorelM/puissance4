import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:flutter/material.dart';

import '../controllers/widget_data_controller.dart';
import '../l10n/assistant_ui_localizations.dart';
import '../ports/ports.dart';
import '../theme/dashboard_tokens.dart';
import '../widgets/widget_bodies.dart';

enum WidgetMenuAction { edit, rename, remove }

/// Carte d'un widget : titre, menu, et le corps selon l'état des données
/// (chargement, erreur avec réessai, vide).
class WidgetFrame extends StatelessWidget {
  const WidgetFrame({
    super.key,
    required this.title,
    required this.child,
    this.onMenu,
    this.trailing,
  });

  final String title;
  final Widget child;
  final ValueChanged<WidgetMenuAction>? onMenu;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.dashboardTokens;
    final l10n = AssistantUiLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tokens.grid),
      ),
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: tokens.text,
                  ),
                ),
              ),
              ?trailing,
              if (onMenu != null)
                PopupMenuButton<WidgetMenuAction>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: tokens.textMuted,
                  ),
                  onSelected: onMenu,
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: WidgetMenuAction.edit,
                      child: Text(l10n.widgetEdit),
                    ),
                    PopupMenuItem(
                      value: WidgetMenuAction.rename,
                      child: Text(l10n.widgetRename),
                    ),
                    PopupMenuItem(
                      value: WidgetMenuAction.remove,
                      child: Text(l10n.widgetRemove),
                    ),
                  ],
                )
              else
                const SizedBox(height: 40),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Un widget branché sur ses données : crée et garde son
/// [WidgetDataController], le met à jour quand la définition ou les filtres
/// changent.
class LiveWidget extends StatefulWidget {
  const LiveWidget({
    super.key,
    required this.definition,
    required this.filters,
    required this.client,
    required this.builder,
    this.onSelect,
  });

  final WidgetDefinition definition;
  final DashboardFilters filters;
  final DataSourceClient client;

  /// Construit la carte autour du corps (données ou état de chargement).
  final Widget Function(BuildContext context, Widget body) builder;

  /// Clic sur une valeur, avec les données affichées.
  final void Function(String field, Object? value, SourceData data)? onSelect;

  @override
  State<LiveWidget> createState() => _LiveWidgetState();
}

class _LiveWidgetState extends State<LiveWidget> {
  late final WidgetDataController _controller = WidgetDataController(
    widget.client,
    widget.definition,
    widget.filters,
  );

  @override
  void didUpdateWidget(LiveWidget old) {
    super.didUpdateWidget(old);
    _controller.update(widget.definition, widget.filters);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) => widget.builder(context, _body(context)),
  );

  Widget _body(BuildContext context) {
    final tokens = context.dashboardTokens;
    final l10n = AssistantUiLocalizations.of(context);
    final data = _controller.data;
    if (data == null && _controller.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.widgetLoadError,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: tokens.textMuted),
            ),
            TextButton(onPressed: _controller.reload, child: Text(l10n.retry)),
          ],
        ),
      );
    }
    if (data == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (WidgetRegistry.isEmpty(data)) {
      return Center(
        child: Text(
          l10n.widgetNoData,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: tokens.textMuted),
        ),
      );
    }
    final onSelect = widget.onSelect;
    return WidgetRegistry.build(
      widget.definition,
      data,
      onSelect: onSelect == null
          ? null
          : (field, value) => onSelect(field, value, data),
    );
  }
}
