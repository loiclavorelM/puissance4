// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get abandon => 'Forfeit';

  @override
  String get abandonMessage =>
      'Leaving counts as a loss (or a cancelled game if you haven\'t played a move).';

  @override
  String get abandonTitle => 'Forfeit the game?';

  @override
  String get aboutLine => 'Connect Four RL · v0.1 · Serverpod';

  @override
  String get accountCreated => 'Account created: your progress is kept.';

  @override
  String get accountSection => 'ACCOUNT';

  @override
  String get actionImpossible => 'Can\'t do that.';

  @override
  String get alreadyInGame => 'You already have a game in progress.';

  @override
  String get appTitle => 'Connect Four';

  @override
  String get authAnd => ' and the ';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authBackToSignUp => 'Back to sign up';

  @override
  String get authContinue => 'Continue';

  @override
  String get authContinueAsGuest => 'Continue without an account';

  @override
  String get authEmailLabel => 'EMAIL ADDRESS';

  @override
  String authError(String error) {
    return 'Sign-in error: $error';
  }

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authHaveAccount => 'Already have an account? ';

  @override
  String get authNewPasswordLabel => 'NEW PASSWORD';

  @override
  String get authNewPasswordTitle => 'New password';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authNoProviders => 'No sign-in method is set up on the server.';

  @override
  String get authOfflineUnavailable =>
      'No internet connection: unavailable offline.';

  @override
  String get authOr => 'or';

  @override
  String get authPasswordLabel => 'PASSWORD';

  @override
  String get authPrivacyPolicy => 'privacy policy';

  @override
  String get authRequestReset => 'Send';

  @override
  String get authResetPassword => 'Reset';

  @override
  String get authResetPasswordDescription =>
      'Enter your email address to reset your password.';

  @override
  String get authResetPasswordTitle => 'Reset your password';

  @override
  String get authSetPasswordTitle => 'Choose a password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authSignUpTitle => 'Create an account';

  @override
  String get authTerms => 'terms of use';

  @override
  String get authTermsIntro => 'I have read and accept the ';

  @override
  String get authTitle => 'Sign in';

  @override
  String get authVerificationMessage =>
      'A verification email has been sent. Check your inbox and enter the code below.';

  @override
  String get authVerify => 'Verify';

  @override
  String get authVerifyAccountTitle => 'Verify your account';

  @override
  String get authVerifyCodeTitle => 'Verify the code';

  @override
  String get back => 'Back';

  @override
  String get bestMove => 'Best move according to the Expert';

  @override
  String get botBeginner => 'Beginner';

  @override
  String get botBeginnerDescription =>
      'A bot just getting started at Connect Four.';

  @override
  String botDisplayName(String name) {
    return '$name bot';
  }

  @override
  String get botExpert => 'Expert';

  @override
  String get botExpertDescription =>
      'The strongest bot, trained with reinforcement learning.';

  @override
  String get botMedium => 'Medium';

  @override
  String get botMediumDescription => 'An intermediate-level bot.';

  @override
  String botThinking(String name) {
    return '$name is thinking…';
  }

  @override
  String get botsLoadError => 'Couldn\'t load the bots.';

  @override
  String get cancel => 'Cancel';

  @override
  String get chooseMode => 'CHOOSE YOUR MODE';

  @override
  String get chooseOpponent => 'CHOOSE YOUR OPPONENT';

  @override
  String get codeCopied => 'Code copied';

  @override
  String get codeHint => 'CODE';

  @override
  String get codeLength => 'The code is 6 characters long.';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get continueAction => 'Continue';

  @override
  String get copy => 'Copy';

  @override
  String get createAccount => 'Create an account';

  @override
  String get createAccountIntro =>
      'Your Elo, games and history stay on this account. You can then sign in with your email on any device.';

  @override
  String get createAccountSignInBlocked =>
      'To sign in to an existing account, sign out first from the settings — your guest progress will not be kept.';

  @override
  String get createGameFailedRetry => 'Couldn\'t create the game. Try again.';

  @override
  String get createRoom => 'Create and get a code';

  @override
  String get createRoomSection => 'CREATE A ROOM';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String dateToday(String time) {
    return 'Today, $time';
  }

  @override
  String dateYesterday(String time) {
    return 'Yesterday, $time';
  }

  @override
  String get defaultPlayerName => 'Player';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get download => 'Download';

  @override
  String get edit => 'Edit';

  @override
  String get editNeedsServer => 'A server connection is needed to edit';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String eloLabel(int elo) {
    return 'ELO $elo';
  }

  @override
  String eloVariation(String variation) {
    return ' ($variation Elo)';
  }

  @override
  String get expertAnalysing => 'The Expert is analysing this move…';

  @override
  String expertWouldPlay(int column) {
    return 'The Expert would play column $column';
  }

  @override
  String get explainInvalid => 'This move can\'t be explained.';

  @override
  String get explainMove => 'Explain this move';

  @override
  String get explainNotConfigured =>
      'AI explanations aren\'t enabled on this server.';

  @override
  String get explainRateLimited =>
      'Too many explanations requested this hour. Try again later.';

  @override
  String get explainSignIn => 'Sign in to get an explanation.';

  @override
  String get explainUnavailable =>
      'The explanation service isn\'t responding. Try again later.';

  @override
  String get filterAll => 'All';

  @override
  String get gameCancelled => 'Game cancelled';

  @override
  String get gameConnecting => 'Joining the game…';

  @override
  String get gameDraw => 'Draw';

  @override
  String get gameInProgressBanner => 'You have a game in progress.';

  @override
  String get gameInProgressTitle => 'Game in progress';

  @override
  String get gameLost => 'You lose';

  @override
  String get gameLostByDisconnect => 'You lose (disconnection)';

  @override
  String get gameLostByForfeit => 'You lose by forfeit';

  @override
  String get gameLostOnTime => 'You lose on time';

  @override
  String get gameReconnecting => 'Connection lost — reconnecting…';

  @override
  String get gameWon => 'You win!';

  @override
  String get gameWonByDisconnect => 'You win (disconnection)!';

  @override
  String get gameWonByForfeit => 'You win by forfeit!';

  @override
  String get gameWonOnTime => 'You win on time!';

  @override
  String get guestAccount => 'Guest account';

  @override
  String get guestAccountHint =>
      'Create an account so you don\'t lose your progress.';

  @override
  String get guestSignOutMessage =>
      'You are playing as a guest: if you sign out, you will lose your progress (Elo, games, history) for good.';

  @override
  String get guestSignOutTitle => 'Sign out?';

  @override
  String get historyEmpty => 'No games yet.';

  @override
  String get historyLoadError => 'Couldn\'t load your history.';

  @override
  String get historyTitle => 'History';

  @override
  String get join => 'Join';

  @override
  String get joinFriendSection => 'JOIN A FRIEND';

  @override
  String labelWithElo(String label, int elo) {
    return '$label · ELO $elo';
  }

  @override
  String get language => 'Language';

  @override
  String get layFlatHint => 'Lay the phone flat for a two-player game';

  @override
  String get leaderboardAlone => 'Nobody else yet.';

  @override
  String get leaderboardFriends => 'Friends';

  @override
  String get leaderboardGlobal => 'Global';

  @override
  String get leaderboardLoadError => 'Couldn\'t load the leaderboard.';

  @override
  String get leaderboardSignIn => 'Sign in to see the leaderboard.';

  @override
  String get lightThemeSoon =>
      'A light theme is coming soon — your choice is already saved.';

  @override
  String get loginTagline => 'Challenge the AI. Climb the leaderboard.';

  @override
  String get loginWordmark => 'CONNECT ';

  @override
  String losingMove(int column) {
    return 'Losing move — the Expert would play column $column';
  }

  @override
  String get modeFaceToFace => 'Face to face';

  @override
  String get modeFaceToFaceSubtitle =>
      'Two players on this phone, lying on the table';

  @override
  String get modeMulti => 'Multi';

  @override
  String get modeMultiplayer => 'Multiplayer';

  @override
  String get modeMultiplayerSubtitle => 'Challenge a friend 1v1';

  @override
  String get modeNormal => 'Normal';

  @override
  String get modeNormalSubtitle => 'Pick the bot\'s difficulty';

  @override
  String get modeRanked => 'Ranked';

  @override
  String get modeRankedSubtitle => 'Play the server\'s bot, raise your Elo';

  @override
  String get needsServer => 'This mode needs a connection to the server.';

  @override
  String get newGame => 'New game';

  @override
  String get newGameFailed => 'Couldn\'t create the game.';

  @override
  String get newGameStarted => 'New game!';

  @override
  String get noOpenRooms => 'No public rooms right now. Create yours!';

  @override
  String get normalNeedsSession => 'Sign in (even as a guest, online) to play.';

  @override
  String get notImplemented => 'Not implemented yet';

  @override
  String get noticeColumnFull => 'Column full.';

  @override
  String get noticeConnectionLost => 'Connection lost — retrying.';

  @override
  String get noticeGameNotFound => 'Game not found.';

  @override
  String get noticeGameOver => 'The game is over.';

  @override
  String get noticeMoveRefused => 'Move refused. Try again.';

  @override
  String get noticeMoveUnconfirmed =>
      'Unstable connection — waiting for the move to be confirmed.';

  @override
  String get noticeNotYourTurn => 'It\'s not your turn.';

  @override
  String get noticeSaveFailed => 'The game couldn\'t be saved on this device.';

  @override
  String get openRoomsSection => 'OPEN ROOMS';

  @override
  String get openRoomsUnavailable => 'Room list unavailable.';

  @override
  String get opponent => 'Opponent';

  @override
  String get opponentDisconnected =>
      'Opponent disconnected — you win if they don\'t come back.';

  @override
  String get opponentTurn => 'Opponent\'s turn';

  @override
  String get ownRoom => 'That\'s your own room: share the code with a friend.';

  @override
  String get photoChange => 'Change the photo';

  @override
  String get photoChoose => 'Choose from the gallery';

  @override
  String get photoInvalid => 'This file isn\'t a readable image.';

  @override
  String get photoNeedsServer =>
      'A server connection is needed to change the photo';

  @override
  String get photoPickFailed => 'Couldn\'t open the camera or the gallery.';

  @override
  String get photoRemove => 'Remove the photo';

  @override
  String get photoRemoved => 'Profile photo removed.';

  @override
  String get photoTake => 'Take a photo';

  @override
  String get photoTooLarge => 'This image is too large.';

  @override
  String get photoUpdated => 'Profile photo updated.';

  @override
  String get player1 => 'Player 1';

  @override
  String get player2 => 'Player 2';

  @override
  String playerPlayedColumn(String name, int column) {
    return '$name played column $column';
  }

  @override
  String playerWins(String name) {
    return '$name wins!';
  }

  @override
  String get poweredByServerpod => 'Powered by Serverpod';

  @override
  String get preferencesSection => 'PREFERENCES';

  @override
  String get publicRoom => 'Public room';

  @override
  String get publicRoomOff => 'Only people with the code can join';

  @override
  String get publicRoomOn => 'Visible to everyone in open rooms';

  @override
  String rankedOpponent(String name, int elo) {
    return 'Opponent: $name bot (ELO $elo)';
  }

  @override
  String get rankedOpponentByElo => 'Opponent picked from your Elo';

  @override
  String get rankedRules =>
      'Every move is checked by the server. Wins, losses and draws change your Elo; leaving counts as a loss (unless you haven\'t played a move). 60 s per move.';

  @override
  String get replayFirst => 'Start';

  @override
  String get replayLast => 'End';

  @override
  String replayMove(int cursor, int total) {
    return 'Move $cursor / $total';
  }

  @override
  String get replayNext => 'Next';

  @override
  String get replayNoMoves => 'This game\'s moves weren\'t recorded.';

  @override
  String get replayPause => 'Pause';

  @override
  String get replayPlay => 'Play';

  @override
  String get replayPrevious => 'Previous';

  @override
  String get replayTitle => 'Replay';

  @override
  String get replayUnavailable => 'Replay unavailable right now (network?).';

  @override
  String get resultDraw => 'Draw';

  @override
  String get resultLoss => 'Loss';

  @override
  String get resultWin => 'Win';

  @override
  String get resume => 'Resume';

  @override
  String get retry => 'Retry';

  @override
  String get roomClosedNobody => 'Room closed: nobody joined in time.';

  @override
  String roomClosesIn(String remaining) {
    return 'The room closes in $remaining';
  }

  @override
  String roomHostInfo(int elo, String remaining) {
    return '$elo Elo · $remaining';
  }

  @override
  String get roomNotFound => 'Unknown code or room already closed.';

  @override
  String get roomTaken => 'Room already taken or closed.';

  @override
  String get save => 'Save';

  @override
  String secondsLeft(int seconds) {
    return '${seconds}s';
  }

  @override
  String get serverConnectionLost => 'Lost connection to the server.';

  @override
  String get serverUnreachableLater =>
      'Couldn\'t reach the server. Try again later.';

  @override
  String get serverUnreachableRetry => 'Couldn\'t reach the server. Try again.';

  @override
  String get serversUnreachable =>
      'You\'re online, but our servers can\'t be reached right now.';

  @override
  String get settings => 'Settings';

  @override
  String get shakeToStop => 'Shake the phone to stop the game';

  @override
  String get shareCode => 'SHARE THIS CODE';

  @override
  String get signOut => 'Sign out';

  @override
  String get start => 'Start';

  @override
  String get startGameFailed => 'Couldn\'t start the game.';

  @override
  String get startRanked => 'Start a ranked game';

  @override
  String get starting => 'Starting…';

  @override
  String get statElo => 'ELO';

  @override
  String get statGames => 'Games';

  @override
  String get statWins => 'Wins';

  @override
  String get statsLoadError =>
      'Couldn\'t load your latest stats — showing defaults.';

  @override
  String get statusConnected => 'Connected';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusUnknown => 'Unknown status';

  @override
  String get stop => 'Stop';

  @override
  String get stopCancels =>
      'You haven\'t played yet: it will simply be cancelled.';

  @override
  String get stopCountsAsLoss =>
      'You\'ve already played: it will count as a loss.';

  @override
  String get stopGameTitle => 'Stop the game?';

  @override
  String get stopLoserIsPlayerToMove =>
      'The player whose turn it is will lose the game.';

  @override
  String get tabHistory => 'History';

  @override
  String get tabLeaderboard => 'Leaderboard';

  @override
  String get tabPlay => 'Play';

  @override
  String turnOf(String name) {
    return '$name\'s turn';
  }

  @override
  String get usernameInvalid => 'This username isn\'t valid.';

  @override
  String get usernameInvalidChars => 'Letters, digits, \"_\" and \"-\" only.';

  @override
  String get usernameLabel => 'USERNAME';

  @override
  String get usernameTaken => 'This username is already taken.';

  @override
  String usernameTooLong(int max) {
    return '$max characters maximum.';
  }

  @override
  String usernameTooShort(int min) {
    return 'At least $min characters.';
  }

  @override
  String get usernameUpdated => 'Username updated.';

  @override
  String get waitingOpponent => 'Waiting for an opponent…';

  @override
  String get you => 'You';

  @override
  String youAnd(String name) {
    return 'You · $name';
  }

  @override
  String youPlayedColumn(int column) {
    return 'You played column $column';
  }

  @override
  String get yourElo => 'YOUR ELO';

  @override
  String get yourTurn => 'Your turn';
}
