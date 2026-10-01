import 'package:puissance4_client/puissance4_client.dart';

import '../../../client.dart';
import '../../offline/model/local_cache.dart';

class BotRepository {
  BotRepository(this._cache);

  final LocalCache _cache;

  /// Bots proposés en mode Normal, triés par elo. En cache d'abord puis
  /// depuis le serveur pour rester jouable hors-ligne — sauf sans
  /// `authUserId` (invité local), où il n'y a pas de clé de cache : appel
  /// réseau seul.
  Stream<List<Bot>> watchBots(UuidValue? authUserId) {
    if (authUserId == null) return Stream.fromFuture(client.bot.getBots());
    return _cache.cacheThenNetwork<List<Bot>>(
      authUserId: authUserId,
      name: 'bots',
      fetch: client.bot.getBots,
      decode: (json) => (json as List)
          .map((e) => Bot.fromJson(e as Map<String, dynamic>))
          .toList(),
      encode: (bots) => bots.map((bot) => bot.toJson()).toList(),
    );
  }
}
