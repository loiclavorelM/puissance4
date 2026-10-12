import 'package:assistant_contracts/assistant_contracts.dart';

/// Messages et modèle de chat, calqués sur `IChatClient`
/// (Microsoft.Extensions.AI) pour que la boucle se traduise ligne à ligne
/// en C#. Indépendants du fournisseur : `OllamaChatModel` en est une
/// implémentation.
enum ChatRole { system, user, assistant, tool }

final class ToolCall {
  const ToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  factory ToolCall.fromJson(Json json) => ToolCall(
    id: json.string('id'),
    name: json.string('name'),
    arguments: json.objectOrNull('arguments') ?? const {},
  );

  final String id;
  final String name;
  final Json arguments;

  ToolCall copyWith({Json? arguments}) =>
      ToolCall(id: id, name: name, arguments: arguments ?? this.arguments);

  Json toJson() => {'id': id, 'name': name, 'arguments': arguments};
}

final class ChatMessage {
  const ChatMessage(
    this.role,
    this.content, {
    this.toolCalls = const [],
    this.toolName,
    this.toolCallId,
  });

  const ChatMessage.system(String content) : this(ChatRole.system, content);
  const ChatMessage.user(String content) : this(ChatRole.user, content);

  /// Résultat d'un appel d'outil.
  const ChatMessage.toolResult(String id, String name, String content)
    : this(ChatRole.tool, content, toolName: name, toolCallId: id);

  factory ChatMessage.fromJson(Json json) => ChatMessage(
    ChatRole.values.byName(json.string('role')),
    json.stringOrNull('content') ?? '',
    toolCalls: [
      for (final call in json.list('toolCalls'))
        ToolCall.fromJson((call! as Map).cast()),
    ],
    toolName: json.stringOrNull('toolName'),
    toolCallId: json.stringOrNull('toolCallId'),
  );

  final ChatRole role;
  final String content;
  final List<ToolCall> toolCalls;
  final String? toolName;
  final String? toolCallId;

  ChatMessage copyWith({String? content, List<ToolCall>? toolCalls}) =>
      ChatMessage(
        role,
        content ?? this.content,
        toolCalls: toolCalls ?? this.toolCalls,
        toolName: toolName,
        toolCallId: toolCallId,
      );

  Json toJson() => compact({
    'role': role.name,
    'content': content,
    if (toolCalls.isNotEmpty)
      'toolCalls': [for (final c in toolCalls) c.toJson()],
    'toolName': toolName,
    'toolCallId': toolCallId,
  });
}

/// Un outil tel que le LLM le voit : nom, description, schéma.
final class ToolSpec {
  const ToolSpec(this.name, this.description, this.parameters);

  final String name;
  final String description;
  final Json parameters;
}

final class ChatOptions {
  const ChatOptions({required this.model, this.tools = const []});

  final String model;
  final List<ToolSpec> tools;
}

final class ChatUsage {
  const ChatUsage(this.inputTokens, this.outputTokens);

  static const zero = ChatUsage(0, 0);

  final int inputTokens;
  final int outputTokens;

  ChatUsage operator +(ChatUsage other) => ChatUsage(
    inputTokens + other.inputTokens,
    outputTokens + other.outputTokens,
  );
}

final class ChatResponse {
  const ChatResponse(this.message, [this.usage = ChatUsage.zero]);

  /// Message de l'assistant : texte et/ou appels d'outils.
  final ChatMessage message;
  final ChatUsage usage;
}

abstract interface class ChatModel {
  Future<ChatResponse> getResponse(
    List<ChatMessage> messages,
    ChatOptions options,
  );
}
