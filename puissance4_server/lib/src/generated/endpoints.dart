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
import 'dart:typed_data' as _idt;
import 'package:puissance4_server/src/generated/game/enum_type.dart'
    as _ijl03sjm;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'package:serverpod_offline_sync_server/serverpod_offline_sync_server.dart'
    as _izehhkf5;
import '../auth/anonymous_idp_endpoint.dart' as _in0zita6;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../bot/bot_endpoint.dart' as _i8l8pxdo;
import '../connection/connection_endpoint.dart' as _in8dx5ef;
import '../friends/friends_endpoint.dart' as _ikhcdsyv;
import '../game/game_endpoint.dart' as _im5t12sm;
import '../greetings/greeting_endpoint.dart' as _il624ik7;
import '../history/history_endpoint.dart' as _iqb2o93i;
import '../leaderboard/leaderboard_endpoint.dart' as _io6aq3ur;
import '../live/live_endpoint.dart' as _i4k4ewet;
import '../multiplayer/multiplayer_endpoint.dart' as _iznver3h;
import '../profile/profile_endpoint.dart' as _i6ky944g;
import '../ranked/ranked_endpoint.dart' as _iipq9d8b;
import '../review/review_endpoint.dart' as _iypg8dvf;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'anonymousIdp': _in0zita6.AnonymousIdpEndpoint()
        ..initialize(
          server,
          'anonymousIdp',
          null,
        ),
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'bot': _i8l8pxdo.BotEndpoint()
        ..initialize(
          server,
          'bot',
          null,
        ),
      'connection': _in8dx5ef.ConnectionEndpoint()
        ..initialize(
          server,
          'connection',
          null,
        ),
      'friends': _ikhcdsyv.FriendsEndpoint()
        ..initialize(
          server,
          'friends',
          null,
        ),
      'game': _im5t12sm.GameEndpoint()
        ..initialize(
          server,
          'game',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'history': _iqb2o93i.HistoryEndpoint()
        ..initialize(
          server,
          'history',
          null,
        ),
      'leaderboard': _io6aq3ur.LeaderboardEndpoint()
        ..initialize(
          server,
          'leaderboard',
          null,
        ),
      'live': _i4k4ewet.LiveEndpoint()
        ..initialize(
          server,
          'live',
          null,
        ),
      'multiplayer': _iznver3h.MultiplayerEndpoint()
        ..initialize(
          server,
          'multiplayer',
          null,
        ),
      'profile': _i6ky944g.ProfileEndpoint()
        ..initialize(
          server,
          'profile',
          null,
        ),
      'ranked': _iipq9d8b.RankedEndpoint()
        ..initialize(
          server,
          'ranked',
          null,
        ),
      'review': _iypg8dvf.ReviewEndpoint()
        ..initialize(
          server,
          'review',
          null,
        ),
    };
    connectors['anonymousIdp'] = _is.EndpointConnector(
      name: 'anonymousIdp',
      endpoint: endpoints['anonymousIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'token': _is.ParameterDescription(
              name: 'token',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['anonymousIdp'] as _in0zita6.AnonymousIdpEndpoint)
                      .login(
                        session,
                        token: params['token'],
                      ),
        ),
      },
    );
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['bot'] = _is.EndpointConnector(
      name: 'bot',
      endpoint: endpoints['bot']!,
      methodConnectors: {
        'getBots': _is.MethodConnector(
          name: 'getBots',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['bot'] as _i8l8pxdo.BotEndpoint).getBots(session),
        ),
      },
    );
    connectors['connection'] = _is.EndpointConnector(
      name: 'connection',
      endpoint: endpoints['connection']!,
      methodConnectors: {
        'ping': _is.MethodConnector(
          name: 'ping',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['connection'] as _in8dx5ef.ConnectionEndpoint)
                      .ping(session),
        ),
      },
    );
    connectors['friends'] = _is.EndpointConnector(
      name: 'friends',
      endpoint: endpoints['friends']!,
      methodConnectors: {
        'getOverview': _is.MethodConnector(
          name: 'getOverview',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friends'] as _ikhcdsyv.FriendsEndpoint)
                  .getOverview(session),
        ),
        'searchPlayers': _is.MethodConnector(
          name: 'searchPlayers',
          params: {
            'query': _is.ParameterDescription(
              name: 'query',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friends'] as _ikhcdsyv.FriendsEndpoint)
                  .searchPlayers(
                    session,
                    params['query'],
                  ),
        ),
        'recentOpponents': _is.MethodConnector(
          name: 'recentOpponents',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friends'] as _ikhcdsyv.FriendsEndpoint)
                  .recentOpponents(session),
        ),
        'getRivalries': _is.MethodConnector(
          name: 'getRivalries',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friends'] as _ikhcdsyv.FriendsEndpoint)
                  .getRivalries(session),
        ),
        'getFriendsActivity': _is.MethodConnector(
          name: 'getFriendsActivity',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friends'] as _ikhcdsyv.FriendsEndpoint)
                  .getFriendsActivity(session),
        ),
        'shakeToAdd': _is.MethodConnector(
          name: 'shakeToAdd',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friends'] as _ikhcdsyv.FriendsEndpoint)
                  .shakeToAdd(session),
        ),
        'getChallenges': _is.MethodConnector(
          name: 'getChallenges',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friends'] as _ikhcdsyv.FriendsEndpoint)
                  .getChallenges(session),
        ),
        'declineChallenge': _is.MethodConnector(
          name: 'declineChallenge',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friends'] as _ikhcdsyv.FriendsEndpoint)
                  .declineChallenge(
                    session,
                    params['code'],
                  ),
        ),
        'sendRequest': _is.MethodConnector(
          name: 'sendRequest',
          params: {
            'userId': _is.ParameterDescription(
              name: 'userId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friends'] as _ikhcdsyv.FriendsEndpoint)
                  .sendRequest(
                    session,
                    params['userId'],
                  ),
        ),
        'acceptRequest': _is.MethodConnector(
          name: 'acceptRequest',
          params: {
            'friendshipId': _is.ParameterDescription(
              name: 'friendshipId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friends'] as _ikhcdsyv.FriendsEndpoint)
                  .acceptRequest(
                    session,
                    params['friendshipId'],
                  ),
        ),
        'declineRequest': _is.MethodConnector(
          name: 'declineRequest',
          params: {
            'friendshipId': _is.ParameterDescription(
              name: 'friendshipId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friends'] as _ikhcdsyv.FriendsEndpoint)
                  .declineRequest(
                    session,
                    params['friendshipId'],
                  ),
        ),
        'cancelRequest': _is.MethodConnector(
          name: 'cancelRequest',
          params: {
            'friendshipId': _is.ParameterDescription(
              name: 'friendshipId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friends'] as _ikhcdsyv.FriendsEndpoint)
                  .cancelRequest(
                    session,
                    params['friendshipId'],
                  ),
        ),
        'removeFriend': _is.MethodConnector(
          name: 'removeFriend',
          params: {
            'userId': _is.ParameterDescription(
              name: 'userId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['friends'] as _ikhcdsyv.FriendsEndpoint)
                  .removeFriend(
                    session,
                    params['userId'],
                  ),
        ),
      },
    );
    connectors['game'] = _is.EndpointConnector(
      name: 'game',
      endpoint: endpoints['game']!,
      methodConnectors: {
        'getActivePartie': _is.MethodConnector(
          name: 'getActivePartie',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['game'] as _im5t12sm.GameEndpoint)
                  .getActivePartie(session),
        ),
        'playMove': _is.MethodConnector(
          name: 'playMove',
          params: {
            'partieId': _is.ParameterDescription(
              name: 'partieId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'column': _is.ParameterDescription(
              name: 'column',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['game'] as _im5t12sm.GameEndpoint).playMove(
                session,
                params['partieId'],
                params['column'],
              ),
        ),
        'abandon': _is.MethodConnector(
          name: 'abandon',
          params: {
            'partieId': _is.ParameterDescription(
              name: 'partieId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['game'] as _im5t12sm.GameEndpoint).abandon(
                session,
                params['partieId'],
              ),
        ),
        'watchPartie': _is.MethodStreamConnector(
          name: 'watchPartie',
          params: {
            'partieId': _is.ParameterDescription(
              name: 'partieId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['game'] as _im5t12sm.GameEndpoint).watchPartie(
                session,
                params['partieId'],
              ),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    connectors['history'] = _is.EndpointConnector(
      name: 'history',
      endpoint: endpoints['history']!,
      methodConnectors: {
        'getListHistories': _is.MethodConnector(
          name: 'getListHistories',
          params: {
            'typePartie': _is.ParameterDescription(
              name: 'typePartie',
              type: _is.getType<_ijl03sjm.EnumType?>(),
              nullable: true,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['history'] as _iqb2o93i.HistoryEndpoint)
                  .getListHistories(
                    session,
                    typePartie: params['typePartie'],
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'getReplay': _is.MethodConnector(
          name: 'getReplay',
          params: {
            'idPartie': _is.ParameterDescription(
              name: 'idPartie',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['history'] as _iqb2o93i.HistoryEndpoint).getReplay(
                    session,
                    idPartie: params['idPartie'],
                  ),
        ),
        'getHistory': _is.MethodConnector(
          name: 'getHistory',
          params: {
            'idPartie': _is.ParameterDescription(
              name: 'idPartie',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['history'] as _iqb2o93i.HistoryEndpoint)
                  .getHistory(
                    session,
                    idPartie: params['idPartie'],
                  ),
        ),
      },
    );
    connectors['leaderboard'] = _is.EndpointConnector(
      name: 'leaderboard',
      endpoint: endpoints['leaderboard']!,
      methodConnectors: {
        'getLeaderboard': _is.MethodConnector(
          name: 'getLeaderboard',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['leaderboard'] as _io6aq3ur.LeaderboardEndpoint)
                      .getLeaderboard(
                        session,
                        limit: params['limit'],
                        offset: params['offset'],
                      ),
        ),
        'getMyRank': _is.MethodConnector(
          name: 'getMyRank',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['leaderboard'] as _io6aq3ur.LeaderboardEndpoint)
                      .getMyRank(session),
        ),
      },
    );
    connectors['live'] = _is.EndpointConnector(
      name: 'live',
      endpoint: endpoints['live']!,
      methodConnectors: {
        'watchUpdates': _is.MethodStreamConnector(
          name: 'watchUpdates',
          params: {},
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['live'] as _i4k4ewet.LiveEndpoint).watchUpdates(
                session,
              ),
        ),
      },
    );
    connectors['multiplayer'] = _is.EndpointConnector(
      name: 'multiplayer',
      endpoint: endpoints['multiplayer']!,
      methodConnectors: {
        'hostRoom': _is.MethodStreamConnector(
          name: 'hostRoom',
          params: {
            'isPublic': _is.ParameterDescription(
              name: 'isPublic',
              type: _is.getType<bool>(),
              nullable: false,
            ),
            'challengeUserId': _is.ParameterDescription(
              name: 'challengeUserId',
              type: _is.getType<_is.UuidValue?>(),
              nullable: true,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['multiplayer'] as _iznver3h.MultiplayerEndpoint)
                  .hostRoom(
                    session,
                    params['isPublic'],
                    challengeUserId: params['challengeUserId'],
                  ),
        ),
        'watchLobby': _is.MethodStreamConnector(
          name: 'watchLobby',
          params: {},
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['multiplayer'] as _iznver3h.MultiplayerEndpoint)
                  .watchLobby(session),
        ),
        'joinRoom': _is.MethodStreamConnector(
          name: 'joinRoom',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['multiplayer'] as _iznver3h.MultiplayerEndpoint)
                  .joinRoom(
                    session,
                    params['code'],
                  ),
        ),
      },
    );
    connectors['profile'] = _is.EndpointConnector(
      name: 'profile',
      endpoint: endpoints['profile']!,
      methodConnectors: {
        'getMyProfile': _is.MethodConnector(
          name: 'getMyProfile',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['profile'] as _i6ky944g.ProfileEndpoint)
                  .getMyProfile(session),
        ),
        'updateUsername': _is.MethodConnector(
          name: 'updateUsername',
          params: {
            'username': _is.ParameterDescription(
              name: 'username',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['profile'] as _i6ky944g.ProfileEndpoint)
                  .updateUsername(
                    session,
                    params['username'],
                  ),
        ),
        'uploadProfilePhoto': _is.MethodConnector(
          name: 'uploadProfilePhoto',
          params: {
            'photo': _is.ParameterDescription(
              name: 'photo',
              type: _is.getType<_idt.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['profile'] as _i6ky944g.ProfileEndpoint)
                  .uploadProfilePhoto(
                    session,
                    params['photo'],
                  ),
        ),
        'removeProfilePhoto': _is.MethodConnector(
          name: 'removeProfilePhoto',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['profile'] as _i6ky944g.ProfileEndpoint)
                  .removeProfilePhoto(session),
        ),
      },
    );
    connectors['ranked'] = _is.EndpointConnector(
      name: 'ranked',
      endpoint: endpoints['ranked']!,
      methodConnectors: {
        'startRanked': _is.MethodConnector(
          name: 'startRanked',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['ranked'] as _iipq9d8b.RankedEndpoint)
                  .startRanked(session),
        ),
      },
    );
    connectors['review'] = _is.EndpointConnector(
      name: 'review',
      endpoint: endpoints['review']!,
      methodConnectors: {
        'explainMove': _is.MethodConnector(
          name: 'explainMove',
          params: {
            'moves': _is.ParameterDescription(
              name: 'moves',
              type: _is.getType<List<int>>(),
              nullable: false,
            ),
            'moveIndex': _is.ParameterDescription(
              name: 'moveIndex',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'language': _is.ParameterDescription(
              name: 'language',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['review'] as _iypg8dvf.ReviewEndpoint).explainMove(
                    session,
                    moves: params['moves'],
                    moveIndex: params['moveIndex'],
                    language: params['language'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_offline_sync'] = _izehhkf5.Endpoints()
      ..initializeEndpoints(server);
  }
}
