import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../client.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/viewmodel/profile_provider.dart';
import 'auth_form_theme.dart';

/// "Créer un compte" for a guest signed in anonymously (US0.2), pushed from
/// the settings. The module's own sign-up form: the server attaches the new
/// email account to the guest's auth user (`EmailIdpEndpoint`), so the
/// player keeps their Elo, games and history.
class CreateAccountScreen extends ConsumerWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    void onAuthenticated() {
      // Même authUserId : rien ne change côté auth, seul `isGuest` bascule.
      ref.invalidate(myProfileProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountCreated)));
      Navigator.of(context).pop();
    }

    void onError(Object error) {
      // Le formulaire propose aussi « Déjà un compte ? » : se connecter à un
      // autre compte exige de se déconnecter de l'invité d'abord (serveur).
      final message = error is SignInWhileAuthenticatedException
          ? l10n.createAccountSignInBlocked
          : l10n.authError('$error');
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        title: Text(l10n.createAccount),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.createAccountIntro,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: AuthFormTheme(
                      child: EmailSignInWidget(
                        client: client,
                        startScreen: EmailFlowScreen.startRegistration,
                        onAuthenticated: onAuthenticated,
                        onError: onError,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
