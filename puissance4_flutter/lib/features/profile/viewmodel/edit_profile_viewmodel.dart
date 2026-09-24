import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import 'profile_provider.dart';

class EditProfileState {
  const EditProfileState({this.isSubmitting = false, this.errorMessage});

  final bool isSubmitting;

  /// Erreur du dernier envoi (refus serveur ou réseau), `null` sinon.
  final String? errorMessage;
}

final editProfileViewModelProvider =
    NotifierProvider.autoDispose<EditProfileViewModel, EditProfileState>(
      EditProfileViewModel.new,
    );

/// Modification du profil depuis Réglages — pseudo uniquement pour l'instant ;
/// le changement de photo (US2.1) viendra s'ajouter ici.
class EditProfileViewModel extends AutoDisposeNotifier<EditProfileState> {
  @override
  EditProfileState build() => const EditProfileState();

  /// Renvoie `true` si le pseudo a été enregistré.
  Future<bool> submitUsername(String username) async {
    state = const EditProfileState(isSubmitting: true);
    try {
      await ref.read(profileRepositoryProvider).updateUsername(username.trim());
    } on ProfileUpdateException catch (e) {
      state = EditProfileState(errorMessage: _messageFor(e.reason));
      return false;
    } catch (_) {
      state = const EditProfileState(
        errorMessage: 'Impossible de joindre le serveur. Réessaie plus tard.',
      );
      return false;
    }
    // Jouer et Réglages lisent le pseudo depuis `myProfileProvider` ; le
    // Classement se recharge déjà à chaque ouverture de l'onglet.
    ref.invalidate(myProfileProvider);
    state = const EditProfileState();
    return true;
  }

  static String _messageFor(EnumProfileUpdateError reason) => switch (reason) {
    EnumProfileUpdateError.invalidUsername => 'Ce pseudo n\'est pas valide.',
    EnumProfileUpdateError.usernameTaken => 'Ce pseudo est déjà pris.',
  };
}
