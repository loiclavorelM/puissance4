import 'package:puissance4_client/puissance4_client.dart';

import '../../../client.dart';
import '../../offline/model/local_cache.dart';

/// Appels `client.friends.*` (E15). Toutes les actions peuvent lever une
/// [FriendsException].
class FriendsRepository {
  FriendsRepository(this._cache);

  final LocalCache _cache;

  /// Onglet Amis en cache d'abord (s'il existe), puis depuis le serveur.
  Stream<FriendsOverviewDto> watchOverview(UuidValue authUserId) =>
      _cache.cacheThenNetwork(
        authUserId: authUserId,
        name: 'friends',
        fetch: client.friends.getOverview,
        decode: (json) =>
            FriendsOverviewDto.fromJson(json as Map<String, dynamic>),
        encode: (overview) => overview.toJson(),
      );

  Future<List<PlayerSearchResultDto>> search(String query) =>
      client.friends.searchPlayers(query);

  Future<FriendshipDto> sendRequest(UuidValue userId) =>
      client.friends.sendRequest(userId);

  Future<FriendshipDto> accept(UuidValue friendshipId) =>
      client.friends.acceptRequest(friendshipId);

  Future<void> decline(UuidValue friendshipId) =>
      client.friends.declineRequest(friendshipId);

  Future<void> cancel(UuidValue friendshipId) =>
      client.friends.cancelRequest(friendshipId);

  Future<void> remove(UuidValue userId) => client.friends.removeFriend(userId);

  /// Le joueur courant vient de secouer : le joueur qui a secoué en même
  /// temps (US15.6), ou `null` après ~2 s.
  Future<PlayerSearchResultDto?> shakeToAdd() => client.friends.shakeToAdd();

  Future<List<PlayerSearchResultDto>> recentOpponents() =>
      client.friends.recentOpponents();

  /// Défis reçus encore ouverts (salles réservées au joueur).
  Future<List<FriendChallengeDto>> challenges() =>
      client.friends.getChallenges();

  Future<void> declineChallenge(String code) =>
      client.friends.declineChallenge(code);
}
