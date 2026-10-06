import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @abandon.
  ///
  /// In fr, this message translates to:
  /// **'Abandonner'**
  String get abandon;

  /// No description provided for @abandonMessage.
  ///
  /// In fr, this message translates to:
  /// **'Quitter compte comme une défaite (ou une partie annulée si tu n\'as joué aucun coup).'**
  String get abandonMessage;

  /// No description provided for @abandonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Abandonner la partie ?'**
  String get abandonTitle;

  /// No description provided for @aboutLine.
  ///
  /// In fr, this message translates to:
  /// **'Puissance 4 RL · v0.1 · Serverpod'**
  String get aboutLine;

  /// No description provided for @accountCreated.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé : ta progression est conservée.'**
  String get accountCreated;

  /// No description provided for @accountSection.
  ///
  /// In fr, this message translates to:
  /// **'COMPTE'**
  String get accountSection;

  /// No description provided for @actionImpossible.
  ///
  /// In fr, this message translates to:
  /// **'Action impossible.'**
  String get actionImpossible;

  /// No description provided for @activityDraw.
  ///
  /// In fr, this message translates to:
  /// **'{friend} a fait match nul en {mode} contre {opponent}'**
  String activityDraw(String friend, String mode, String opponent);

  /// No description provided for @activityEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Pas de partie chez tes amis cette semaine.'**
  String get activityEmpty;

  /// No description provided for @activityLost.
  ///
  /// In fr, this message translates to:
  /// **'{friend} a perdu en {mode} contre {opponent}'**
  String activityLost(String friend, String mode, String opponent);

  /// No description provided for @activityWon.
  ///
  /// In fr, this message translates to:
  /// **'{friend} a gagné en {mode} contre {opponent}'**
  String activityWon(String friend, String mode, String opponent);

  /// No description provided for @activityYou.
  ///
  /// In fr, this message translates to:
  /// **'toi'**
  String get activityYou;

  /// No description provided for @alreadyInGame.
  ///
  /// In fr, this message translates to:
  /// **'Tu as déjà une partie en cours.'**
  String get alreadyInGame;

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Puissance 4'**
  String get appTitle;

  /// No description provided for @authAnd.
  ///
  /// In fr, this message translates to:
  /// **' et la '**
  String get authAnd;

  /// No description provided for @authBackToSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get authBackToSignIn;

  /// No description provided for @authBackToSignUp.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'inscription'**
  String get authBackToSignUp;

  /// No description provided for @authContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get authContinue;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In fr, this message translates to:
  /// **'Continuer sans compte'**
  String get authContinueAsGuest;

  /// No description provided for @authEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'ADRESSE E-MAIL'**
  String get authEmailLabel;

  /// No description provided for @authError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion : {error}'**
  String authError(String error);

  /// No description provided for @authForgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get authForgotPassword;

  /// No description provided for @authHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ? '**
  String get authHaveAccount;

  /// No description provided for @authNewPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'NOUVEAU MOT DE PASSE'**
  String get authNewPasswordLabel;

  /// No description provided for @authNewPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get authNewPasswordTitle;

  /// No description provided for @authNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas de compte ? '**
  String get authNoAccount;

  /// No description provided for @authNoProviders.
  ///
  /// In fr, this message translates to:
  /// **'Aucun moyen de connexion n\'est configuré sur le serveur.'**
  String get authNoProviders;

  /// No description provided for @authOfflineUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet : indisponible hors-ligne.'**
  String get authOfflineUnavailable;

  /// No description provided for @authOr.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get authOr;

  /// No description provided for @authPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'MOT DE PASSE'**
  String get authPasswordLabel;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'politique de confidentialité'**
  String get authPrivacyPolicy;

  /// No description provided for @authRequestReset.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get authRequestReset;

  /// No description provided for @authResetPassword.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get authResetPassword;

  /// No description provided for @authResetPasswordDescription.
  ///
  /// In fr, this message translates to:
  /// **'Saisis ton adresse e-mail pour réinitialiser ton mot de passe.'**
  String get authResetPasswordDescription;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get authResetPasswordTitle;

  /// No description provided for @authSetPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un mot de passe'**
  String get authSetPasswordTitle;

  /// No description provided for @authSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get authSignUp;

  /// No description provided for @authSignUpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get authSignUpTitle;

  /// No description provided for @authTerms.
  ///
  /// In fr, this message translates to:
  /// **'conditions d\'utilisation'**
  String get authTerms;

  /// No description provided for @authTermsIntro.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai lu et j\'accepte les '**
  String get authTermsIntro;

  /// No description provided for @authTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get authTitle;

  /// No description provided for @authVerificationMessage.
  ///
  /// In fr, this message translates to:
  /// **'Un e-mail de vérification a été envoyé. Vérifie ta boîte de réception et saisis le code ci-dessous.'**
  String get authVerificationMessage;

  /// No description provided for @authVerify.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get authVerify;

  /// No description provided for @authVerifyAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier le compte'**
  String get authVerifyAccountTitle;

  /// No description provided for @authVerifyCodeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier le code'**
  String get authVerifyCodeTitle;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @bestMove.
  ///
  /// In fr, this message translates to:
  /// **'Meilleur coup selon l\'Expert'**
  String get bestMove;

  /// No description provided for @botBeginner.
  ///
  /// In fr, this message translates to:
  /// **'Débutant'**
  String get botBeginner;

  /// No description provided for @botBeginnerDescription.
  ///
  /// In fr, this message translates to:
  /// **'Un bot qui débute au Puissance 4.'**
  String get botBeginnerDescription;

  /// No description provided for @botDisplayName.
  ///
  /// In fr, this message translates to:
  /// **'Bot {name}'**
  String botDisplayName(String name);

  /// No description provided for @botExpert.
  ///
  /// In fr, this message translates to:
  /// **'Expert'**
  String get botExpert;

  /// No description provided for @botExpertDescription.
  ///
  /// In fr, this message translates to:
  /// **'Le bot le plus fort, entraîné par apprentissage par renforcement.'**
  String get botExpertDescription;

  /// No description provided for @botMedium.
  ///
  /// In fr, this message translates to:
  /// **'Medium'**
  String get botMedium;

  /// No description provided for @botMediumDescription.
  ///
  /// In fr, this message translates to:
  /// **'Un bot de niveau intermédiaire.'**
  String get botMediumDescription;

  /// No description provided for @botThinking.
  ///
  /// In fr, this message translates to:
  /// **'{name} réfléchit…'**
  String botThinking(String name);

  /// No description provided for @botsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les bots.'**
  String get botsLoadError;

  /// No description provided for @cameraUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Caméra indisponible : vérifie l\'autorisation d\'accès.'**
  String get cameraUnavailable;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @challengeDeclined.
  ///
  /// In fr, this message translates to:
  /// **'{name} a refusé ton défi.'**
  String challengeDeclined(String name);

  /// No description provided for @challengeExpired.
  ///
  /// In fr, this message translates to:
  /// **'{name} n\'a pas répondu à ton défi.'**
  String challengeExpired(String name);

  /// No description provided for @challengeGone.
  ///
  /// In fr, this message translates to:
  /// **'Ce défi n\'existe plus.'**
  String get challengeGone;

  /// No description provided for @challengeReceived.
  ///
  /// In fr, this message translates to:
  /// **'{name} te défie !'**
  String challengeReceived(String name);

  /// No description provided for @challengeWaiting.
  ///
  /// In fr, this message translates to:
  /// **'En attente de {name}…'**
  String challengeWaiting(String name);

  /// No description provided for @chooseMode.
  ///
  /// In fr, this message translates to:
  /// **'CHOISIS TON MODE'**
  String get chooseMode;

  /// No description provided for @chooseOpponent.
  ///
  /// In fr, this message translates to:
  /// **'CHOISIS TON ADVERSAIRE'**
  String get chooseOpponent;

  /// No description provided for @codeCopied.
  ///
  /// In fr, this message translates to:
  /// **'Code copié'**
  String get codeCopied;

  /// No description provided for @codeHint.
  ///
  /// In fr, this message translates to:
  /// **'CODE'**
  String get codeHint;

  /// No description provided for @codeLength.
  ///
  /// In fr, this message translates to:
  /// **'Le code fait 6 caractères.'**
  String get codeLength;

  /// No description provided for @comingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get comingSoon;

  /// No description provided for @continueAction.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueAction;

  /// No description provided for @copy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get copy;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// No description provided for @createAccountIntro.
  ///
  /// In fr, this message translates to:
  /// **'Ton Elo, tes parties et ton historique restent sur ce compte. Tu pourras ensuite te connecter par email sur n\'importe quel appareil.'**
  String get createAccountIntro;

  /// No description provided for @createAccountSignInBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Pour te connecter à un compte existant, déconnecte-toi d\'abord depuis les réglages — ta progression d\'invité ne sera pas conservée.'**
  String get createAccountSignInBlocked;

  /// No description provided for @createGameFailedRetry.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de créer la partie. Réessaie.'**
  String get createGameFailedRetry;

  /// No description provided for @createRoom.
  ///
  /// In fr, this message translates to:
  /// **'Créer et obtenir un code'**
  String get createRoom;

  /// No description provided for @createRoomSection.
  ///
  /// In fr, this message translates to:
  /// **'CRÉER UNE SALLE'**
  String get createRoomSection;

  /// No description provided for @darkTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème sombre'**
  String get darkTheme;

  /// No description provided for @dateToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui, {time}'**
  String dateToday(String time);

  /// No description provided for @dateYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier, {time}'**
  String dateYesterday(String time);

  /// No description provided for @defaultPlayerName.
  ///
  /// In fr, this message translates to:
  /// **'Joueur'**
  String get defaultPlayerName;

  /// No description provided for @disconnected.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecté'**
  String get disconnected;

  /// No description provided for @download.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get download;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @editNeedsServer.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au serveur requise pour modifier'**
  String get editNeedsServer;

  /// No description provided for @editProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get editProfileTitle;

  /// No description provided for @eloLabel.
  ///
  /// In fr, this message translates to:
  /// **'ELO {elo}'**
  String eloLabel(int elo);

  /// No description provided for @eloVariation.
  ///
  /// In fr, this message translates to:
  /// **' ({variation} Elo)'**
  String eloVariation(String variation);

  /// No description provided for @expertAnalysing.
  ///
  /// In fr, this message translates to:
  /// **'L\'Expert analyse ce coup…'**
  String get expertAnalysing;

  /// No description provided for @expertWouldPlay.
  ///
  /// In fr, this message translates to:
  /// **'L\'Expert jouait la colonne {column}'**
  String expertWouldPlay(int column);

  /// No description provided for @explainInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Ce coup ne peut pas être expliqué.'**
  String get explainInvalid;

  /// No description provided for @explainMove.
  ///
  /// In fr, this message translates to:
  /// **'Expliquer ce coup'**
  String get explainMove;

  /// No description provided for @explainNotConfigured.
  ///
  /// In fr, this message translates to:
  /// **'L\'explication par IA n\'est pas activée sur ce serveur.'**
  String get explainNotConfigured;

  /// No description provided for @explainRateLimited.
  ///
  /// In fr, this message translates to:
  /// **'Trop d\'explications demandées cette heure-ci. Réessaie plus tard.'**
  String get explainRateLimited;

  /// No description provided for @explainSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Connecte-toi pour obtenir une explication.'**
  String get explainSignIn;

  /// No description provided for @explainUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Le service d\'explication ne répond pas. Réessaie plus tard.'**
  String get explainUnavailable;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get filterAll;

  /// No description provided for @friendAccept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get friendAccept;

  /// No description provided for @friendAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes maintenant amis avec {name} !'**
  String friendAccepted(String name);

  /// No description provided for @friendAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get friendAdd;

  /// No description provided for @friendChallenge.
  ///
  /// In fr, this message translates to:
  /// **'Défier'**
  String get friendChallenge;

  /// No description provided for @friendCodeCopied.
  ///
  /// In fr, this message translates to:
  /// **'Code ami copié.'**
  String get friendCodeCopied;

  /// No description provided for @friendCodeCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier le code'**
  String get friendCodeCopy;

  /// No description provided for @friendCodeHint.
  ///
  /// In fr, this message translates to:
  /// **'Donne-le à un ami pour qu\'il t\'ajoute.'**
  String get friendCodeHint;

  /// No description provided for @friendDecline.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get friendDecline;

  /// No description provided for @friendQrHint.
  ///
  /// In fr, this message translates to:
  /// **'Fais-le scanner par ton ami depuis Amis › Ajouter.'**
  String get friendQrHint;

  /// No description provided for @friendRelationFriend.
  ///
  /// In fr, this message translates to:
  /// **'Ami'**
  String get friendRelationFriend;

  /// No description provided for @friendRelationSent.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée'**
  String get friendRelationSent;

  /// No description provided for @friendRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get friendRemove;

  /// No description provided for @friendRemoveMessage.
  ///
  /// In fr, this message translates to:
  /// **'Tu disparaîtras aussi de sa liste.'**
  String get friendRemoveMessage;

  /// No description provided for @friendRemoveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retirer {name} de tes amis ?'**
  String friendRemoveTitle(String name);

  /// No description provided for @friendRequestDaysAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {days} jours'**
  String friendRequestDaysAgo(int days);

  /// No description provided for @friendRequestSent.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée à {name}.'**
  String friendRequestSent(String name);

  /// No description provided for @friendRequestToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get friendRequestToday;

  /// No description provided for @friendRequestYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get friendRequestYesterday;

  /// No description provided for @friendRequestsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande en attente.'**
  String get friendRequestsEmpty;

  /// No description provided for @friendRequestsReceived.
  ///
  /// In fr, this message translates to:
  /// **'REÇUES'**
  String get friendRequestsReceived;

  /// No description provided for @friendRequestsSent.
  ///
  /// In fr, this message translates to:
  /// **'ENVOYÉES'**
  String get friendRequestsSent;

  /// No description provided for @friendScanHint.
  ///
  /// In fr, this message translates to:
  /// **'Vise le QR code de ton ami (Amis › Ajouter).'**
  String get friendScanHint;

  /// No description provided for @friendScanQr.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un QR'**
  String get friendScanQr;

  /// No description provided for @friendSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo ou code ami (P4-…)'**
  String get friendSearchHint;

  /// No description provided for @friendSearchNoResult.
  ///
  /// In fr, this message translates to:
  /// **'Aucun joueur trouvé.'**
  String get friendSearchNoResult;

  /// No description provided for @friendSearchTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Tape au moins 3 caractères, ou un code ami.'**
  String get friendSearchTooShort;

  /// No description provided for @friendShakeToAdd.
  ///
  /// In fr, this message translates to:
  /// **'Secouer'**
  String get friendShakeToAdd;

  /// No description provided for @friendShowQr.
  ///
  /// In fr, this message translates to:
  /// **'Afficher mon QR code'**
  String get friendShowQr;

  /// No description provided for @friendUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Cet ami n\'est plus disponible pour jouer.'**
  String get friendUnavailable;

  /// No description provided for @friendsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore d\'amis. Ajoute les joueurs que tu croises !'**
  String get friendsEmpty;

  /// No description provided for @friendsEmptyAction.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des amis'**
  String get friendsEmptyAction;

  /// No description provided for @friendsErrorAlreadyFriends.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes déjà amis.'**
  String get friendsErrorAlreadyFriends;

  /// No description provided for @friendsErrorAlreadySent.
  ///
  /// In fr, this message translates to:
  /// **'Demande déjà envoyée.'**
  String get friendsErrorAlreadySent;

  /// No description provided for @friendsErrorNotFriends.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'êtes plus amis.'**
  String get friendsErrorNotFriends;

  /// No description provided for @friendsErrorRequestNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Cette demande n\'existe plus.'**
  String get friendsErrorRequestNotFound;

  /// No description provided for @friendsErrorSelf.
  ///
  /// In fr, this message translates to:
  /// **'Tu ne peux pas t\'ajouter toi-même.'**
  String get friendsErrorSelf;

  /// No description provided for @friendsErrorTooMany.
  ///
  /// In fr, this message translates to:
  /// **'Limite de 200 amis atteinte.'**
  String get friendsErrorTooMany;

  /// No description provided for @friendsErrorUserNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Joueur introuvable.'**
  String get friendsErrorUserNotFound;

  /// No description provided for @friendsGuestMessage.
  ///
  /// In fr, this message translates to:
  /// **'Crée un compte pour ajouter des amis : tu gardes ta progression.'**
  String get friendsGuestMessage;

  /// No description provided for @friendsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger tes amis.'**
  String get friendsLoadError;

  /// No description provided for @friendsLocalGuestMessage.
  ///
  /// In fr, this message translates to:
  /// **'Connecte-toi au serveur pour ajouter des amis.'**
  String get friendsLocalGuestMessage;

  /// No description provided for @friendsSince.
  ///
  /// In fr, this message translates to:
  /// **'Amis depuis le {date}'**
  String friendsSince(String date);

  /// No description provided for @friendsTabAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get friendsTabAdd;

  /// No description provided for @friendsTabList.
  ///
  /// In fr, this message translates to:
  /// **'Mes amis'**
  String get friendsTabList;

  /// No description provided for @friendsTabRequests.
  ///
  /// In fr, this message translates to:
  /// **'Demandes'**
  String get friendsTabRequests;

  /// No description provided for @friendsTabRivalries.
  ///
  /// In fr, this message translates to:
  /// **'Rivalités'**
  String get friendsTabRivalries;

  /// No description provided for @gameCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Partie annulée'**
  String get gameCancelled;

  /// No description provided for @gameConnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion à la partie…'**
  String get gameConnecting;

  /// No description provided for @gameDraw.
  ///
  /// In fr, this message translates to:
  /// **'Match nul'**
  String get gameDraw;

  /// No description provided for @gameInProgressBanner.
  ///
  /// In fr, this message translates to:
  /// **'Tu as une partie en cours.'**
  String get gameInProgressBanner;

  /// No description provided for @gameInProgressTitle.
  ///
  /// In fr, this message translates to:
  /// **'Partie en cours'**
  String get gameInProgressTitle;

  /// No description provided for @gameLost.
  ///
  /// In fr, this message translates to:
  /// **'Défaite'**
  String get gameLost;

  /// No description provided for @gameLostByDisconnect.
  ///
  /// In fr, this message translates to:
  /// **'Défaite (déconnexion)'**
  String get gameLostByDisconnect;

  /// No description provided for @gameLostByForfeit.
  ///
  /// In fr, this message translates to:
  /// **'Défaite par abandon'**
  String get gameLostByForfeit;

  /// No description provided for @gameLostOnTime.
  ///
  /// In fr, this message translates to:
  /// **'Défaite au temps'**
  String get gameLostOnTime;

  /// No description provided for @gameReconnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion perdue — reconnexion…'**
  String get gameReconnecting;

  /// No description provided for @gameWon.
  ///
  /// In fr, this message translates to:
  /// **'Victoire !'**
  String get gameWon;

  /// No description provided for @gameWonByDisconnect.
  ///
  /// In fr, this message translates to:
  /// **'Victoire (déconnexion) !'**
  String get gameWonByDisconnect;

  /// No description provided for @gameWonByForfeit.
  ///
  /// In fr, this message translates to:
  /// **'Victoire par abandon !'**
  String get gameWonByForfeit;

  /// No description provided for @gameWonOnTime.
  ///
  /// In fr, this message translates to:
  /// **'Victoire au temps !'**
  String get gameWonOnTime;

  /// No description provided for @guestAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte invité'**
  String get guestAccount;

  /// No description provided for @guestAccountHint.
  ///
  /// In fr, this message translates to:
  /// **'Crée un compte pour ne pas perdre ta progression.'**
  String get guestAccountHint;

  /// No description provided for @guestSignOutMessage.
  ///
  /// In fr, this message translates to:
  /// **'Tu joues en invité : en te déconnectant, tu perdras ta progression (Elo, parties, historique) sans pouvoir la retrouver.'**
  String get guestSignOutMessage;

  /// No description provided for @guestSignOutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter ?'**
  String get guestSignOutTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune partie pour l\'instant.'**
  String get historyEmpty;

  /// No description provided for @historyLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger l\'historique.'**
  String get historyLoadError;

  /// No description provided for @historyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get historyTitle;

  /// No description provided for @join.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre'**
  String get join;

  /// No description provided for @joinFriendSection.
  ///
  /// In fr, this message translates to:
  /// **'REJOINDRE UN AMI'**
  String get joinFriendSection;

  /// No description provided for @labelWithElo.
  ///
  /// In fr, this message translates to:
  /// **'{label} · ELO {elo}'**
  String labelWithElo(String label, int elo);

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @layFlatHint.
  ///
  /// In fr, this message translates to:
  /// **'Pose le téléphone à plat pour jouer à deux'**
  String get layFlatHint;

  /// No description provided for @leaderboardAlone.
  ///
  /// In fr, this message translates to:
  /// **'Personne d\'autre pour l\'instant.'**
  String get leaderboardAlone;

  /// No description provided for @leaderboardFriends.
  ///
  /// In fr, this message translates to:
  /// **'Amis'**
  String get leaderboardFriends;

  /// No description provided for @leaderboardGlobal.
  ///
  /// In fr, this message translates to:
  /// **'Global'**
  String get leaderboardGlobal;

  /// No description provided for @leaderboardLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le classement.'**
  String get leaderboardLoadError;

  /// No description provided for @leaderboardNoFriends.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute des amis pour te comparer à eux.'**
  String get leaderboardNoFriends;

  /// No description provided for @leaderboardSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Connecte-toi pour voir le classement.'**
  String get leaderboardSignIn;

  /// No description provided for @lightThemeSoon.
  ///
  /// In fr, this message translates to:
  /// **'Le thème clair arrive bientôt — ton choix est déjà mémorisé.'**
  String get lightThemeSoon;

  /// No description provided for @loginTagline.
  ///
  /// In fr, this message translates to:
  /// **'Défie l\'IA. Grimpe le classement.'**
  String get loginTagline;

  /// No description provided for @loginWordmark.
  ///
  /// In fr, this message translates to:
  /// **'PUISSANCE '**
  String get loginWordmark;

  /// No description provided for @losingMove.
  ///
  /// In fr, this message translates to:
  /// **'Coup perdant — l\'Expert jouait la colonne {column}'**
  String losingMove(int column);

  /// No description provided for @modeFaceToFace.
  ///
  /// In fr, this message translates to:
  /// **'Face à face'**
  String get modeFaceToFace;

  /// No description provided for @modeFaceToFaceSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'À deux sur ce téléphone, posé sur la table'**
  String get modeFaceToFaceSubtitle;

  /// No description provided for @modeMulti.
  ///
  /// In fr, this message translates to:
  /// **'Multi'**
  String get modeMulti;

  /// No description provided for @modeMultiplayer.
  ///
  /// In fr, this message translates to:
  /// **'Multijoueur'**
  String get modeMultiplayer;

  /// No description provided for @modeMultiplayerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Défie un ami en 1v1'**
  String get modeMultiplayerSubtitle;

  /// No description provided for @modeNormal.
  ///
  /// In fr, this message translates to:
  /// **'Normal'**
  String get modeNormal;

  /// No description provided for @modeNormalSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisis la difficulté du bot'**
  String get modeNormalSubtitle;

  /// No description provided for @modeRanked.
  ///
  /// In fr, this message translates to:
  /// **'Classé'**
  String get modeRanked;

  /// No description provided for @modeRankedSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Affronte le bot du serveur, fais monter ton Elo'**
  String get modeRankedSubtitle;

  /// No description provided for @myFriendCode.
  ///
  /// In fr, this message translates to:
  /// **'MON CODE AMI'**
  String get myFriendCode;

  /// No description provided for @needsServer.
  ///
  /// In fr, this message translates to:
  /// **'Ce mode nécessite une connexion au serveur.'**
  String get needsServer;

  /// No description provided for @newGame.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle partie'**
  String get newGame;

  /// No description provided for @newGameFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de créer la partie.'**
  String get newGameFailed;

  /// No description provided for @newGameStarted.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle partie !'**
  String get newGameStarted;

  /// No description provided for @noOpenRooms.
  ///
  /// In fr, this message translates to:
  /// **'Aucune salle publique pour le moment. Crée la tienne !'**
  String get noOpenRooms;

  /// No description provided for @normalNeedsSession.
  ///
  /// In fr, this message translates to:
  /// **'Connecte-toi (même en invité, en ligne) pour jouer.'**
  String get normalNeedsSession;

  /// No description provided for @notImplemented.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore implémenté'**
  String get notImplemented;

  /// No description provided for @noticeColumnFull.
  ///
  /// In fr, this message translates to:
  /// **'Colonne pleine.'**
  String get noticeColumnFull;

  /// No description provided for @noticeConnectionLost.
  ///
  /// In fr, this message translates to:
  /// **'Connexion perdue — nouvelles tentatives en cours.'**
  String get noticeConnectionLost;

  /// No description provided for @noticeGameNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Partie introuvable.'**
  String get noticeGameNotFound;

  /// No description provided for @noticeGameOver.
  ///
  /// In fr, this message translates to:
  /// **'La partie est terminée.'**
  String get noticeGameOver;

  /// No description provided for @noticeMoveRefused.
  ///
  /// In fr, this message translates to:
  /// **'Coup refusé. Réessaie.'**
  String get noticeMoveRefused;

  /// No description provided for @noticeMoveUnconfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Connexion instable — coup en attente de confirmation.'**
  String get noticeMoveUnconfirmed;

  /// No description provided for @noticeNotYourTurn.
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est pas ton tour.'**
  String get noticeNotYourTurn;

  /// No description provided for @noticeSaveFailed.
  ///
  /// In fr, this message translates to:
  /// **'La partie n\'a pas pu être enregistrée sur l\'appareil.'**
  String get noticeSaveFailed;

  /// No description provided for @openRoomsSection.
  ///
  /// In fr, this message translates to:
  /// **'SALLES OUVERTES'**
  String get openRoomsSection;

  /// No description provided for @openRoomsUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Liste des salles indisponible.'**
  String get openRoomsUnavailable;

  /// No description provided for @opponent.
  ///
  /// In fr, this message translates to:
  /// **'Adversaire'**
  String get opponent;

  /// No description provided for @opponentDisconnected.
  ///
  /// In fr, this message translates to:
  /// **'Adversaire déconnecté — victoire s\'il ne revient pas.'**
  String get opponentDisconnected;

  /// No description provided for @opponentTurn.
  ///
  /// In fr, this message translates to:
  /// **'Tour de l\'adversaire'**
  String get opponentTurn;

  /// No description provided for @ownRoom.
  ///
  /// In fr, this message translates to:
  /// **'C\'est ta propre salle : partage le code à un ami.'**
  String get ownRoom;

  /// No description provided for @photoChange.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get photoChange;

  /// No description provided for @photoChoose.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la galerie'**
  String get photoChoose;

  /// No description provided for @photoInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n\'est pas une image lisible.'**
  String get photoInvalid;

  /// No description provided for @photoNeedsServer.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au serveur requise pour changer la photo'**
  String get photoNeedsServer;

  /// No description provided for @photoPickFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir la caméra ou la galerie.'**
  String get photoPickFailed;

  /// No description provided for @photoRemove.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la photo'**
  String get photoRemove;

  /// No description provided for @photoRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Photo de profil supprimée.'**
  String get photoRemoved;

  /// No description provided for @photoTake.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get photoTake;

  /// No description provided for @photoTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'Cette image est trop grande.'**
  String get photoTooLarge;

  /// No description provided for @photoUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Photo de profil mise à jour.'**
  String get photoUpdated;

  /// No description provided for @player1.
  ///
  /// In fr, this message translates to:
  /// **'Joueur 1'**
  String get player1;

  /// No description provided for @player2.
  ///
  /// In fr, this message translates to:
  /// **'Joueur 2'**
  String get player2;

  /// No description provided for @playerPlayedColumn.
  ///
  /// In fr, this message translates to:
  /// **'{name} a joué la colonne {column}'**
  String playerPlayedColumn(String name, int column);

  /// No description provided for @playerWins.
  ///
  /// In fr, this message translates to:
  /// **'{name} gagne !'**
  String playerWins(String name);

  /// No description provided for @poweredByServerpod.
  ///
  /// In fr, this message translates to:
  /// **'Propulsé par Serverpod'**
  String get poweredByServerpod;

  /// No description provided for @preferencesSection.
  ///
  /// In fr, this message translates to:
  /// **'PRÉFÉRENCES'**
  String get preferencesSection;

  /// No description provided for @presenceOnline.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get presenceOnline;

  /// No description provided for @presencePlaying.
  ///
  /// In fr, this message translates to:
  /// **'En partie · {mode}'**
  String presencePlaying(String mode);

  /// No description provided for @presenceSeenDays.
  ///
  /// In fr, this message translates to:
  /// **'Vu il y a {count} j'**
  String presenceSeenDays(int count);

  /// No description provided for @presenceSeenHours.
  ///
  /// In fr, this message translates to:
  /// **'Vu il y a {count} h'**
  String presenceSeenHours(int count);

  /// No description provided for @presenceSeenJustNow.
  ///
  /// In fr, this message translates to:
  /// **'Vu à l\'instant'**
  String get presenceSeenJustNow;

  /// No description provided for @presenceSeenMinutes.
  ///
  /// In fr, this message translates to:
  /// **'Vu il y a {count} min'**
  String presenceSeenMinutes(int count);

  /// No description provided for @publicRoom.
  ///
  /// In fr, this message translates to:
  /// **'Salle publique'**
  String get publicRoom;

  /// No description provided for @publicRoomOff.
  ///
  /// In fr, this message translates to:
  /// **'Seuls ceux qui ont le code peuvent rejoindre'**
  String get publicRoomOff;

  /// No description provided for @publicRoomOn.
  ///
  /// In fr, this message translates to:
  /// **'Visible par tous dans les salles ouvertes'**
  String get publicRoomOn;

  /// No description provided for @rankedOpponent.
  ///
  /// In fr, this message translates to:
  /// **'Adversaire : Bot {name} (ELO {elo})'**
  String rankedOpponent(String name, int elo);

  /// No description provided for @rankedOpponentByElo.
  ///
  /// In fr, this message translates to:
  /// **'Adversaire choisi selon ton Elo'**
  String get rankedOpponentByElo;

  /// No description provided for @rankedRules.
  ///
  /// In fr, this message translates to:
  /// **'Chaque coup est validé par le serveur. Victoire, défaite ou nul font varier ton Elo ; quitter la partie compte comme une défaite (sauf si tu n\'as joué aucun coup). 60 s par coup.'**
  String get rankedRules;

  /// No description provided for @recentOpponents.
  ///
  /// In fr, this message translates to:
  /// **'RENCONTRÉS RÉCEMMENT'**
  String get recentOpponents;

  /// No description provided for @recentOpponentsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Tes adversaires en Multi apparaîtront ici, pour les ajouter en un tap.'**
  String get recentOpponentsEmpty;

  /// No description provided for @replayFirst.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get replayFirst;

  /// No description provided for @replayLast.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get replayLast;

  /// No description provided for @replayMove.
  ///
  /// In fr, this message translates to:
  /// **'Coup {cursor} / {total}'**
  String replayMove(int cursor, int total);

  /// No description provided for @replayNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get replayNext;

  /// No description provided for @replayNoMoves.
  ///
  /// In fr, this message translates to:
  /// **'Les coups de cette partie n\'ont pas été enregistrés.'**
  String get replayNoMoves;

  /// No description provided for @replayPause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get replayPause;

  /// No description provided for @replayPlay.
  ///
  /// In fr, this message translates to:
  /// **'Lecture'**
  String get replayPlay;

  /// No description provided for @replayPrevious.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get replayPrevious;

  /// No description provided for @replayTitle.
  ///
  /// In fr, this message translates to:
  /// **'Revoir la partie'**
  String get replayTitle;

  /// No description provided for @replayUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Replay indisponible pour le moment (réseau ?).'**
  String get replayUnavailable;

  /// No description provided for @resultDraw.
  ///
  /// In fr, this message translates to:
  /// **'Match nul'**
  String get resultDraw;

  /// No description provided for @resultLoss.
  ///
  /// In fr, this message translates to:
  /// **'Défaite'**
  String get resultLoss;

  /// No description provided for @resultWin.
  ///
  /// In fr, this message translates to:
  /// **'Victoire'**
  String get resultWin;

  /// No description provided for @resume.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get resume;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @rivalriesActivity.
  ///
  /// In fr, this message translates to:
  /// **'ACTIVITÉ DE TES AMIS'**
  String get rivalriesActivity;

  /// No description provided for @rivalriesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute des amis pour suivre vos rivalités.'**
  String get rivalriesEmpty;

  /// No description provided for @rivalriesHeadToHead.
  ///
  /// In fr, this message translates to:
  /// **'TÊTE-À-TÊTE'**
  String get rivalriesHeadToHead;

  /// No description provided for @rivalryChallengeOffline.
  ///
  /// In fr, this message translates to:
  /// **'Défier (quand il sera en ligne)'**
  String get rivalryChallengeOffline;

  /// No description provided for @rivalryDraws.
  ///
  /// In fr, this message translates to:
  /// **'{count} nul(s)'**
  String rivalryDraws(int count);

  /// No description provided for @rivalryGames.
  ///
  /// In fr, this message translates to:
  /// **'VOS PARTIES'**
  String get rivalryGames;

  /// No description provided for @rivalryGamesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Défie-le pour commencer votre rivalité !'**
  String get rivalryGamesEmpty;

  /// No description provided for @rivalryNoGames.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore joué ensemble'**
  String get rivalryNoGames;

  /// No description provided for @rivalryRecord.
  ///
  /// In fr, this message translates to:
  /// **'{wins} V · {losses} D · {draws} N'**
  String rivalryRecord(int wins, int losses, int draws);

  /// No description provided for @roomClosedNobody.
  ///
  /// In fr, this message translates to:
  /// **'Salle fermée : personne ne l\'a rejointe à temps.'**
  String get roomClosedNobody;

  /// No description provided for @roomClosesIn.
  ///
  /// In fr, this message translates to:
  /// **'La salle se ferme dans {remaining}'**
  String roomClosesIn(String remaining);

  /// No description provided for @roomHostInfo.
  ///
  /// In fr, this message translates to:
  /// **'{elo} Elo · {remaining}'**
  String roomHostInfo(int elo, String remaining);

  /// No description provided for @roomNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Code inconnu ou salle déjà fermée.'**
  String get roomNotFound;

  /// No description provided for @roomTaken.
  ///
  /// In fr, this message translates to:
  /// **'Salle déjà prise ou fermée.'**
  String get roomTaken;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @secondsLeft.
  ///
  /// In fr, this message translates to:
  /// **'{seconds} s'**
  String secondsLeft(int seconds);

  /// No description provided for @serverConnectionLost.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au serveur perdue.'**
  String get serverConnectionLost;

  /// No description provided for @serverUnreachableLater.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le serveur. Réessaie plus tard.'**
  String get serverUnreachableLater;

  /// No description provided for @serverUnreachableRetry.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le serveur. Réessaie.'**
  String get serverUnreachableRetry;

  /// No description provided for @serversUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes connecté à internet, mais nos serveurs sont injoignables pour le moment.'**
  String get serversUnreachable;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settings;

  /// No description provided for @shakeToAddFound.
  ///
  /// In fr, this message translates to:
  /// **'Trouvé !'**
  String get shakeToAddFound;

  /// No description provided for @shakeToAddHint.
  ///
  /// In fr, this message translates to:
  /// **'Rien n\'est envoyé sans ton accord : tu choisis ensuite de l\'ajouter.'**
  String get shakeToAddHint;

  /// No description provided for @shakeToAddMatching.
  ///
  /// In fr, this message translates to:
  /// **'Recherche…'**
  String get shakeToAddMatching;

  /// No description provided for @shakeToAddNobody.
  ///
  /// In fr, this message translates to:
  /// **'Personne n\'a secoué en même temps'**
  String get shakeToAddNobody;

  /// No description provided for @shakeToAddWaiting.
  ///
  /// In fr, this message translates to:
  /// **'Secoue ton téléphone en même temps que ton ami'**
  String get shakeToAddWaiting;

  /// No description provided for @shakeToStop.
  ///
  /// In fr, this message translates to:
  /// **'Secoue le téléphone pour arrêter la partie'**
  String get shakeToStop;

  /// No description provided for @shareCode.
  ///
  /// In fr, this message translates to:
  /// **'PARTAGE CE CODE'**
  String get shareCode;

  /// No description provided for @signOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get signOut;

  /// No description provided for @start.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer'**
  String get start;

  /// No description provided for @startGameFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lancer la partie.'**
  String get startGameFailed;

  /// No description provided for @startRanked.
  ///
  /// In fr, this message translates to:
  /// **'Lancer une partie classée'**
  String get startRanked;

  /// No description provided for @starting.
  ///
  /// In fr, this message translates to:
  /// **'Lancement…'**
  String get starting;

  /// No description provided for @statElo.
  ///
  /// In fr, this message translates to:
  /// **'ELO'**
  String get statElo;

  /// No description provided for @statGames.
  ///
  /// In fr, this message translates to:
  /// **'Parties'**
  String get statGames;

  /// No description provided for @statWins.
  ///
  /// In fr, this message translates to:
  /// **'Victoires'**
  String get statWins;

  /// No description provided for @statsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger tes stats à jour — valeurs par défaut affichées.'**
  String get statsLoadError;

  /// No description provided for @statusConnected.
  ///
  /// In fr, this message translates to:
  /// **'Connecté'**
  String get statusConnected;

  /// No description provided for @statusOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get statusOffline;

  /// No description provided for @statusUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Statut inconnu'**
  String get statusUnknown;

  /// No description provided for @stop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get stop;

  /// No description provided for @stopCancels.
  ///
  /// In fr, this message translates to:
  /// **'Tu n\'as pas encore joué : elle sera simplement annulée.'**
  String get stopCancels;

  /// No description provided for @stopCountsAsLoss.
  ///
  /// In fr, this message translates to:
  /// **'Tu as déjà joué : elle comptera comme une défaite.'**
  String get stopCountsAsLoss;

  /// No description provided for @stopGameTitle.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter la partie ?'**
  String get stopGameTitle;

  /// No description provided for @stopLoserIsPlayerToMove.
  ///
  /// In fr, this message translates to:
  /// **'Le joueur dont c\'est le tour perdra la partie.'**
  String get stopLoserIsPlayerToMove;

  /// No description provided for @tabFriends.
  ///
  /// In fr, this message translates to:
  /// **'Amis'**
  String get tabFriends;

  /// No description provided for @tabHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get tabHistory;

  /// No description provided for @tabLeaderboard.
  ///
  /// In fr, this message translates to:
  /// **'Classement'**
  String get tabLeaderboard;

  /// No description provided for @tabPlay.
  ///
  /// In fr, this message translates to:
  /// **'Jouer'**
  String get tabPlay;

  /// No description provided for @turnOf.
  ///
  /// In fr, this message translates to:
  /// **'À {name} de jouer'**
  String turnOf(String name);

  /// No description provided for @usernameInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Ce pseudo n\'est pas valide.'**
  String get usernameInvalid;

  /// No description provided for @usernameInvalidChars.
  ///
  /// In fr, this message translates to:
  /// **'Lettres, chiffres, « _ » et « - » uniquement.'**
  String get usernameInvalidChars;

  /// No description provided for @usernameLabel.
  ///
  /// In fr, this message translates to:
  /// **'PSEUDO'**
  String get usernameLabel;

  /// No description provided for @usernameTaken.
  ///
  /// In fr, this message translates to:
  /// **'Ce pseudo est déjà pris.'**
  String get usernameTaken;

  /// No description provided for @usernameTooLong.
  ///
  /// In fr, this message translates to:
  /// **'{max} caractères maximum.'**
  String usernameTooLong(int max);

  /// No description provided for @usernameTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Au moins {min} caractères.'**
  String usernameTooShort(int min);

  /// No description provided for @usernameUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo mis à jour.'**
  String get usernameUpdated;

  /// No description provided for @waitingOpponent.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'un adversaire…'**
  String get waitingOpponent;

  /// No description provided for @you.
  ///
  /// In fr, this message translates to:
  /// **'Toi'**
  String get you;

  /// No description provided for @youAnd.
  ///
  /// In fr, this message translates to:
  /// **'Toi · {name}'**
  String youAnd(String name);

  /// No description provided for @youPlayedColumn.
  ///
  /// In fr, this message translates to:
  /// **'Tu as joué la colonne {column}'**
  String youPlayedColumn(int column);

  /// No description provided for @yourElo.
  ///
  /// In fr, this message translates to:
  /// **'TON ELO'**
  String get yourElo;

  /// No description provided for @yourTurn.
  ///
  /// In fr, this message translates to:
  /// **'À toi de jouer'**
  String get yourTurn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
