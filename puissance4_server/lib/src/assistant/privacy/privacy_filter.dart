import 'package:assistant_contracts/assistant_contracts.dart';
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../orchestrator/chat_model.dart';
import 'exposure_policy.dart';
import 'name_index.dart';
import 'token_map.dart';

/// Le filtre de confidentialité de l'orchestrateur : on ne chiffre pas, on
/// **remplace** les valeurs sensibles par des jetons (`[Player:1]`), et la
/// correspondance reste sur le serveur. Il intervient à cinq endroits, et
/// les outils n'en savent rien :
/// 1. la question du joueur ([pseudonymizeInput]) ;
/// 2. les arguments des outils, rétablis avant exécution ([restoreArguments]) ;
/// 3. les résultats des outils ([protectResult]) ;
/// 4. la réponse affichée ([restoreText]) ;
/// 5. tout ce qui part vers le LLM, en dernier contrôle ([guardEgress]) —
///    et c'est cette version, avec jetons, qui est enregistrée.
final class PrivacyFilter {
  PrivacyFilter({
    required this.policy,
    required this.index,
    required this.tokens,
    required this.selfRef,
    required this.selfName,
    Map<String, String> labels = const {},
  }) : _labels = {...labels, selfRef: selfName};

  final ExposurePolicy policy;
  final NameIndex index;
  final TokenMap tokens;

  /// `user:<uuid>` du joueur, et son pseudo.
  final String selfRef;
  final String selfName;

  /// Nom affiché de chaque référence rencontrée (pour rétablir).
  final Map<String, String> _labels;

  static const _playerKind = 'Player';

  String _tokenFor(String ref, String label, {String kind = _playerKind}) {
    _labels[ref] = label;
    return ref == selfRef ? policy.selfToken : tokens.tokenFor(ref, kind);
  }

  /// [text] sans aucune valeur sensible connue : noms du dictionnaire, puis
  /// formats (codes ami → jeton, codes de salle → masqués).
  String pseudonymizeText(String text) {
    final matches = index.find(text);
    final buffer = StringBuffer();
    var cursor = 0;
    for (final match in matches) {
      buffer
        ..write(text.substring(cursor, match.start))
        ..write(_tokenFor(match.ref, text.substring(match.start, match.end)));
      cursor = match.end;
    }
    buffer.write(text.substring(cursor));
    var result = buffer.toString();
    for (final MapEntry(key: kind, value: pattern) in policy.formats.entries) {
      result = result.replaceAllMapped(pattern, (m) {
        // Déjà un jeton ([Player:12] contient des chiffres) : on n'y touche pas.
        if (_insideToken(result, m.start)) return m[0]!;
        return kind == 'RoomCode'
            ? '[RoomCode]'
            : _tokenFor('${kind.toLowerCase()}:${m[0]}', m[0]!, kind: kind);
      });
    }
    return result;
  }

  static bool _insideToken(String text, int index) {
    final open = text.lastIndexOf('[', index);
    final close = text.lastIndexOf(']', index);
    return open > close && text.indexOf(']', index) > index;
  }

  /// La question : d'abord les mentions (le joueur a choisi qui, aucun
  /// risque de se tromper), puis le dictionnaire et les formats.
  String pseudonymizeInput(ChatInput input) {
    var text = input.text;
    for (final mention in input.mentions) {
      if (!mention.isPlayer || mention.label.isEmpty) continue;
      text = text.replaceAll(
        RegExp(RegExp.escape(mention.label), caseSensitive: false),
        _tokenFor(mention.ref, mention.label),
      );
    }
    return pseudonymizeText(text);
  }

  /// Arguments d'un appel d'outil, jetons rétablis : un jeton seul devient
  /// la référence (les outils filtrent par id, deux homonymes restent
  /// distincts), un jeton dans un texte (un titre) devient le nom.
  Json restoreArguments(Json args) =>
      _mapStrings(args, (value) {
            final whole = TokenMap.pattern.matchAsPrefix(value.trim());
            if (whole != null && whole.end == value.trim().length) {
              final ref = value.trim() == policy.selfToken
                  ? selfRef
                  : tokens.refOf(value.trim());
              if (ref != null) {
                return ref.startsWith('friendcode:') ? ref.substring(11) : ref;
              }
            }
            if (value.trim() == policy.selfToken) return selfRef;
            return restoreText(value);
          })
          as Json;

  /// Résultat d'un outil : règles de champ de `ai-exposure.json` sur les
  /// lignes typées (champ masqué retiré, champ pseudonymisé remplacé par le
  /// jeton de sa référence), puis dictionnaire sur tout le texte.
  Json protectResult(Json result) {
    final protected = result.containsKey('fields') && result.containsKey('rows')
        ? _protectRows(result)
        : result;
    return _mapStrings(protected, pseudonymizeText) as Json;
  }

  Json _protectRows(Json result) {
    final fields = [
      for (final field in result.list('fields'))
        (field! as Map).cast<String, Object?>(),
    ];
    final names = [for (final f in fields) f.string('name')];
    final refIndex = names.indexOf('opponentRef');
    final hidden = <int>{
      for (var i = 0; i < names.length; i++)
        if (policy.fields[names[i]]?.exposure == Exposure.hidden) i,
    };
    final rows = [
      for (final raw in result.list('rows'))
        () {
          final row = List<Object?>.from(raw! as List);
          for (var i = 0; i < names.length; i++) {
            final rule = policy.fields[names[i]];
            if (rule?.exposure != Exposure.pseudonymized || row[i] is! String) {
              continue;
            }
            final unless = rule!.unlessField == null
                ? -1
                : names.indexOf(rule.unlessField!);
            if (unless >= 0 && row[unless] == rule.unlessEquals) continue;
            final ref = refIndex >= 0 ? row[refIndex] as String? : null;
            row[i] = ref == null
                ? pseudonymizeText(row[i]! as String)
                : _tokenFor(
                    ref,
                    row[i]! as String,
                    kind: rule.kind ?? _playerKind,
                  );
          }
          return [
            for (var i = 0; i < row.length; i++)
              if (!hidden.contains(i)) row[i],
          ];
        }(),
    ];
    return {
      ...result,
      'fields': [
        for (var i = 0; i < fields.length; i++)
          if (!hidden.contains(i)) fields[i],
      ],
      'rows': rows,
    };
  }

  /// Texte du LLM, jetons → vrais noms. Un jeton inventé reste tel quel.
  String restoreText(String text) => text
      .replaceAllMapped(TokenMap.pattern, (m) {
        final token = m[0]!;
        final ref = token == policy.selfToken ? selfRef : tokens.refOf(token);
        if (ref == null) return token;
        return _labels[ref] ??
            (ref.startsWith('friendcode:') ? ref.substring(11) : token);
      })
      .replaceAll(policy.selfToken, selfName);

  /// Dernier contrôle avant l'envoi : le même dictionnaire sur toute la
  /// requête (historique, résultats d'outils, texte libre). Ce qui aurait
  /// échappé aux étapes précédentes est remplacé ici.
  List<ChatMessage> guardEgress(List<ChatMessage> messages) => [
    for (final message in messages)
      message.role == ChatRole.system
          ? message
          : message.copyWith(
              content: pseudonymizeText(message.content),
              toolCalls: [
                for (final call in message.toolCalls)
                  call.copyWith(
                    arguments:
                        _mapStrings(call.arguments, pseudonymizeText) as Json,
                  ),
              ],
            ),
  ];

  static Object? _mapStrings(Object? value, String Function(String) map) =>
      switch (value) {
        final String text => map(text),
        final Map<dynamic, dynamic> object => <String, Object?>{
          for (final MapEntry(:key, :value) in object.entries)
            '$key': _mapStrings(value, map),
        },
        final List<dynamic> list => [
          for (final item in list) _mapStrings(item, map),
        ],
        _ => value,
      };
}

/// L'index des pseudos de tous les joueurs, gardé en cache et reconstruit
/// quand un pseudo change (nombre de joueurs ou dernière mise à jour
/// différents) : vérification à chaque demande, cohérente en cluster.
abstract final class NameDirectory {
  static NameIndex? _index;
  static String? _signature;

  static Future<NameIndex> index(Session session, ExposurePolicy policy) async {
    final stats = await session.db.unsafeQuery(
      'SELECT count(*), max(coalesce("updatedAt", "createdAt")) FROM "user"',
    );
    final signature = '${stats.first[0]}|${stats.first[1]}';
    if (_index != null && signature == _signature) return _index!;
    final users = await User.db.find(session);
    _index = NameIndex(
      {for (final user in users) user.username: 'user:${user.id}'},
      minLength: policy.minLength,
      commonWords: policy.commonWords,
    );
    _signature = signature;
    return _index!;
  }

  /// Noms actuels des références `user:<uuid>` de [refs].
  static Future<Map<String, String>> labels(
    Session session,
    Iterable<String> refs,
  ) async {
    final ids = {
      for (final ref in refs)
        if (ref.startsWith('user:')) UuidValue.withValidation(ref.substring(5)),
    };
    if (ids.isEmpty) return const {};
    return {
      for (final user in await User.db.find(
        session,
        where: (t) => t.id.inSet(ids),
      ))
        'user:${user.id}': user.username,
    };
  }
}
