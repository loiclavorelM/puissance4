import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_palette.dart';
import '../model/profile_photo.dart';
import '../model/username_rules.dart';
import '../viewmodel/edit_profile_viewmodel.dart';
import '../viewmodel/profile_provider.dart';
import 'profile_avatar.dart';

/// "Modifier" du compte (Réglages) : pseudo et photo de profil (E2,
/// US2.1). Le badge caméra ouvre le choix de la photo : appareil photo (sur
/// téléphone), galerie, ou suppression.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(myProfileProvider).valueOrNull;
    _usernameController = TextEditingController(text: profile?.username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final saved = await ref
        .read(editProfileViewModelProvider.notifier)
        .submitUsername(_usernameController.text);
    if (!saved || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.usernameUpdated)));
    Navigator.of(context).pop();
  }

  Future<void> _choosePhoto({required bool hasPhoto}) async {
    final l10n = context.l10n;
    final viewModel = ref.read(editProfileViewModelProvider.notifier);
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      backgroundColor: context.colors.card,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sur le web, pas d'appareil photo fiable : galerie seulement.
            if (!kIsWeb)
              _PhotoActionTile(
                icon: Icons.photo_camera,
                label: l10n.photoTake,
                action: _PhotoAction.camera,
              ),
            _PhotoActionTile(
              icon: Icons.photo_library,
              label: l10n.photoChoose,
              action: _PhotoAction.gallery,
            ),
            if (hasPhoto)
              _PhotoActionTile(
                icon: Icons.delete_outline,
                label: l10n.photoRemove,
                action: _PhotoAction.remove,
              ),
          ],
        ),
      ),
    );
    if (action == null) return;
    final changed = switch (action) {
      _PhotoAction.camera => await viewModel.changePhoto(PhotoSource.camera),
      _PhotoAction.gallery => await viewModel.changePhoto(PhotoSource.gallery),
      _PhotoAction.remove => await viewModel.removePhoto(),
    };
    if (!changed || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          action == _PhotoAction.remove ? l10n.photoRemoved : l10n.photoUpdated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileViewModelProvider);
    final profile = ref.watch(myProfileProvider).valueOrNull;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.text,
        title: Text(context.l10n.editProfileTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: _usernameController,
                        builder: (context, value, _) => ProfileAvatar(
                          username: value.text,
                          thumbnailUrl: profile?.thumbnailUrl,
                          radius: 44,
                        ),
                      ),
                      if (state.isUpdatingPhoto)
                        Positioned.fill(
                          child: CircularProgressIndicator(
                            color: context.colors.primary,
                          ),
                        ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton.filled(
                          // Sans session serveur (invité hors-ligne), pas
                          // d'envoi possible.
                          tooltip: profile == null
                              ? context.l10n.photoNeedsServer
                              : context.l10n.photoChange,
                          onPressed: profile == null || state.isUpdatingPhoto
                              ? null
                              : () => _choosePhoto(
                                  hasPhoto: profile.thumbnailUrl != null,
                                ),
                          style: IconButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            disabledBackgroundColor: context.colors.card,
                            minimumSize: const Size.square(34),
                            padding: EdgeInsets.zero,
                          ),
                          iconSize: 18,
                          icon: Icon(
                            Icons.photo_camera,
                            color: context.colors.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.photoError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.photoError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.colors.yellow),
                  ),
                ],
                const SizedBox(height: 32),
                Text(
                  context.l10n.usernameLabel,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  enabled: !state.isSubmitting,
                  maxLength: usernameMaxLength,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) => switch (checkUsername(value ?? '')) {
                    null => null,
                    UsernameProblem.tooShort => context.l10n.usernameTooShort(
                      usernameMinLength,
                    ),
                    UsernameProblem.tooLong => context.l10n.usernameTooLong(
                      usernameMaxLength,
                    ),
                    UsernameProblem.invalidCharacters =>
                      context.l10n.usernameInvalidChars,
                  },
                  style: TextStyle(color: context.colors.text),
                  cursorColor: context.colors.primary,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.colors.fieldFill,
                    counterStyle: TextStyle(color: context.colors.textFaint),
                    errorText: state.errorMessage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: context.colors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: state.isSubmitting
                      ? SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.text,
                          ),
                        )
                      : Text(
                          context.l10n.save,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _PhotoAction { camera, gallery, remove }

class _PhotoActionTile extends StatelessWidget {
  const _PhotoActionTile({
    required this.icon,
    required this.label,
    required this.action,
  });

  final IconData icon;
  final String label;
  final _PhotoAction action;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: context.colors.text),
    title: Text(label, style: TextStyle(color: context.colors.text)),
    onTap: () => Navigator.of(context).pop(action),
  );
}
