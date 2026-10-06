import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_palette.dart';

/// Applies the app's palette (light or dark) to the native auth widgets
/// (input fields, buttons, links all read from the ambient [Theme] /
/// [ColorScheme]) and translates their texts. Shared by the login screen and
/// the guest's "create an account" screen.
class AuthFormTheme extends StatelessWidget {
  const AuthFormTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Thème de l'app (clair ou sombre, couleurs déjà réglées) ; seuls les
    // champs de saisie ont un style propre à la maquette.
    final baseTheme = Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.fieldFill,
        labelStyle: TextStyle(
          color: colors.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
        hintStyle: TextStyle(color: colors.textFaint),
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
          borderSide: BorderSide(
            color: colors.primary,
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
    final l10n = context.l10n;
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
        basic: BasicSignInTexts(
          noAuthenticationProvidersConfigured: l10n.authNoProviders,
          orContinueWith: l10n.authOr,
        ),
        email: EmailSignInTexts.defaults.copyWith(
          title: l10n.authTitle,
          emailLabel: l10n.authEmailLabel,
          passwordLabel: l10n.authPasswordLabel,
          signIn: l10n.authSignIn,
          forgotPassword: l10n.authForgotPassword,
          dontHaveAnAccount: l10n.authNoAccount,
          signUp: l10n.authSignUp,
          signUpTitle: l10n.authSignUpTitle,
          continueAction: l10n.authContinue,
          alreadyHaveAnAccount: l10n.authHaveAccount,
          verifyAccountTitle: l10n.authVerifyAccountTitle,
          verifyResetCodeTitle: l10n.authVerifyCodeTitle,
          verificationMessage: l10n.authVerificationMessage,
          verify: l10n.authVerify,
          setAccountPasswordTitle: l10n.authSetPasswordTitle,
          backToSignUp: l10n.authBackToSignUp,
          setNewPasswordTitle: l10n.authNewPasswordTitle,
          newPasswordLabel: l10n.authNewPasswordLabel,
          resetPasswordTitle: l10n.authResetPasswordTitle,
          resetPasswordDescription: l10n.authResetPasswordDescription,
          requestPasswordReset: l10n.authRequestReset,
          resetPassword: l10n.authResetPassword,
          backToSignIn: l10n.authBackToSignIn,
          termsIntro: l10n.authTermsIntro,
          termsAndConditions: l10n.authTerms,
          andText: l10n.authAnd,
          privacyPolicy: l10n.authPrivacyPolicy,
        ),
        anonymous: AnonymousSignInTexts(
          signInButton: l10n.authContinueAsGuest,
        ),
        child: child,
      ),
    );
  }
}
