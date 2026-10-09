import 'json.dart';
import 'widget_definition.dart';

enum ToolState { started, done, failed }

/// Codes d'erreur de l'assistant : l'app les traduit, jamais de texte.
enum AssistantErrorCode {
  notConfigured,
  unavailable,
  rateLimited,
  tooManySteps,
  invalidInput,
}

/// Événements du stream de l'assistant (`contracts/assistant-events.schema.json`).
sealed class AssistantEvent {
  const AssistantEvent();

  factory AssistantEvent.fromJson(Json json) => switch (json.string('event')) {
    'started' => StartedEvent(json.string('conversationId')),
    'toolStatus' => ToolStatusEvent(
      json.string('tool'),
      ToolState.values.byName(json.string('state')),
    ),
    'dashboardChanged' => DashboardChangedEvent(json.intOrNull('version')!),
    'block' => BlockEvent(
      WidgetDefinition.fromJson(json.objectOrNull('definition')!),
    ),
    'text' => TextEvent(json.string('text')),
    'done' => DoneEvent(
      inputTokens: json.objectOrNull('usage')?.intOrNull('inputTokens') ?? 0,
      outputTokens: json.objectOrNull('usage')?.intOrNull('outputTokens') ?? 0,
    ),
    _ => ErrorEvent(
      AssistantErrorCode.values.asNameMap()[json.stringOrNull('code')] ??
          AssistantErrorCode.unavailable,
    ),
  };

  Json toJson();
}

/// Premier événement : la conversation (créée si besoin) à réutiliser.
final class StartedEvent extends AssistantEvent {
  const StartedEvent(this.conversationId);
  final String conversationId;

  @override
  Json toJson() => {'event': 'started', 'conversationId': conversationId};
}

final class ToolStatusEvent extends AssistantEvent {
  const ToolStatusEvent(this.tool, this.state);
  final String tool;
  final ToolState state;

  @override
  Json toJson() => {'event': 'toolStatus', 'tool': tool, 'state': state.name};
}

final class DashboardChangedEvent extends AssistantEvent {
  const DashboardChangedEvent(this.version);
  final int version;

  @override
  Json toJson() => {'event': 'dashboardChanged', 'version': version};
}

/// Un widget proposé dans le chat, que le joueur peut épingler.
final class BlockEvent extends AssistantEvent {
  const BlockEvent(this.definition);
  final WidgetDefinition definition;

  @override
  Json toJson() => {'event': 'block', 'definition': definition.toJson()};
}

final class TextEvent extends AssistantEvent {
  const TextEvent(this.text);
  final String text;

  @override
  Json toJson() => {'event': 'text', 'text': text};
}

final class DoneEvent extends AssistantEvent {
  const DoneEvent({this.inputTokens = 0, this.outputTokens = 0});
  final int inputTokens;
  final int outputTokens;

  @override
  Json toJson() => {
    'event': 'done',
    'usage': {'inputTokens': inputTokens, 'outputTokens': outputTokens},
  };
}

final class ErrorEvent extends AssistantEvent {
  const ErrorEvent(this.code);
  final AssistantErrorCode code;

  @override
  Json toJson() => {'event': 'error', 'code': code.name};
}
