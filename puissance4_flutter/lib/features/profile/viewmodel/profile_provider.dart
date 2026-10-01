import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../client.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../offline/viewmodel/local_cache_provider.dart';
import '../model/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(localCacheProvider)),
);

/// Le profil du User authentifié — `null` tant qu'on n'a pas de session
/// serveur réelle (`AuthStatus.localGuest` n'a pas d'`authUserId` du tout,
/// donc pas d'appel tenté). Émet d'abord le profil en cache puis celui du
/// serveur ; se recalcule à chaque transition d'auth et sur chaque
/// événement temps réel `profileChanged` (voir `liveUpdatesProvider`).
final myProfileProvider = StreamProvider<UserProfileDto?>((ref) {
  final status = ref.watch(authViewModelProvider).status;
  final authUserId = client.auth.authInfo?.authUserId;
  if (status != AuthStatus.serverAuthenticated || authUserId == null) {
    return Stream.value(null);
  }
  return ref.read(profileRepositoryProvider).watchMyProfile(authUserId);
});
