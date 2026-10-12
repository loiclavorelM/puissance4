import 'dart:async';

import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:flutter/foundation.dart';

import '../ports/ports.dart';

/// Un élément du fil de discussion.
sealed class ChatEntry {
  const ChatEntry();
}

final class UserEntry extends ChatEntry {
  const UserEntry(this.input);
  final ChatInput input;
}

final class AssistantTextEntry extends ChatEntry {
  const AssistantTextEntry(this.text);
  final String text;
}

/// Un widget proposé dans le chat, que le joueur peut épingler.
final class BlockEntry extends ChatEntry {
  BlockEntry(this.definition);
  final WidgetDefinition definition;
  bool pinned = false;
}

/// Un outil appelé par l'assistant (statut affiché pendant la demande).
final class ToolEntry extends ChatEntry {
  ToolEntry(this.tool, this.state);
  final String tool;
  ToolState state;
}

final class ErrorEntry extends ChatEntry {
  const ErrorEntry(this.code);
  final AssistantErrorCode code;
}

/// La conversation en cours avec l'assistant.
class ChatController extends ChangeNotifier {
  ChatController(this._client);

  final AssistantClient _client;
  final List<ChatEntry> _entries = [];
  String? _conversationId;
  StreamSubscription<AssistantEvent>? _subscription;
  bool _disposed = false;

  List<ChatEntry> get entries => List.unmodifiable(_entries);
  bool get isSending => _subscription != null;
  String? get conversationId => _conversationId;

  void send(ChatInput input) {
    if (isSending || !input.isValid) return;
    _entries.add(UserEntry(input));
    _subscription = _client
        .send(_conversationId, input)
        .listen(
          _onEvent,
          onError: (Object _) =>
              _finish(const ErrorEntry(AssistantErrorCode.unavailable)),
          onDone: () => _finish(null),
        );
    _notify();
  }

  void _onEvent(AssistantEvent event) {
    switch (event) {
      case StartedEvent(:final conversationId):
        _conversationId = conversationId;
      case ToolStatusEvent(:final tool, :final state):
        final running = _entries.reversed
            .whereType<ToolEntry>()
            .where((e) => e.tool == tool && e.state == ToolState.started)
            .firstOrNull;
        if (running != null && state != ToolState.started) {
          running.state = state;
        } else {
          _entries.add(ToolEntry(tool, state));
        }
      case BlockEvent(:final definition):
        _entries.add(BlockEntry(definition));
      case TextEvent(:final text):
        _entries.add(AssistantTextEntry(text));
      case ErrorEvent(:final code):
        _entries.add(ErrorEntry(code));
      case DashboardChangedEvent() || DoneEvent():
        // Le tableau de bord se recharge par son propre canal (LiveEvent).
        break;
    }
    _notify();
  }

  void _finish(ChatEntry? last) {
    if (last != null) _entries.add(last);
    _subscription = null;
    _notify();
  }

  void markPinned(BlockEntry entry) {
    entry.pinned = true;
    _notify();
  }

  /// Repart d'une conversation vide.
  void reset() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    _entries.clear();
    _conversationId = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
