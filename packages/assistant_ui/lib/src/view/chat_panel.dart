import 'dart:async';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:flutter/material.dart';

import '../controllers/chat_controller.dart';
import '../labels.dart';
import '../ports/ports.dart';
import '../theme/dashboard_tokens.dart';
import 'mini_markdown.dart';
import 'widget_frame.dart';

/// Le chat de l'assistant : fil de discussion, blocs épinglables, saisie
/// avec mentions (`@` + nom d'un adversaire → pastille qui porte son id :
/// le backend attribue le jeton sans rien deviner).
class ChatPanel extends StatefulWidget {
  const ChatPanel({
    super.key,
    required this.controller,
    required this.data,
    required this.filters,
    required this.onPin,
  });

  final ChatController controller;
  final DataSourceClient data;

  /// Filtres du tableau de bord, repris par les blocs du chat.
  final DashboardFilters filters;
  final Future<void> Function(WidgetDefinition definition) onPin;

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _mentions = <Mention>[];
  List<MentionSuggestion> _suggestions = const [];
  Timer? _debounce;

  static final _mentionQuery = RegExp(r'@(\S*)$');

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_scrollToEnd);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scrollToEnd);
    _debounce?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) {
      unawaited(
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        ),
      );
    }
  });

  void _onTyping(String text) {
    _debounce?.cancel();
    final query = _mentionQuery.firstMatch(text)?.group(1);
    if (query == null) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final found = await widget.data.searchMentions(query);
      if (mounted) setState(() => _suggestions = found);
    });
  }

  void _pick(MentionSuggestion suggestion) {
    final text = _input.text.replaceFirst(
      _mentionQuery,
      '${suggestion.mention.label} ',
    );
    _input.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() {
      _mentions.add(suggestion.mention);
      _suggestions = const [];
    });
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final language = Localizations.localeOf(context).languageCode == 'en'
        ? 'en'
        : 'fr';
    widget.controller.send(
      ChatInput(
        text: text,
        language: language,
        mentions: [
          for (final mention in {for (final m in _mentions) m.ref: m}.values)
            if (text.contains(mention.label)) mention,
        ],
      ),
    );
    _input.clear();
    _mentions.clear();
    setState(() => _suggestions = const []);
  }

  @override
  Widget build(BuildContext context) {
    final labels = DashboardLabels.of(context);
    final tokens = context.dashboardTokens;
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final entries = widget.controller.entries;
        return Column(
          children: [
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          labels.l10n.chatEmpty,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: tokens.textMuted),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(12),
                      itemCount:
                          entries.length +
                          (widget.controller.isSending ? 1 : 0),
                      itemBuilder: (context, index) => index == entries.length
                          ? _Thinking(label: labels.l10n.chatThinking)
                          : _entry(context, entries[index], labels),
                    ),
            ),
            if (_suggestions.isNotEmpty)
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final suggestion in _suggestions)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          avatar: Icon(
                            suggestion.isBot
                                ? Icons.smart_toy_outlined
                                : Icons.person_outline,
                            size: 16,
                          ),
                          label: Text(suggestion.mention.label),
                          onPressed: () => _pick(suggestion),
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: ChatInput.maxLength,
                      textInputAction: TextInputAction.send,
                      onChanged: _onTyping,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: labels.l10n.chatHint,
                        counterText: '',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: labels.l10n.chatSend,
                    onPressed: widget.controller.isSending ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _entry(BuildContext context, ChatEntry entry, DashboardLabels labels) {
    final tokens = context.dashboardTokens;
    return switch (entry) {
      UserEntry(:final input) => _Bubble(
        mine: true,
        child: Text(input.text, style: TextStyle(color: tokens.text)),
      ),
      AssistantTextEntry(:final text) => _Bubble(
        mine: false,
        child: MiniMarkdown(
          text,
          style: TextStyle(color: tokens.text, fontSize: 14),
        ),
      ),
      ToolEntry(:final tool, :final state) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 14,
              child: switch (state) {
                ToolState.started => const CircularProgressIndicator(
                  strokeWidth: 1.5,
                ),
                ToolState.done => Icon(
                  Icons.check,
                  size: 14,
                  color: tokens.success,
                ),
                ToolState.failed => Icon(
                  Icons.replay,
                  size: 14,
                  color: tokens.warn,
                ),
              },
            ),
            const SizedBox(width: 8),
            Text(
              labels.tool(tool),
              style: TextStyle(fontSize: 12, color: tokens.textMuted),
            ),
          ],
        ),
      ),
      BlockEntry() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SizedBox(
          height: entry.definition.type == WidgetType.kpi ? 130 : 260,
          child: LiveWidget(
            definition: entry.definition,
            filters: widget.filters,
            client: widget.data,
            builder: (context, body) => WidgetFrame(
              title: entry.definition.title,
              trailing: entry.pinned
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.push_pin,
                        size: 18,
                        color: tokens.accent,
                      ),
                    )
                  : TextButton.icon(
                      onPressed: () async {
                        await widget.onPin(entry.definition.unplaced);
                        widget.controller.markPinned(entry);
                      },
                      icon: const Icon(Icons.push_pin_outlined, size: 16),
                      label: Text(labels.l10n.widgetPin),
                    ),
              child: body,
            ),
          ),
        ),
      ),
      ErrorEntry(:final code) => _Bubble(
        mine: false,
        child: Text(labels.error(code), style: TextStyle(color: tokens.danger)),
      ),
    };
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.mine, required this.child});

  final bool mine;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.dashboardTokens;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: mine
              ? tokens.accent.withValues(alpha: 0.15)
              : tokens.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
    );
  }
}

class _Thinking extends StatelessWidget {
  const _Thinking({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, color: context.dashboardTokens.textMuted),
    ),
  );
}
