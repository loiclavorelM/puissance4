import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../client.dart';
import '../../../core/theme/app_colors.dart';
import '../../offline/view/server_connection_indicator.dart';
import '../../offline/viewmodel/server_connection_provider.dart';
import '../viewmodel/auth_viewmodel.dart';

/// Login screen (maquette "Connexion") — pure View: no ViewModel, no model.
/// Wraps the native Serverpod [SignInWidget] (email + Google + Anonymous,
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
                      children: const [
                        TextSpan(text: 'PUISSANCE '),
                        TextSpan(
                          text: '4',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Défie l'IA. Grimpe le classement.",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
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
                  const Text(
                    'Propulsé par Serverpod',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
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

/// Applies the maquette's dark/coral palette to the native auth widget
/// (input fields, buttons, links all read from the ambient [Theme] /
/// [ColorScheme]) and translates its texts to French.
class _ThemedSignIn extends ConsumerWidget {
  const _ThemedSignIn({this.onAuthenticated});

  final VoidCallback? onAuthenticated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final isGuestLoading = authState.status == AuthStatus.loading;
    // Email/mot de passe et Google ont besoin du serveur — inutile de les
    // laisser actifs hors-ligne, ça échouerait de toute façon. "Continuer
    // sans compte" reste actif : il a son propre repli local hors-ligne.
    final hasNetwork = ref.watch(serverConnectionTrackerProvider).hasNetwork;

    final baseTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.card,
        onSurface: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fieldFill,
        labelStyle: const TextStyle(
          color: Colors.white60,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
        hintStyle: const TextStyle(color: Colors.white38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
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
    );

    // Le package d'auth (SignInWidget) code en dur certaines Rows, comme
    // "Pas de compte ? S'inscrire", sans possibilité d'y injecter un Wrap
    // depuis l'extérieur — mais leur taille de police suit bien le
    // `bodyMedium` ambiant. On la rend dépendante de la largeur d'écran
    // pour rester lisible sans déborder sur les téléphones étroits.
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bodyFontSize = screenWidth < 360 ? 12.0 : 14.0;

    return Theme(
      data: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.copyWith(
          bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
            fontSize: bodyFontSize,
          ),
        ),
      ),
      child: SignInLocalizationProvider(
        basic: const BasicSignInTexts(
          noAuthenticationProvidersConfigured:
              "Aucun moyen de connexion n'est configuré sur le serveur.",
          orContinueWith: 'ou',
        ),
        email: EmailSignInTexts.defaults.copyWith(
          title: 'Connexion',
          emailLabel: 'ADRESSE E-MAIL',
          passwordLabel: 'MOT DE PASSE',
          signIn: 'Se connecter',
          forgotPassword: 'Mot de passe oublié ?',
          dontHaveAnAccount: 'Pas de compte ? ',
          signUp: "S'inscrire",
          signUpTitle: 'Créer un compte',
          continueAction: 'Continuer',
          alreadyHaveAnAccount: 'Déjà un compte ? ',
          verifyAccountTitle: 'Vérifier le compte',
          verifyResetCodeTitle: 'Vérifier le code',
          verificationMessage:
              'Un e-mail de vérification a été envoyé. Vérifie ta boîte de '
              'réception et saisis le code ci-dessous.',
          verify: 'Vérifier',
          setAccountPasswordTitle: 'Choisir un mot de passe',
          backToSignUp: "Retour à l'inscription",
          setNewPasswordTitle: 'Nouveau mot de passe',
          newPasswordLabel: 'NOUVEAU MOT DE PASSE',
          resetPasswordTitle: 'Réinitialiser le mot de passe',
          resetPasswordDescription:
              'Saisis ton adresse e-mail pour réinitialiser ton mot de '
              'passe.',
          requestPasswordReset: 'Envoyer',
          resetPassword: 'Réinitialiser',
          backToSignIn: 'Retour à la connexion',
          termsIntro: "J'ai lu et j'accepte les ",
          termsAndConditions: "conditions d'utilisation",
          andText: ' et la ',
          privacyPolicy: 'politique de confidentialité',
        ),
        anonymous: const AnonymousSignInTexts(
          signInButton: 'Continuer sans compte',
        ),
        google: const GoogleSignInTexts(signInButton: 'Continuer avec Google'),
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
                      SnackBar(content: Text('Erreur de connexion : $error')),
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
                        SnackBar(content: Text('Erreur de connexion : $error')),
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
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Pas de connexion internet : indisponible hors-ligne.',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
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
      ),
    );
  }
}
