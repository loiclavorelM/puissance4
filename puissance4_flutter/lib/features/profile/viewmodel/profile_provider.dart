import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../auth/viewmodel/auth_viewmodel.dart';
import '../model/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(),
);

/// Le profil du User authentifié — `null` tant qu'on n'a pas de session
/// serveur réelle (`AuthStatus.localGuest` n'a pas d'`authUserId` du tout,
/// donc pas d'appel tenté). Se recalcule automatiquement à chaque
/// transition d'auth.
final myProfileProvider = FutureProvider<UserProfileDto?>((ref) async {
  final status = ref.watch(authViewModelProvider).status;
  if (status != AuthStatus.serverAuthenticated) return null;
  return ref.read(profileRepositoryProvider).fetchMyProfile();
});
