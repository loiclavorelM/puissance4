import 'dart:convert';

import 'package:serverpod_client/serverpod_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache local (JSON dans `shared_preferences`) des dernières réponses
/// serveur — profil, classement, historique — pour afficher quelque chose
/// immédiatement au démarrage et hors-ligne, puis rafraîchir depuis le
/// réseau (voir [cacheThenNetwork]).
///
/// Les clés sont préfixées par l'`authUserId` : un changement de compte sur
/// le même appareil ne montre jamais les données de l'ancien, même si
/// [clear] (appelé à la déconnexion) n'a pas encore fini.
class LocalCache {
  LocalCache({SharedPreferencesAsync? prefs})
    : _prefs = prefs ?? SharedPreferencesAsync();

  static const _prefix = 'cache.';

  final SharedPreferencesAsync _prefs;

  String _key(UuidValue authUserId, String name) =>
      '$_prefix${authUserId.uuid}.$name';

  /// `null` si absent ou illisible (ex. format d'un DTO changé depuis).
  Future<T?> read<T>(
    UuidValue authUserId,
    String name,
    T Function(Object? json) decode,
  ) async {
    final raw = await _prefs.getString(_key(authUserId, name));
    if (raw == null) return null;
    try {
      return decode(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> write(UuidValue authUserId, String name, Object? json) =>
      _prefs.setString(_key(authUserId, name), jsonEncode(json));

  /// Émet la valeur en cache (si elle existe), puis la réponse réseau une
  /// fois arrivée — qui remplace le cache. Si le réseau échoue alors qu'on
  /// avait déjà une valeur en cache, l'erreur est avalée : l'écran garde les
  /// dernières données connues plutôt que d'afficher une erreur.
  Stream<T> cacheThenNetwork<T>({
    required UuidValue authUserId,
    required String name,
    required Future<T> Function() fetch,
    required T Function(Object? json) decode,
    required Object? Function(T value) encode,
  }) async* {
    final cached = await read(authUserId, name, decode);
    if (cached != null) yield cached;
    final T fresh;
    try {
      fresh = await fetch();
    } catch (_) {
      if (cached == null) rethrow;
      return;
    }
    yield fresh;
    await write(authUserId, name, encode(fresh));
  }

  /// Vide tout le cache (tous comptes confondus) — à la déconnexion.
  Future<void> clear() async {
    final keys = await _prefs.getKeys();
    final ours = keys.where((key) => key.startsWith(_prefix)).toSet();
    if (ours.isNotEmpty) await _prefs.clear(allowList: ours);
  }
}
