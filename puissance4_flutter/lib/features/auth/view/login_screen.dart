import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../client.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../offline/view/server_connection_indicator.dart';
import '../../offline/viewmodel/server_connection_provider.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'auth_form_theme.dart';

/// Login screen (maquette "Connexion") — pure View: no ViewModel, no model.
/// Wraps the native Serverpod [SignInWidget] (email + Anonymous,
/// auto-detected from what the server has configured) with the app's visual
/// identity. Auth logic itself lives entirely in the module.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.onAuthenticated});

  /// Called once the user is signed in (by any provider).
  final VoidCallback? onAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [ServerConnectionIndicator()],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Logo(),
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                      children: [
                        TextSpan(text: context.l10n.loginWordmark),
                        const TextSpan(
                          text: '4',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.loginTagline,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: _ThemedSignIn(onAuthenticated: onAuthenticated),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    context.l10n.poweredByServerpod,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
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

/// Two overlapping circles, matching the maquette's logo mark.
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 64,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: _dot(AppColors.yellow, 52),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _dot(AppColors.primary, 52),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// The native [SignInWidget] in the app's look ([AuthFormTheme]), plus the
/// "Continuer sans compte" button with its offline fallback.
class _ThemedSignIn extends ConsumerWidget {
  const _ThemedSignIn({this.onAuthenticated});

  final VoidCallback? onAuthenticated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final isGuestLoading = authState.status == AuthStatus.loading;
    // Email/mot de passe a besoin du serveur — inutile de le laisser actif
    // hors-ligne, ça échouerait de toute façon. "Continuer sans compte"
    // reste actif : il a son propre repli local hors-ligne.
    final hasNetwork = ref.watch(serverConnectionTrackerProvider).hasNetwork;

    final l10n = context.l10n;
    return AuthFormTheme(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IgnorePointer(
            ignoring: !hasNetwork,
            child: AnimatedOpacity(
              opacity: hasNetwork ? 1 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: SignInWidget(
                client: client,
                onAuthenticated: onAuthenticated,
                onError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.authError('$error'))),
                  );
                },
                // The package defaults the email flow to the sign-up
                // screen (email only, no password) — this screen is
                // "Connexion", so it must start on the login form (email +
                // password) instead.
                emailSignInWidget: EmailSignInWidget(
                  client: client,
                  startScreen: EmailFlowScreen.login,
                  onAuthenticated: onAuthenticated,
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.authError('$error'))),
                    );
                  },
                ),
                // The built-in anonymous button always surfaces a server
                // error — replaced below by one that falls back to a
                // local guest profile when the server is unreachable.
                disableAnonymousSignInWidget: true,
                // Shared look for every provider button (pill, coral) —
                // matches the maquette's single-accent-color aesthetic.
                buttonStyle: const SignInButtonStyle(
                  shape: SignInButtonShape.pill,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
          if (!hasNetwork)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.authOfflineUnavailable,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 12),
          AnonymousSignInButton(
            onPressed: isGuestLoading
                ? null
                : () => ref
                      .read(authViewModelProvider.notifier)
                      .continueAsGuest(),
            isLoading: isGuestLoading,
            isDisabled: isGuestLoading,
          ),
        ],
      ),
    );
  }
}
