import 'package:puissance4_client/puissance4_client.dart';

import '../../../client.dart';
import '../../offline/model/local_cache.dart';

class ProfileRepository {
  ProfileRepository(this._cache);

  final LocalCache _cache;

  Future<UserProfileDto> fetchMyProfile() => client.profile.getMyProfile();

  /// Profil en cache d'abord (s'il existe), puis celui du serveur.
  Stream<UserProfileDto> watchMyProfile(UuidValue authUserId) =>
      _cache.cacheThenNetwork(
        authUserId: authUserId,
        name: 'profile',
        fetch: fetchMyProfile,
        decode: (json) => UserProfileDto.fromJson(json as Map<String, dynamic>),
        encode: (profile) => profile.toJson(),
      );

  /// Lève [ProfileUpdateException] si le pseudo est invalide ou déjà pris.
  Future<UserProfileDto> updateUsername(String username) =>
      client.profile.updateUsername(username);
}
