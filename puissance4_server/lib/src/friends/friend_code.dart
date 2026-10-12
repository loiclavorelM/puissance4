import 'dart:math';

import 'package:serverpod/serverpod.dart';

/// Code ami (E15) : 6 caractères sans les signes ambigus (0/O, 1/I/L),
/// affiché `P4-XXXXXX` côté app. 31⁶ ≈ 9·10⁸ codes : un tirage au hasard
/// suffit, l'index unique de `User.friendCode` tranche en cas de doublon.
abstract final class FriendCode {
  static const length = 6;
  static const prefix = 'P4-';
  static const _alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

  static final _random = Random.secure();

  static String generate() => List.generate(
    length,
    (_) => _alphabet[_random.nextInt(_alphabet.length)],
  ).join();

  /// [input] tel que saisi (`p4-7kq2x9`, `P4 7KQ2X9`, `7kq2x9`…) ramené au
  /// code stocké, ou `null` s'il ne peut pas en être un.
  static String? parse(String input) {
    var code = input.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    if (code.length == length + 2 && code.startsWith('P4')) {
      code = code.substring(2);
    }
    if (code.length != length) return null;
    return code.split('').every(_alphabet.contains) ? code : null;
  }
}

/// Clé d'une paire de joueurs, identique dans les deux sens :
/// `Friendship.pairKey` n'admet qu'une ligne par paire.
String friendPairKey(UuidValue a, UuidValue b) {
  final ids = [a.uuid, b.uuid]..sort();
  return ids.join(':');
}
