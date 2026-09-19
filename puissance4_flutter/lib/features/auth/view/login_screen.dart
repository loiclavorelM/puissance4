import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../client.dart';

/// Login screen (maquette "Connexion") — pure View: no ViewModel, no model.
/// Wraps the native Serverpod [SignInWidget] (email + Google + Anonymous,
/// auto-detected from what the server has configured) with the app's visual
/// identity. Auth logic itself lives entirely in the module.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.onAuthenticated});

  /// Called once the user is signed in (by any provider).
  final VoidCallback? onAuthenticated;

  static const _background = Color(0xFF0D0E1F);
  static const _card = Color(0xFF171A38);
  static const _fieldFill = Color(0xFF1E2247);
  static const _primary = Color(0xFFE8543F);
  static const _yellow = Color(0xFFF4B740);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
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
                          style: TextStyle(color: _primary),
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
                      color: _card,
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
            child: _dot(LoginScreen._yellow, 52),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _dot(LoginScreen._primary, 52),
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
class _ThemedSignIn extends StatelessWidget {
  const _ThemedSignIn({this.onAuthenticated});

  final VoidCallback? onAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: LoginScreen._primary,
          onPrimary: Colors.white,
          surface: LoginScreen._card,
          onSurface: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: LoginScreen._fieldFill,
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
              color: LoginScreen._primary,
              width: 1.5,
            ),
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
          dontHaveAnAccount: 'Pas encore de compte ? ',
          signUp: 'Créer un compte',
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
        child: SignInWidget(
          client: client,
          onAuthenticated: onAuthenticated,
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur de connexion : $error')),
            );
          },
          // The package defaults the email flow to the sign-up screen
          // (email only, no password) — this screen is "Connexion", so it
          // must start on the login form (email + password) instead.
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
          // Shared look for every provider button (pill, coral) — matches
          // the maquette's single-accent-color aesthetic.
          buttonStyle: const SignInButtonStyle(
            shape: SignInButtonShape.pill,
            backgroundColor: LoginScreen._primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
