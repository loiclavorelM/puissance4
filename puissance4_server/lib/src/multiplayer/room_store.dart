import 'dart:async';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Salle d'attente Multi : un hôte, un code, pas encore d'adversaire. Jamais
/// en base — une `Partie` n'est créée qu'une fois l'adversaire arrivé, pour
/// qu'aucune salle abandonnée ne laisse de partie fantôme.
class Room {
  Room({
    required this.code,
    required this.hostAuthUserId,
    required this.hostUserId,
    required this.expiresAt,
  });

  final String code;
  final UuidValue hostAuthUserId;

  /// `User.id` (profil de jeu) de l'hôte.
  final UuidValue hostUserId;
  final DateTime expiresAt;
}

/// Stockage des salles d'attente. Seule pièce du Multi à dépendre du nombre
/// de serveurs : [InMemoryRoomStore] suffit pour un seul serveur ; en cluster
/// (Redis activé), une autre implémentation partagée la remplace dans
/// `multiplayer_config.dart` — table `salle` réservée par un
/// `DELETE … RETURNING`, ou script Redis `GETDEL`. Le reste du Multi passe
/// déjà par la base et `session.messages`.
abstract interface class RoomStore {
  /// Ouvre une salle pour cet hôte. Une salle déjà ouverte par le même hôte
  /// est fermée et renvoyée dans `replaced`, pour que l'appelant prévienne
  /// son ancien stream.
  Future<({Room room, Room? replaced})> create({
    required UuidValue hostAuthUserId,
    required UuidValue hostUserId,
    required Duration lifetime,
  });

  /// Retire la salle [code] pour [guestAuthUserId] et la renvoie, ou `null`
  /// si elle n'existe pas ou plus. Atomique : de deux joueurs qui tapent le
  /// même code, un seul obtient la salle. Lève `GameException(ownRoom)` —
  /// sans retirer la salle — si l'invité en est l'hôte.
  Future<Room?> claim(String code, {required UuidValue guestAuthUserId});

  /// Ferme la salle [code] si elle appartient encore à [hostAuthUserId] (le
  /// stream de l'hôte se ferme sans adversaire).
  Future<void> remove(String code, UuidValue hostAuthUserId);

  /// Rend à son hôte une salle obtenue par [claim] que l'invité n'a pas pu
  /// utiliser. `false` si c'est trop tard (expirée, code repris, ou l'hôte a
  /// déjà ouvert une autre salle) : l'appelant la ferme alors pour de bon.
  Future<bool> restore(Room room);
}

/// [RoomStore] en mémoire du serveur : une `Map` qu'aucun `await` ne
/// traverse entre lecture et écriture, donc atomique sur l'isolate unique.
/// Les salles meurent avec le serveur, ce qui est voulu (aucun stream d'hôte
/// n'y survit non plus).
class InMemoryRoomStore implements RoomStore {
  InMemoryRoomStore({Random? random}) : _random = random ?? Random.secure();

  /// Sans 0/O ni 1/I/L, pour un code lisible à voix haute.
  static const _alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const codeLength = 6;

  final Random _random;
  final _byCode = <String, Room>{};
  final _codeByHost = <UuidValue, String>{};

  @override
  Future<({Room room, Room? replaced})> create({
    required UuidValue hostAuthUserId,
    required UuidValue hostUserId,
    required Duration lifetime,
  }) async {
    _purgeExpired();
    final previousCode = _codeByHost.remove(hostAuthUserId);
    final replaced = previousCode == null ? null : _byCode.remove(previousCode);

    String code;
    do {
      code = List.generate(
        codeLength,
        (_) => _alphabet[_random.nextInt(_alphabet.length)],
      ).join();
    } while (_byCode.containsKey(code));

    final room = Room(
      code: code,
      hostAuthUserId: hostAuthUserId,
      hostUserId: hostUserId,
      expiresAt: DateTime.now().toUtc().add(lifetime),
    );
    _byCode[code] = room;
    _codeByHost[hostAuthUserId] = code;
    return (room: room, replaced: replaced);
  }

  @override
  Future<Room?> claim(
    String code, {
    required UuidValue guestAuthUserId,
  }) async {
    _purgeExpired();
    final normalized = code.trim().toUpperCase();
    final room = _byCode[normalized];
    if (room == null) return null;
    if (room.hostAuthUserId == guestAuthUserId) {
      throw GameException(reason: EnumGameError.ownRoom);
    }
    _byCode.remove(normalized);
    _codeByHost.remove(room.hostAuthUserId);
    return room;
  }

  @override
  Future<void> remove(String code, UuidValue hostAuthUserId) async {
    if (_byCode[code]?.hostAuthUserId != hostAuthUserId) return;
    _byCode.remove(code);
    _codeByHost.remove(hostAuthUserId);
  }

  @override
  Future<bool> restore(Room room) async {
    _purgeExpired();
    if (!room.expiresAt.isAfter(DateTime.now().toUtc()) ||
        _byCode.containsKey(room.code) ||
        _codeByHost.containsKey(room.hostAuthUserId)) {
      return false;
    }
    _byCode[room.code] = room;
    _codeByHost[room.hostAuthUserId] = room.code;
    return true;
  }

  /// Filet de sécurité : le stream de l'hôte ferme déjà sa salle à
  /// l'expiration, mais une salle dont le stream serait mort sans prévenir
  /// ne doit pas rester réservable.
  void _purgeExpired() {
    final now = DateTime.now().toUtc();
    _byCode.removeWhere((code, room) {
      final expired = !room.expiresAt.isAfter(now);
      if (expired) _codeByHost.remove(room.hostAuthUserId);
      return expired;
    });
  }
}
