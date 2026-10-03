import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../model/username_rules.dart';
import '../viewmodel/edit_profile_viewmodel.dart';
import '../viewmodel/profile_provider.dart';
import 'profile_avatar.dart';
import '../../../core/l10n/l10n.dart';

/// "Modifier" du compte (Réglages) — pseudo seulement pour l'instant. Le
/// badge caméra est réservé à la photo de profil (US2.1 : `image_picker` +
/// permissions), désactivé en attendant.
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileViewModelProvider);
    final profile = ref.watch(myProfileProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
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
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Tooltip(
                          message: context.l10n.photoSoon,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.card,
                            child: Icon(
                              Icons.photo_camera,
                              size: 16,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  context.l10n.usernameLabel,
                  style: TextStyle(
                    color: Colors.white60,
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
                  style: const TextStyle(color: Colors.white),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.fieldFill,
                    counterStyle: const TextStyle(color: Colors.white38),
                    errorText: state.errorMessage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: state.isSubmitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
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
