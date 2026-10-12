// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get abandon => 'Abandonner';

  @override
  String get abandonMessage =>
      'Quitter compte comme une défaite (ou une partie annulée si tu n\'as joué aucun coup).';

  @override
  String get abandonTitle => 'Abandonner la partie ?';

  @override
  String get aboutLine => 'Puissance 4 RL · v0.1 · Serverpod';

  @override
  String get accountCreated => 'Compte créé : ta progression est conservée.';

  @override
  String get accountSection => 'COMPTE';

  @override
  String get actionImpossible => 'Action impossible.';

  @override
  String activityDraw(String friend, String mode, String opponent) {
    return '$friend a fait match nul en $mode contre $opponent';
  }

  @override
  String get activityEmpty => 'Pas de partie chez tes amis cette semaine.';

  @override
  String activityLost(String friend, String mode, String opponent) {
    return '$friend a perdu en $mode contre $opponent';
  }

  @override
  String activityWon(String friend, String mode, String opponent) {
    return '$friend a gagné en $mode contre $opponent';
  }

  @override
  String get activityYou => 'toi';

  @override
  String get alreadyInGame => 'Tu as déjà une partie en cours.';

  @override
  String get appTitle => 'Puissance 4';

  @override
  String get authAnd => ' et la ';

  @override
  String get authBackToSignIn => 'Retour à la connexion';

  @override
  String get authBackToSignUp => 'Retour à l\'inscription';

  @override
  String get authContinue => 'Continuer';

  @override
  String get authContinueAsGuest => 'Continuer sans compte';

  @override
  String get authEmailLabel => 'ADRESSE E-MAIL';

  @override
  String authError(String error) {
    return 'Erreur de connexion : $error';
  }

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authHaveAccount => 'Déjà un compte ? ';

  @override
  String get authNewPasswordLabel => 'NOUVEAU MOT DE PASSE';

  @override
  String get authNewPasswordTitle => 'Nouveau mot de passe';

  @override
  String get authNoAccount => 'Pas de compte ? ';

  @override
  String get authNoProviders =>
      'Aucun moyen de connexion n\'est configuré sur le serveur.';

  @override
  String get authOfflineUnavailable =>
      'Pas de connexion internet : indisponible hors-ligne.';

  @override
  String get authOr => 'ou';

  @override
  String get authPasswordLabel => 'MOT DE PASSE';

  @override
  String get authPrivacyPolicy => 'politique de confidentialité';

  @override
  String get authRequestReset => 'Envoyer';

  @override
  String get authResetPassword => 'Réinitialiser';

  @override
  String get authResetPasswordDescription =>
      'Saisis ton adresse e-mail pour réinitialiser ton mot de passe.';

  @override
  String get authResetPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get authSetPasswordTitle => 'Choisir un mot de passe';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authSignUp => 'S\'inscrire';

  @override
  String get authSignUpTitle => 'Créer un compte';

  @override
  String get authTerms => 'conditions d\'utilisation';

  @override
  String get authTermsIntro => 'J\'ai lu et j\'accepte les ';

  @override
  String get authTitle => 'Connexion';

  @override
  String get authVerificationMessage =>
      'Un e-mail de vérification a été envoyé. Vérifie ta boîte de réception et saisis le code ci-dessous.';

  @override
  String get authVerify => 'Vérifier';

  @override
  String get authVerifyAccountTitle => 'Vérifier le compte';

  @override
  String get authVerifyCodeTitle => 'Vérifier le code';

  @override
  String get back => 'Retour';

  @override
  String get bestMove => 'Meilleur coup selon l\'Expert';

  @override
  String get botBeginner => 'Débutant';

  @override
  String botDisplayName(String name) {
    return 'Bot $name';
  }

  @override
  String get botEasy => 'Facile';

  @override
  String get botEasyDescription =>
      'Un réseau en tout début d\'entraînement, encore plein d\'erreurs.';

  @override
  String get botExpert => 'Expert';

  @override
  String get botExpertDescription =>
      'Le plus fort : entièrement entraîné, il réfléchit longuement (800 simulations).';

  @override
  String get botHard => 'Difficile';

  @override
  String get botHardDescription =>
      'Réfléchit avant chaque coup (100 simulations).';

  @override
  String get botMedium => 'Medium';

  @override
  String get botModerate => 'Moyen';

  @override
  String get botModerateDescription =>
      'Ne rate ni une victoire ni un blocage, mais ne calcule pas loin.';

  @override
  String botThinking(String name) {
    return '$name réfléchit…';
  }

  @override
  String get botVeryEasy => 'Très facile';

  @override
  String get botVeryEasyDescription =>
      'Un réseau qui n\'a encore rien appris : il joue presque au hasard.';

  @override
  String get cameraUnavailable =>
      'Caméra indisponible : vérifie l\'autorisation d\'accès.';

  @override
  String get cancel => 'Annuler';

  @override
  String challengeDeclined(String name) {
    return '$name a refusé ton défi.';
  }

  @override
  String challengeExpired(String name) {
    return '$name n\'a pas répondu à ton défi.';
  }

  @override
  String get challengeGone => 'Ce défi n\'existe plus.';

  @override
  String challengeReceived(String name) {
    return '$name te défie !';
  }

  @override
  String challengeWaiting(String name) {
    return 'En attente de $name…';
  }

  @override
  String get chooseMode => 'CHOISIS TON MODE';

  @override
  String get chooseOpponent => 'CHOISIS TON ADVERSAIRE';

  @override
  String get codeCopied => 'Code copié';

  @override
  String get codeHint => 'CODE';

  @override
  String get codeLength => 'Le code fait 6 caractères.';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get continueAction => 'Continuer';

  @override
  String get copy => 'Copier';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get createAccountIntro =>
      'Ton Elo, tes parties et ton historique restent sur ce compte. Tu pourras ensuite te connecter par email sur n\'importe quel appareil.';

  @override
  String get createAccountSignInBlocked =>
      'Pour te connecter à un compte existant, déconnecte-toi d\'abord depuis les réglages — ta progression d\'invité ne sera pas conservée.';

  @override
  String get createGameFailedRetry =>
      'Impossible de créer la partie. Réessaie.';

  @override
  String get createRoom => 'Créer et obtenir un code';

  @override
  String get createRoomSection => 'CRÉER UNE SALLE';

  @override
  String dateToday(String time) {
    return 'Aujourd\'hui, $time';
  }

  @override
  String dateYesterday(String time) {
    return 'Hier, $time';
  }

  @override
  String get defaultPlayerName => 'Joueur';

  @override
  String get disconnected => 'Déconnecté';

  @override
  String get edit => 'Modifier';

  @override
  String get editNeedsServer => 'Connexion au serveur requise pour modifier';

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String eloLabel(int elo) {
    return 'ELO $elo';
  }

  @override
  String eloVariation(String variation) {
    return ' ($variation Elo)';
  }

  @override
  String get expertAnalysing => 'L\'Expert analyse ce coup…';

  @override
  String expertWouldPlay(int column) {
    return 'L\'Expert jouait la colonne $column';
  }

  @override
  String get explainInvalid => 'Ce coup ne peut pas être expliqué.';

  @override
  String get explainMove => 'Expliquer ce coup';

  @override
  String get explainNotConfigured =>
      'L\'explication par IA n\'est pas activée sur ce serveur.';

  @override
  String get explainRateLimited =>
      'Trop d\'explications demandées cette heure-ci. Réessaie plus tard.';

  @override
  String get explainSignIn => 'Connecte-toi pour obtenir une explication.';

  @override
  String get explainUnavailable =>
      'Le service d\'explication ne répond pas. Réessaie plus tard.';

  @override
  String get filterAll => 'Tous';

  @override
  String get friendAccept => 'Accepter';

  @override
  String friendAccepted(String name) {
    return 'Vous êtes maintenant amis avec $name !';
  }

  @override
  String get friendAdd => 'Ajouter';

  @override
  String get friendChallenge => 'Défier';

  @override
  String get friendCodeCopied => 'Code ami copié.';

  @override
  String get friendCodeCopy => 'Copier le code';

  @override
  String get friendCodeHint => 'Donne-le à un ami pour qu\'il t\'ajoute.';

  @override
  String get friendDecline => 'Refuser';

  @override
  String get friendQrHint =>
      'Fais-le scanner par ton ami depuis Amis › Ajouter.';

  @override
  String get friendRelationFriend => 'Ami';

  @override
  String get friendRelationSent => 'Demande envoyée';

  @override
  String get friendRemove => 'Retirer';

  @override
  String get friendRemoveMessage => 'Tu disparaîtras aussi de sa liste.';

  @override
  String friendRemoveTitle(String name) {
    return 'Retirer $name de tes amis ?';
  }

  @override
  String friendRequestDaysAgo(int days) {
    return 'Il y a $days jours';
  }

  @override
  String friendRequestSent(String name) {
    return 'Demande envoyée à $name.';
  }

  @override
  String get friendRequestToday => 'Aujourd\'hui';

  @override
  String get friendRequestYesterday => 'Hier';

  @override
  String get friendRequestsEmpty => 'Aucune demande en attente.';

  @override
  String get friendRequestsReceived => 'REÇUES';

  @override
  String get friendRequestsSent => 'ENVOYÉES';

  @override
  String get friendScanHint => 'Vise le QR code de ton ami (Amis › Ajouter).';

  @override
  String get friendScanQr => 'Scanner un QR';

  @override
  String get friendSearchHint => 'Pseudo ou code ami (P4-…)';

  @override
  String get friendSearchNoResult => 'Aucun joueur trouvé.';

  @override
  String get friendSearchTooShort =>
      'Tape au moins 3 caractères, ou un code ami.';

  @override
  String get friendShakeToAdd => 'Secouer';

  @override
  String get friendShowQr => 'Afficher mon QR code';

  @override
  String get friendUnavailable => 'Cet ami n\'est plus disponible pour jouer.';

  @override
  String get friendsEmpty =>
      'Pas encore d\'amis. Ajoute les joueurs que tu croises !';

  @override
  String get friendsEmptyAction => 'Ajouter des amis';

  @override
  String get friendsErrorAlreadyFriends => 'Vous êtes déjà amis.';

  @override
  String get friendsErrorAlreadySent => 'Demande déjà envoyée.';

  @override
  String get friendsErrorNotFriends => 'Vous n\'êtes plus amis.';

  @override
  String get friendsErrorRequestNotFound => 'Cette demande n\'existe plus.';

  @override
  String get friendsErrorSelf => 'Tu ne peux pas t\'ajouter toi-même.';

  @override
  String get friendsErrorTooMany => 'Limite de 200 amis atteinte.';

  @override
  String get friendsErrorUserNotFound => 'Joueur introuvable.';

  @override
  String get friendsGuestMessage =>
      'Crée un compte pour ajouter des amis : tu gardes ta progression.';

  @override
  String get friendsLoadError => 'Impossible de charger tes amis.';

  @override
  String get friendsLocalGuestMessage =>
      'Connecte-toi au serveur pour ajouter des amis.';

  @override
  String friendsSince(String date) {
    return 'Amis depuis le $date';
  }

  @override
  String get friendsTabAdd => 'Ajouter';

  @override
  String get friendsTabList => 'Mes amis';

  @override
  String get friendsTabRequests => 'Demandes';

  @override
  String get friendsTabRivalries => 'Rivalités';

  @override
  String get gameCancelled => 'Partie annulée';

  @override
  String get gameConnecting => 'Connexion à la partie…';

  @override
  String get gameDraw => 'Match nul';

  @override
  String get gameInProgressBanner => 'Tu as une partie en cours.';

  @override
  String get gameInProgressTitle => 'Partie en cours';

  @override
  String get gameLost => 'Défaite';

  @override
  String get gameLostByDisconnect => 'Défaite (déconnexion)';

  @override
  String get gameLostByForfeit => 'Défaite par abandon';

  @override
  String get gameLostOnTime => 'Défaite au temps';

  @override
  String get gameReconnecting => 'Connexion perdue — reconnexion…';

  @override
  String get gameWon => 'Victoire !';

  @override
  String get gameWonByDisconnect => 'Victoire (déconnexion) !';

  @override
  String get gameWonByForfeit => 'Victoire par abandon !';

  @override
  String get gameWonOnTime => 'Victoire au temps !';

  @override
  String get guestAccount => 'Compte invité';

  @override
  String get guestAccountHint =>
      'Crée un compte pour ne pas perdre ta progression.';

  @override
  String get guestSignOutMessage =>
      'Tu joues en invité : en te déconnectant, tu perdras ta progression (Elo, parties, historique) sans pouvoir la retrouver.';

  @override
  String get guestSignOutTitle => 'Se déconnecter ?';

  @override
  String get historyEmpty => 'Aucune partie pour l\'instant.';

  @override
  String get historyLoadError => 'Impossible de charger l\'historique.';

  @override
  String get historyTitle => 'Historique';

  @override
  String get join => 'Rejoindre';

  @override
  String get joinFriendSection => 'REJOINDRE UN AMI';

  @override
  String labelWithElo(String label, int elo) {
    return '$label · ELO $elo';
  }

  @override
  String get language => 'Langue';

  @override
  String get layFlatHint => 'Pose le téléphone à plat pour jouer à deux';

  @override
  String get leaderboardAlone => 'Personne d\'autre pour l\'instant.';

  @override
  String get leaderboardFriends => 'Amis';

  @override
  String get leaderboardGlobal => 'Global';

  @override
  String get leaderboardLoadError => 'Impossible de charger le classement.';

  @override
  String get leaderboardNoFriends => 'Ajoute des amis pour te comparer à eux.';

  @override
  String get leaderboardSignIn => 'Connecte-toi pour voir le classement.';

  @override
  String get loginTagline => 'Défie l\'IA. Grimpe le classement.';

  @override
  String get loginWordmark => 'PUISSANCE ';

  @override
  String losingMove(int column) {
    return 'Coup perdant — l\'Expert jouait la colonne $column';
  }

  @override
  String get modeFaceToFace => 'Face à face';

  @override
  String get modeFaceToFaceSubtitle =>
      'À deux sur ce téléphone, posé sur la table';

  @override
  String get modeMulti => 'Multi';

  @override
  String get modeMultiplayer => 'Multijoueur';

  @override
  String get modeMultiplayerSubtitle => 'Défie un ami en 1v1';

  @override
  String get modeNormal => 'Normal';

  @override
  String get modeNormalSubtitle => 'Choisis la difficulté du bot';

  @override
  String get modeRanked => 'Classé';

  @override
  String get modeRankedSubtitle =>
      'Affronte le bot du serveur, fais monter ton Elo';

  @override
  String get myFriendCode => 'MON CODE AMI';

  @override
  String get needsServer => 'Ce mode nécessite une connexion au serveur.';

  @override
  String get newGame => 'Nouvelle partie';

  @override
  String get newGameFailed => 'Impossible de créer la partie.';

  @override
  String get newGameStarted => 'Nouvelle partie !';

  @override
  String get noOpenRooms =>
      'Aucune salle publique pour le moment. Crée la tienne !';

  @override
  String get normalNeedsSession =>
      'Connecte-toi (même en invité, en ligne) pour jouer.';

  @override
  String get notImplemented => 'Pas encore implémenté';

  @override
  String get noticeColumnFull => 'Colonne pleine.';

  @override
  String get noticeConnectionLost =>
      'Connexion perdue — nouvelles tentatives en cours.';

  @override
  String get noticeGameNotFound => 'Partie introuvable.';

  @override
  String get noticeGameOver => 'La partie est terminée.';

  @override
  String get noticeMoveRefused => 'Coup refusé. Réessaie.';

  @override
  String get noticeMoveUnconfirmed =>
      'Connexion instable — coup en attente de confirmation.';

  @override
  String get noticeNotYourTurn => 'Ce n\'est pas ton tour.';

  @override
  String get noticeSaveFailed =>
      'La partie n\'a pas pu être enregistrée sur l\'appareil.';

  @override
  String get openRoomsSection => 'SALLES OUVERTES';

  @override
  String get openRoomsUnavailable => 'Liste des salles indisponible.';

  @override
  String get opponent => 'Adversaire';

  @override
  String get opponentDisconnected =>
      'Adversaire déconnecté — victoire s\'il ne revient pas.';

  @override
  String get opponentTurn => 'Tour de l\'adversaire';

  @override
  String get ownRoom => 'C\'est ta propre salle : partage le code à un ami.';

  @override
  String get photoChange => 'Changer la photo';

  @override
  String get photoChoose => 'Choisir dans la galerie';

  @override
  String get photoInvalid => 'Ce fichier n\'est pas une image lisible.';

  @override
  String get photoNeedsServer =>
      'Connexion au serveur requise pour changer la photo';

  @override
  String get photoPickFailed => 'Impossible d\'ouvrir la caméra ou la galerie.';

  @override
  String get photoRemove => 'Supprimer la photo';

  @override
  String get photoRemoved => 'Photo de profil supprimée.';

  @override
  String get photoTake => 'Prendre une photo';

  @override
  String get photoTooLarge => 'Cette image est trop grande.';

  @override
  String get photoUpdated => 'Photo de profil mise à jour.';

  @override
  String get player1 => 'Joueur 1';

  @override
  String get player2 => 'Joueur 2';

  @override
  String playerPlayedColumn(String name, int column) {
    return '$name a joué la colonne $column';
  }

  @override
  String playerWins(String name) {
    return '$name gagne !';
  }

  @override
  String get poweredByServerpod => 'Propulsé par Serverpod';

  @override
  String get preferencesSection => 'PRÉFÉRENCES';

  @override
  String get presenceOnline => 'En ligne';

  @override
  String presencePlaying(String mode) {
    return 'En partie · $mode';
  }

  @override
  String presenceSeenDays(int count) {
    return 'Vu il y a $count j';
  }

  @override
  String presenceSeenHours(int count) {
    return 'Vu il y a $count h';
  }

  @override
  String get presenceSeenJustNow => 'Vu à l\'instant';

  @override
  String presenceSeenMinutes(int count) {
    return 'Vu il y a $count min';
  }

  @override
  String get publicRoom => 'Salle publique';

  @override
  String get publicRoomOff => 'Seuls ceux qui ont le code peuvent rejoindre';

  @override
  String get publicRoomOn => 'Visible par tous dans les salles ouvertes';

  @override
  String rankedOpponent(String name, int elo) {
    return 'Adversaire : Bot $name (ELO $elo)';
  }

  @override
  String get rankedRules =>
      'Chaque coup est validé par le serveur. Victoire, défaite ou nul font varier ton Elo ; quitter la partie compte comme une défaite (sauf si tu n\'as joué aucun coup). 60 s par coup.';

  @override
  String get recentOpponents => 'RENCONTRÉS RÉCEMMENT';

  @override
  String get recentOpponentsEmpty =>
      'Tes adversaires en Multi apparaîtront ici, pour les ajouter en un tap.';

  @override
  String get replayFirst => 'Début';

  @override
  String get replayLast => 'Fin';

  @override
  String replayMove(int cursor, int total) {
    return 'Coup $cursor / $total';
  }

  @override
  String get replayNext => 'Suivant';

  @override
  String get replayNoMoves =>
      'Les coups de cette partie n\'ont pas été enregistrés.';

  @override
  String get replayPause => 'Pause';

  @override
  String get replayPlay => 'Lecture';

  @override
  String get replayPrevious => 'Précédent';

  @override
  String get replayTitle => 'Revoir la partie';

  @override
  String get replayUnavailable =>
      'Replay indisponible pour le moment (réseau ?).';

  @override
  String get resultDraw => 'Match nul';

  @override
  String get resultLoss => 'Défaite';

  @override
  String get resultWin => 'Victoire';

  @override
  String get resume => 'Reprendre';

  @override
  String get retry => 'Réessayer';

  @override
  String get rivalriesActivity => 'ACTIVITÉ DE TES AMIS';

  @override
  String get rivalriesEmpty => 'Ajoute des amis pour suivre vos rivalités.';

  @override
  String get rivalriesHeadToHead => 'TÊTE-À-TÊTE';

  @override
  String get rivalryChallengeOffline => 'Défier (quand il sera en ligne)';

  @override
  String rivalryDraws(int count) {
    return '$count nul(s)';
  }

  @override
  String get rivalryGames => 'VOS PARTIES';

  @override
  String get rivalryGamesEmpty => 'Défie-le pour commencer votre rivalité !';

  @override
  String get rivalryNoGames => 'Pas encore joué ensemble';

  @override
  String rivalryRecord(int wins, int losses, int draws) {
    return '$wins V · $losses D · $draws N';
  }

  @override
  String get roomClosedNobody =>
      'Salle fermée : personne ne l\'a rejointe à temps.';

  @override
  String roomClosesIn(String remaining) {
    return 'La salle se ferme dans $remaining';
  }

  @override
  String roomHostInfo(int elo, String remaining) {
    return '$elo Elo · $remaining';
  }

  @override
  String get roomNotFound => 'Code inconnu ou salle déjà fermée.';

  @override
  String get roomTaken => 'Salle déjà prise ou fermée.';

  @override
  String get save => 'Enregistrer';

  @override
  String secondsLeft(int seconds) {
    return '$seconds s';
  }

  @override
  String get serverConnectionLost => 'Connexion au serveur perdue.';

  @override
  String get serverUnreachableLater =>
      'Impossible de joindre le serveur. Réessaie plus tard.';

  @override
  String get serverUnreachableRetry =>
      'Impossible de joindre le serveur. Réessaie.';

  @override
  String get serversUnreachable =>
      'Vous êtes connecté à internet, mais nos serveurs sont injoignables pour le moment.';

  @override
  String get settings => 'Réglages';

  @override
  String get shakeToAddFound => 'Trouvé !';

  @override
  String get shakeToAddHint =>
      'Rien n\'est envoyé sans ton accord : tu choisis ensuite de l\'ajouter.';

  @override
  String get shakeToAddMatching => 'Recherche…';

  @override
  String get shakeToAddNobody => 'Personne n\'a secoué en même temps';

  @override
  String get shakeToAddWaiting =>
      'Secoue ton téléphone en même temps que ton ami';

  @override
  String get shakeToStop => 'Secoue le téléphone pour arrêter la partie';

  @override
  String get shareCode => 'PARTAGE CE CODE';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get start => 'Démarrer';

  @override
  String get startGameFailed => 'Impossible de lancer la partie.';

  @override
  String get startRanked => 'Lancer une partie classée';

  @override
  String get starting => 'Lancement…';

  @override
  String get statElo => 'ELO';

  @override
  String get statGames => 'Parties';

  @override
  String get statWins => 'Victoires';

  @override
  String get statsLoadError =>
      'Impossible de charger tes stats à jour — valeurs par défaut affichées.';

  @override
  String get statsServerRequired =>
      'Le tableau de bord et l\'assistant ont besoin d\'une connexion au serveur. Connecte-toi pour les utiliser.';

  @override
  String get statsTitle => 'Mes stats';

  @override
  String get statusConnected => 'Connecté';

  @override
  String get statusOffline => 'Hors ligne';

  @override
  String get statusUnknown => 'Statut inconnu';

  @override
  String get stop => 'Arrêter';

  @override
  String get stopCancels =>
      'Tu n\'as pas encore joué : elle sera simplement annulée.';

  @override
  String get stopCountsAsLoss =>
      'Tu as déjà joué : elle comptera comme une défaite.';

  @override
  String get stopGameTitle => 'Arrêter la partie ?';

  @override
  String get stopLoserIsPlayerToMove =>
      'Le joueur dont c\'est le tour perdra la partie.';

  @override
  String get tabFriends => 'Amis';

  @override
  String get tabHistory => 'Historique';

  @override
  String get tabLeaderboard => 'Classement';

  @override
  String get tabPlay => 'Jouer';

  @override
  String get tabStats => 'Stats';

  @override
  String get theme => 'Thème';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeSystem => 'Système';

  @override
  String turnOf(String name) {
    return 'À $name de jouer';
  }

  @override
  String get usernameInvalid => 'Ce pseudo n\'est pas valide.';

  @override
  String get usernameInvalidChars =>
      'Lettres, chiffres, « _ » et « - » uniquement.';

  @override
  String get usernameLabel => 'PSEUDO';

  @override
  String get usernameTaken => 'Ce pseudo est déjà pris.';

  @override
  String usernameTooLong(int max) {
    return '$max caractères maximum.';
  }

  @override
  String usernameTooShort(int min) {
    return 'Au moins $min caractères.';
  }

  @override
  String get usernameUpdated => 'Pseudo mis à jour.';

  @override
  String get waitingOpponent => 'En attente d\'un adversaire…';

  @override
  String get you => 'Toi';

  @override
  String youAnd(String name) {
    return 'Toi · $name';
  }

  @override
  String youPlayedColumn(int column) {
    return 'Tu as joué la colonne $column';
  }

  @override
  String get yourElo => 'TON ELO';

  @override
  String get yourTurn => 'À toi de jouer';
}
