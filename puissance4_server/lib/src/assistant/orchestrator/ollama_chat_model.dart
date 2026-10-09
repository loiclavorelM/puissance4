import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:assistant_contracts/assistant_contracts.dart';

import 'chat_model.dart';

/// [ChatModel] sur l'API chat d'Ollama Cloud (`POST /api/chat`, sans
/// streaming). Vérifié au lot 0 : les appels arrivent dans
/// `message.tool_calls[]` (`function.name`, `function.arguments` en objet,
/// et un `id` que la doc ne montre pas), les résultats repartent en
/// `{role: tool, tool_name, content}`.
class OllamaChatModel implements ChatModel {
  OllamaChatModel({
    required this.apiKey,
    this.timeout = const Duration(seconds: 60),
    Uri? endpoint,
  }) : _endpoint = endpoint ?? Uri.parse('https://ollama.com/api/chat');

  final String apiKey;
  final Duration timeout;
  final Uri _endpoint;
  static final _random = Random();

  @override
  Future<ChatResponse> getResponse(
    List<ChatMessage> messages,
    ChatOptions options,
  ) async {
    final http = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await http.postUrl(_endpoint);
      request.headers
        ..contentType = ContentType.json
        ..set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
      request.add(
        utf8.encode(
          jsonEncode({
            'model': options.model,
            'stream': false,
            'messages': [for (final m in messages) _encode(m)],
            if (options.tools.isNotEmpty)
              'tools': [
                for (final tool in options.tools)
                  {
                    'type': 'function',
                    'function': {
                      'name': tool.name,
                      'description': tool.description,
                      'parameters': tool.parameters,
                    },
                  },
              ],
          }),
        ),
      );
      final response = await request.close().timeout(timeout);
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout);
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Ollama ${response.statusCode}: $body');
      }
      final json = (jsonDecode(body) as Map).cast<String, Object?>();
      final message = json.objectOrNull('message') ?? const {};
      return ChatResponse(
        ChatMessage(
          ChatRole.assistant,
          (message.stringOrNull('content') ?? '').trim(),
          toolCalls: [
            for (final raw in message.list('tool_calls'))
              _decodeCall((raw! as Map).cast()),
          ],
        ),
        ChatUsage(
          json.intOrNull('prompt_eval_count') ?? 0,
          json.intOrNull('eval_count') ?? 0,
        ),
      );
    } finally {
      http.close(force: true);
    }
  }

  static Json _encode(ChatMessage message) => switch (message.role) {
    ChatRole.tool => {
      'role': 'tool',
      'tool_name': message.toolName,
      'content': message.content,
    },
    ChatRole.assistant when message.toolCalls.isNotEmpty => {
      'role': 'assistant',
      'content': message.content,
      'tool_calls': [
        for (final call in message.toolCalls)
          {
            'id': call.id,
            'function': {'name': call.name, 'arguments': call.arguments},
          },
      ],
    },
    _ => {'role': message.role.name, 'content': message.content},
  };

  static ToolCall _decodeCall(Json json) {
    final function = json.objectOrNull('function') ?? const {};
    final arguments = function['arguments'];
    return ToolCall(
      // Pas d'id garanti par l'API : on en génère un s'il manque.
      id:
          json.stringOrNull('id') ??
          'call_${_random.nextInt(1 << 32).toRadixString(36)}',
      name: function.stringOrNull('name') ?? '',
      arguments: switch (arguments) {
        final Map<String, Object?> map => map,
        final Map map => map.cast(),
        // Certains modèles renvoient les arguments en chaîne JSON.
        final String text => _tryDecode(text),
        _ => const {},
      },
    );
  }

  static Json _tryDecode(String text) {
    try {
      return (jsonDecode(text) as Map).cast();
    } on Object {
      return const {};
    }
  }
}
