import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

/// Table de correspondance d'une conversation : un jeton (`[Player:1]`)
/// pointe vers une référence (`user:<uuid>`), jamais vers le nom en clair.
/// Une valeur garde le même jeton toute la conversation, pour que le LLM
/// suive de qui on parle. Stockée en base (`AssistantToken`) : un autre
/// nœud du cluster peut reprendre la conversation.
final class TokenMap {
  TokenMap._(this._conversationId, this._byToken, this._byRef);

  static Future<TokenMap> load(
    Session session,
    UuidValue conversationId,
  ) async {
    final rows = await AssistantToken.db.find(
      session,
      where: (t) => t.conversationId.equals(conversationId),
    );
    return TokenMap._(
      conversationId,
      {for (final row in rows) row.token: row.ref},
      {for (final row in rows) row.ref: row.token},
    );
  }

  /// Pour les tests et l'outillage : sans base.
  TokenMap.memory() : this._(null, {}, {});

  final UuidValue? _conversationId;
  final Map<String, String> _byToken;
  final Map<String, String> _byRef;
  final _pending = <AssistantToken>[];

  static final pattern = RegExp(r'\[([A-Za-z]+):(\d+)\]');

  /// Le jeton de [ref], créé au besoin (`[kind:n]`, n croissant par type).
  String tokenFor(String ref, String kind) {
    final existing = _byRef[ref];
    if (existing != null) return existing;
    final count = _byToken.keys.where((t) => t.startsWith('[$kind:')).length;
    final token = '[$kind:${count + 1}]';
    _byToken[token] = ref;
    _byRef[ref] = token;
    if (_conversationId != null) {
      _pending.add(
        AssistantToken(
          conversationId: _conversationId,
          token: token,
          kind: kind,
          ref: ref,
        ),
      );
    }
    return token;
  }

  /// La référence d'un jeton, `null` s'il est inconnu (inventé par le LLM).
  String? refOf(String token) => _byToken[token];

  Iterable<String> get tokens => _byToken.keys;

  /// Enregistre les nouveaux jetons.
  Future<void> save(Session session) async {
    if (_pending.isEmpty) return;
    await AssistantToken.db.insert(session, List.of(_pending));
    _pending.clear();
  }
}
