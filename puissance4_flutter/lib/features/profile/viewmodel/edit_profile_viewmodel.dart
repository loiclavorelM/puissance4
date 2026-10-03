import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puissance4_client/puissance4_client.dart';

import '../../settings/viewmodel/locale_provider.dart';
import '../model/profile_photo.dart';
import 'profile_provider.dart';

class EditProfileState {
  const EditProfileState({
    this.isSubmitting = false,
    this.errorMessage,
    this.isUpdatingPhoto = false,
    this.photoError,
  });

  final bool isSubmitting;

  /// Erreur du dernier envoi du pseudo (refus serveur ou réseau), `null`
  /// sinon.
  final String? errorMessage;

  /// Photo en cours de préparation ou d'envoi.
  final bool isUpdatingPhoto;

  /// Erreur du dernier changement de photo, `null` sinon.
  final String? photoError;
}

final photoPickerProvider = Provider<PhotoPicker>((ref) => DevicePhotoPicker());

final editProfileViewModelProvider =
    NotifierProvider.autoDispose<EditProfileViewModel, EditProfileState>(
      EditProfileViewModel.new,
    );

/// Modification du profil depuis Réglages : pseudo et photo (E2, US2.1).
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
      state = EditProfileState(
        errorMessage: ref.read(l10nProvider).serverUnreachableLater,
      );
      return false;
    }
    // Jouer et Réglages lisent le pseudo depuis `myProfileProvider` ;
    // invalidé ici sans attendre l'événement temps réel `profileChanged`
    // (qui recharge aussi le Classement), au cas où le stream serait coupé.
    ref.invalidate(myProfileProvider);
    state = const EditProfileState();
    return true;
  }

  /// Prend ou choisit une photo, la réduit en miniature carrée et l'envoie.
  /// Renvoie `true` si la photo a changé (`false` : annulé ou refusé).
  Future<bool> changePhoto(PhotoSource source) async {
    if (state.isUpdatingPhoto) return false;
    final Uint8List? photo;
    try {
      photo = await ref.read(photoPickerProvider).pick(source);
    } on FormatException {
      state = EditProfileState(photoError: ref.read(l10nProvider).photoInvalid);
      return false;
    } catch (_) {
      // Caméra indisponible, autorisation refusée…
      state = EditProfileState(
        photoError: ref.read(l10nProvider).photoPickFailed,
      );
      return false;
    }
    if (photo == null) return false;
    return _updatePhoto(
      () => ref.read(profileRepositoryProvider).uploadPhoto(photo!),
    );
  }

  /// Retire la photo (retour aux initiales).
  Future<bool> removePhoto() => _updatePhoto(
    () => ref.read(profileRepositoryProvider).removePhoto(),
  );

  Future<bool> _updatePhoto(Future<UserProfileDto> Function() send) async {
    state = const EditProfileState(isUpdatingPhoto: true);
    try {
      await send();
    } on ProfileUpdateException catch (e) {
      state = EditProfileState(photoError: _messageFor(e.reason));
      return false;
    } catch (_) {
      state = EditProfileState(
        photoError: ref.read(l10nProvider).serverUnreachableLater,
      );
      return false;
    }
    ref.invalidate(myProfileProvider);
    state = const EditProfileState();
    return true;
  }

  String _messageFor(EnumProfileUpdateError reason) {
    final l10n = ref.read(l10nProvider);
    return switch (reason) {
      EnumProfileUpdateError.invalidUsername => l10n.usernameInvalid,
      EnumProfileUpdateError.usernameTaken => l10n.usernameTaken,
      EnumProfileUpdateError.photoTooLarge => l10n.photoTooLarge,
      EnumProfileUpdateError.invalidPhoto => l10n.photoInvalid,
    };
  }
}
