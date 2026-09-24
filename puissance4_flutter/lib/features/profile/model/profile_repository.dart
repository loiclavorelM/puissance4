import 'package:puissance4_client/puissance4_client.dart';

import '../../../client.dart';

class ProfileRepository {
  Future<UserProfileDto> fetchMyProfile() => client.profile.getMyProfile();

  /// Lève [ProfileUpdateException] si le pseudo est invalide ou déjà pris.
  Future<UserProfileDto> updateUsername(String username) =>
      client.profile.updateUsername(username);
}
