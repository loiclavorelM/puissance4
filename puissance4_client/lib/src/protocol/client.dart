/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'package:http/http.dart' as _i85jenna;
import 'package:puissance4_client/src/protocol/bot/bot.dart' as _ighv8e6n;
import 'package:puissance4_client/src/protocol/game/enum_type.dart'
    as _i6ui2hi8;
import 'package:puissance4_client/src/protocol/game/game_event.dart'
    as _iho1cjz0;
import 'package:puissance4_client/src/protocol/greetings/greeting.dart'
    as _i45e1izr;
import 'package:puissance4_client/src/protocol/history/history_dto.dart'
    as _igkkg43x;
import 'package:puissance4_client/src/protocol/history/replay_dto.dart'
    as _io6ngfmf;
import 'package:puissance4_client/src/protocol/leaderboard/leaderboard_dto.dart'
    as _ihkbd7x6;
import 'package:puissance4_client/src/protocol/live/live_event.dart'
    as _io59k800;
import 'package:puissance4_client/src/protocol/multiplayer/lobby_snapshot.dart'
    as _imc99i6z;
import 'package:puissance4_client/src/protocol/profile/user_profile_dto.dart'
    as _i5lufru8;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_database/serverpod_database.dart' as _isd;
import 'package:serverpod_offline_sync_client/serverpod_offline_sync_client.dart'
    as _ipulbpi2;
import 'protocol.dart' as _il2as5qe;
import 'sync_tables.dart' as _ii3f3u05;
import 'package:puissance4_client/migrations/migration_registry.dart';

/// By extending [AnonymousIdpBaseEndpoint], the anonymous identity provider
/// endpoint is made available on the server and enables the corresponding
/// sign-in widget on the client.
/// {@category Endpoint}
class EndpointAnonymousIdp extends _iaic.EndpointAnonymousIdpBase {
  EndpointAnonymousIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'anonymousIdp';

  /// Creates a new anonymous account and returns its session.
  ///
  /// Invokes the [AnonymousIdp.beforeAnonymousAccount] callback if configured,
  /// which may prevent account creation if the endpoint is protected.
  @override
  _ida.Future<_iacc.AuthSuccess> login({String? token}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'anonymousIdp',
        'login',
        {'token': token},
      );
}

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// Liste des bots jouables en mode Normal (E5) — alimentée par `botSeeds`
/// (`bot_seed.dart`). Pas de connexion requise : ce n'est pas une donnée
/// personnelle, et un invité local doit pouvoir voir les niveaux proposés.
/// {@category Endpoint}
class EndpointBot extends _isc.EndpointRef {
  EndpointBot(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'bot';

  _ida.Future<List<_ighv8e6n.Bot>> getBots() =>
      caller.callServerEndpoint<List<_ighv8e6n.Bot>>(
        'bot',
        'getBots',
        {},
      );
}

/// Endpoint volontairement vide : sert uniquement de sonde de joignabilité
/// pour `ServerConnectionTracker` côté client. Le simple fait que l'appel
/// réussisse ou échoue passe par les hooks globaux
/// `onSucceededCall`/`onFailedCall` du client généré.
/// {@category Endpoint}
class EndpointConnection extends _isc.EndpointRef {
  EndpointConnection(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'connection';

  _ida.Future<void> ping() => caller.callServerEndpoint<void>(
    'connection',
    'ping',
    {},
  );
}

/// Partie serveur en cours, quel que soit le mode (Multi ou Classé) : la
/// suivre, y jouer, l'abandonner. Les parties naissent ailleurs
/// (`MultiplayerEndpoint`, `RankedEndpoint`) ; voir `server_game.dart` pour
/// les garanties de fin.
/// {@category Endpoint}
class EndpointGame extends _isc.EndpointRef {
  EndpointGame(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'game';

  /// Partie serveur en cours de l'appelant (à reprendre par [watchPartie]),
  /// ou `null`.
  _ida.Future<_isc.UuidValue?> getActivePartie() =>
      caller.callServerEndpoint<_isc.UuidValue?>(
        'game',
        'getActivePartie',
        {},
      );

  /// Suit la partie : `gameStarted` (photo complète) puis les événements, ou
  /// directement `gameOver` si elle est déjà terminée. Sert aussi à revenir
  /// après une coupure, dans le délai de grâce.
  _ida.Stream<_iho1cjz0.GameEvent> watchPartie(_isc.UuidValue partieId) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_iho1cjz0.GameEvent>,
        _iho1cjz0.GameEvent
      >(
        'game',
        'watchPartie',
        {'partieId': partieId},
        {},
      );

  _ida.Future<void> playMove(
    _isc.UuidValue partieId,
    int column,
  ) => caller.callServerEndpoint<void>(
    'game',
    'playMove',
    {
      'partieId': partieId,
      'column': column,
    },
  );

  _ida.Future<void> abandon(_isc.UuidValue partieId) =>
      caller.callServerEndpoint<void>(
        'game',
        'abandon',
        {'partieId': partieId},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _isc.EndpointRef {
  EndpointGreeting(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _ida.Future<_i45e1izr.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i45e1izr.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// Historique des parties de l'appelant (E9) — ne couvre que Multi/Classé
/// (`Partie`). Normal (`OfflineMatchResult`) est une table `database: sync`
/// sans FK vers `User` : elle est lue côté client depuis la session de
/// synchro locale déjà ouverte, pas via cet endpoint. Voir le plan Historique
/// pour le détail de cette séparation volontaire.
/// {@category Endpoint}
class EndpointHistory extends _isc.EndpointRef {
  EndpointHistory(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'history';

  _ida.Future<List<_igkkg43x.HistoryDto>> getListHistories({
    _i6ui2hi8.EnumType? typePartie,
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<List<_igkkg43x.HistoryDto>>(
    'history',
    'getListHistories',
    {
      'typePartie': typePartie,
      'limit': limit,
      'offset': offset,
    },
  );

  /// Coups et joueurs d'une partie Multi/Classé, pour la rejouer (E14).
  /// Réservé aux joueurs de la partie (`GameException(notAPlayer)` sinon).
  _ida.Future<_io6ngfmf.ReplayDto> getReplay({
    required _isc.UuidValue idPartie,
  }) => caller.callServerEndpoint<_io6ngfmf.ReplayDto>(
    'history',
    'getReplay',
    {'idPartie': idPartie},
  );

  _ida.Future<_igkkg43x.HistoryDto> getHistory({
    required _isc.UuidValue idPartie,
  }) => caller.callServerEndpoint<_igkkg43x.HistoryDto>(
    'history',
    'getHistory',
    {'idPartie': idPartie},
  );
}

/// Classement par Elo (E8) — uniquement des `User`, jamais de `Bot` (son
/// `elo` ne sert qu'au matchmaking de difficulté, cf. plan Classement).
/// {@category Endpoint}
class EndpointLeaderboard extends _isc.EndpointRef {
  EndpointLeaderboard(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'leaderboard';

  _ida.Future<List<_ihkbd7x6.LeaderboardEntryDto>> getLeaderboard({
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<List<_ihkbd7x6.LeaderboardEntryDto>>(
    'leaderboard',
    'getLeaderboard',
    {
      'limit': limit,
      'offset': offset,
    },
  );

  /// Rang calculé séparément de [getLeaderboard] (pas de vrai départage
  /// d'ex-aequo, comme la pagination) — permet à l'écran d'afficher la ligne
  /// du joueur courant même quand elle est hors de la page top-N chargée.
  _ida.Future<_ihkbd7x6.LeaderboardEntryDto> getMyRank() =>
      caller.callServerEndpoint<_ihkbd7x6.LeaderboardEntryDto>(
        'leaderboard',
        'getMyRank',
        {},
      );
}

/// Mises à jour "temps réel" : un stream (WebSocket) par client connecté qui
/// reçoit un [LiveEvent] chaque fois que son profil, son historique ou le
/// Classement change côté serveur — les écritures appellent les helpers de
/// `live_notifier.dart`.
/// {@category Endpoint}
class EndpointLive extends _isc.EndpointRef {
  EndpointLive(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'live';

  _ida.Stream<_io59k800.LiveEvent> watchUpdates() =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_io59k800.LiveEvent>,
        _io59k800.LiveEvent
      >(
        'live',
        'watchUpdates',
        {},
        {},
      );
}

/// Multijoueur en ligne (E7) : salles d'attente. Une salle n'existe que tant
/// que le stream de son hôte est ouvert ([hostRoom]) ; la `Partie` n'est
/// créée qu'à l'arrivée de l'adversaire ([joinRoom]). Une fois la partie
/// commencée, chaque joueur la suit par le même stream (ou par
/// `GameEndpoint.watchPartie` après une coupure) et joue par
/// `GameEndpoint.playMove`.
/// {@category Endpoint}
class EndpointMultiplayer extends _isc.EndpointRef {
  EndpointMultiplayer(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'multiplayer';

  /// Ouvre une salle : émet `roomCreated` (avec le code), puis, à l'arrivée
  /// de l'adversaire, les événements de la partie. Fermer ce stream avant
  /// ferme la salle ; à expiration il émet `roomClosed` et se termine.
  /// Une salle [isPublic] apparaît dans le lobby ([watchLobby]) ; sinon elle
  /// ne se rejoint que par son code.
  _ida.Stream<_iho1cjz0.GameEvent> hostRoom(bool isPublic) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_iho1cjz0.GameEvent>,
        _iho1cjz0.GameEvent
      >(
        'multiplayer',
        'hostRoom',
        {'isPublic': isPublic},
        {},
      );

  /// Salles publiques ouvertes (sauf la sienne) : la liste au départ, puis
  /// une nouvelle liste à chaque changement. On les rejoint par [joinRoom]
  /// avec leur code — de deux joueurs qui choisissent la même, un seul
  /// l'obtient, l'autre reçoit `roomNotFound`.
  ///
  /// Pas de générateur `async*` : annulé pendant un `await for`, il ne le
  /// verrait qu'au changement suivant, et la session resterait ouverte.
  _ida.Stream<_imc99i6z.LobbySnapshot> watchLobby() =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_imc99i6z.LobbySnapshot>,
        _imc99i6z.LobbySnapshot
      >(
        'multiplayer',
        'watchLobby',
        {},
        {},
      );

  /// Rejoint la salle [code] : crée la partie et émet ses événements, à
  /// commencer par `gameStarted`.
  _ida.Stream<_iho1cjz0.GameEvent> joinRoom(String code) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_iho1cjz0.GameEvent>,
        _iho1cjz0.GameEvent
      >(
        'multiplayer',
        'joinRoom',
        {'code': code},
        {},
      );
}

/// {@category Endpoint}
class EndpointProfile extends _isc.EndpointRef {
  EndpointProfile(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'profile';

  _ida.Future<_i5lufru8.UserProfileDto> getMyProfile() =>
      caller.callServerEndpoint<_i5lufru8.UserProfileDto>(
        'profile',
        'getMyProfile',
        {},
      );

  /// Change le pseudo du User authentifié (seule modification de profil
  /// pour l'instant — la photo passera par un endpoint d'upload séparé,
  /// cf. T2.1.3). Lève [ProfileUpdateException] si [username] ne respecte
  /// pas [_usernamePattern] ou est déjà pris (insensible à la casse).
  _ida.Future<_i5lufru8.UserProfileDto> updateUsername(String username) =>
      caller.callServerEndpoint<_i5lufru8.UserProfileDto>(
        'profile',
        'updateUsername',
        {'username': username},
      );
}

/// Classé : partie contre un bot joué **par le serveur**, qui valide chaque
/// coup — l'Elo gagné ne peut donc pas être truqué côté client. Le bot est
/// choisi d'après l'Elo du joueur (cahier des charges : < 1000 Débutant,
/// < 1400 Medium, sinon Expert). La partie se suit ensuite comme toute
/// partie serveur, par `GameEndpoint.watchPartie` ; l'Elo est mis à jour à
/// sa fin (`ServerGame`).
/// {@category Endpoint}
class EndpointRanked extends _isc.EndpointRef {
  EndpointRanked(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'ranked';

  /// Crée la partie Classé et renvoie son id. Pas de salle ni de stream ici :
  /// si le client ne vient jamais la suivre, la fin du tour la termine comme
  /// n'importe quelle partie serveur abandonnée.
  _ida.Future<_isc.UuidValue> startRanked() =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'ranked',
        'startRanked',
        {},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_core = _iacc.Caller(client);
    serverpod_auth_idp = _iaic.Caller(client);
    offline_sync = _ipulbpi2.Caller(client);
  }

  late final _iacc.Caller serverpod_auth_core;

  late final _iaic.Caller serverpod_auth_idp;

  late final _ipulbpi2.Caller offline_sync;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    anonymousIdp = EndpointAnonymousIdp(this);
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    bot = EndpointBot(this);
    connection = EndpointConnection(this);
    game = EndpointGame(this);
    greeting = EndpointGreeting(this);
    history = EndpointHistory(this);
    leaderboard = EndpointLeaderboard(this);
    live = EndpointLive(this);
    multiplayer = EndpointMultiplayer(this);
    profile = EndpointProfile(this);
    ranked = EndpointRanked(this);
    modules = Modules(this);
  }

  late final EndpointAnonymousIdp anonymousIdp;

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointBot bot;

  late final EndpointConnection connection;

  late final EndpointGame game;

  late final EndpointGreeting greeting;

  late final EndpointHistory history;

  late final EndpointLeaderboard leaderboard;

  late final EndpointLive live;

  late final EndpointMultiplayer multiplayer;

  late final EndpointProfile profile;

  late final EndpointRanked ranked;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'anonymousIdp': anonymousIdp,
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'bot': bot,
    'connection': connection,
    'game': game,
    'greeting': greeting,
    'history': history,
    'leaderboard': leaderboard,
    'live': live,
    'multiplayer': multiplayer,
    'profile': profile,
    'ranked': ranked,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_core': modules.serverpod_auth_core,
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'offline_sync': modules.offline_sync,
  };

  /// Creates a new client-side database session for the given path.
  ///
  /// The [path] is the file path to the SQLite database file. Since SQLite uses
  /// WAL mode, note that `[path]-shm` and `[path]-wal` files might also exist
  /// transiently for the database while the session is open.
  ///
  /// If [runMigrations] is true, pending migrations will be applied when
  /// opening the database. Be careful when setting this to false, as it might
  /// lead to inconsistencies between the models and the database.
  ///
  /// If [isDebugMode] is true, the database integrity will be verified after
  /// the migrations are applied to provide feedback of possible issues. On a
  /// Flutter application, this should be set to [kDebugMode].
  _ida.Future<_isd.ClientDatabaseSession> createSession(
    String path, {
    bool runMigrations = true,
    bool isDebugMode = false,
  }) async {
    return await _isd.ClientDatabaseSession.open(
      path,
      _il2as5qe.Protocol(),
      clientMigrations: MigrationRegistry.migrations,
      runMigrations: runMigrations,
      isDebugMode: isDebugMode,
    );
  }

  /// Creates a new client-side database session for the given path, wrapped
  /// with the `serverpod_offline_sync` engine for the tables declared with
  /// `database: sync`. See [createSession] for the [path], [runMigrations] and
  /// [isDebugMode] parameters.
  ///
  /// The [persistentUserId] is the user all local operations belong to. When
  /// omitted, the user must be passed through the transaction.
  _ida.Future<_ipulbpi2.OfflineSyncDatabaseSession> createSyncSession(
    String path, {
    bool runMigrations = true,
    bool isDebugMode = false,
    _isc.UuidValue? persistentUserId,
  }) async {
    final session = _ipulbpi2.OfflineSyncDatabaseSession.wraps(
      await createSession(
        path,
        runMigrations: runMigrations,
        isDebugMode: isDebugMode,
      ),
      syncTables: _ii3f3u05.syncTables,
      persistentUserId: persistentUserId,
    );
    await session.db.initialize();
    return session;
  }
}
