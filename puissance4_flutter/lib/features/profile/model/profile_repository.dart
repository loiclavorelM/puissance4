import 'package:puissance4_client/puissance4_client.dart';

import '../../../client.dart';

class ProfileRepository {
  Future<UserProfileDto> fetchMyProfile() => client.profile.getMyProfile();
}
