import 'json.dart';

/// Une pastille choisie dans l'autocomplétion du chat : le backend attribue
/// le jeton sans rien deviner.
final class Mention {
  const Mention({required this.ref, required this.label});

  factory Mention.fromJson(Json json) =>
      Mention(ref: json.string('ref'), label: json.string('label'));

  /// `user:<uuid>` ou `bot:<uuid>`.
  final String ref;

  /// Texte de la pastille, tel qu'il apparaît dans le message.
  final String label;

  bool get isPlayer => ref.startsWith('user:');

  Json toJson() => {'ref': ref, 'label': label};
}

/// Message du joueur (`contracts/assistant-input.schema.json`).
final class ChatInput {
  const ChatInput({
    required this.text,
    this.language = 'fr',
    this.mentions = const [],
  });

  factory ChatInput.fromJson(Json json) => ChatInput(
    text: json.string('text'),
    language: json.stringOrNull('language') ?? 'fr',
    mentions: [
      for (final mention in json.list('mentions'))
        Mention.fromJson((mention! as Map).cast()),
    ],
  );

  static const maxLength = 1000;
  static const maxMentions = 10;

  final String text;
  final String language;
  final List<Mention> mentions;

  bool get isValid =>
      text.trim().isNotEmpty &&
      text.length <= maxLength &&
      mentions.length <= maxMentions &&
      (language == 'fr' || language == 'en');

  Json toJson() => {
    'text': text,
    'language': language,
    if (mentions.isNotEmpty) 'mentions': [for (final m in mentions) m.toJson()],
  };
}
