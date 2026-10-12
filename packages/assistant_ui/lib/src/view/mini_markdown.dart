import 'package:flutter/material.dart';

/// Markdown limité de l'assistant : gras et listes à puces seulement. Les
/// liens gardent leur texte et perdent leur adresse, les images
/// disparaissent : rien ne sort par la réponse.
class MiniMarkdown extends StatelessWidget {
  const MiniMarkdown(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  static final _image = RegExp(r'!\[[^\]]*\]\([^)]*\)');
  static final _link = RegExp(r'\[([^\]]+)\]\([^)]*\)');
  static final _url = RegExp(r'https?://\S+');
  static final _bullet = RegExp(r'^\s*[-*•]\s+');
  static final _heading = RegExp(r'^#{1,6}\s+');

  /// [text] sans ce qui pourrait faire sortir le joueur de l'app.
  static String sanitize(String text) => text
      .replaceAll(_image, '')
      .replaceAllMapped(_link, (m) => m[1]!)
      .replaceAll(_url, '');

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final lines = sanitize(text).trim().split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final raw in lines)
          if (raw.trim().isEmpty)
            const SizedBox(height: 6)
          else if (_bullet.hasMatch(raw))
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 1, bottom: 1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: base),
                  Expanded(
                    child: Text.rich(
                      _spans(raw.replaceFirst(_bullet, ''), base),
                    ),
                  ),
                ],
              ),
            )
          else
            Text.rich(_spans(raw.replaceFirst(_heading, ''), base)),
      ],
    );
  }

  /// `**gras**` → gras ; le reste tel quel.
  static TextSpan _spans(String line, TextStyle base) {
    final parts = line.split('**');
    return TextSpan(
      style: base,
      children: [
        for (var i = 0; i < parts.length; i++)
          TextSpan(
            text: parts[i],
            style: i.isOdd && i < parts.length - 1
                ? const TextStyle(fontWeight: FontWeight.w700)
                : null,
          ),
      ],
    );
  }
}
