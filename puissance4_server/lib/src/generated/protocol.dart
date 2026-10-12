/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:puissance4_server/src/generated/friends/friend_activity_dto.dart'
    as _io800lu2;
import 'package:puissance4_server/src/generated/friends/friend_challenge_dto.dart'
    as _ifqc6g4v;
import 'package:puissance4_server/src/generated/friends/player_search_result_dto.dart'
    as _i259h1cp;
import 'package:puissance4_server/src/generated/friends/rivalry_dto.dart'
    as _ixwte3qx;
import 'package:puissance4_server/src/generated/history/history_dto.dart'
    as _islja9se;
import 'package:puissance4_server/src/generated/leaderboard/leaderboard_dto.dart'
    as _i5549tex;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'package:serverpod_offline_sync_server/serverpod_offline_sync_server.dart'
    as _izehhkf5;
import 'assistant/assistant_conversation.dart' as _ikd6xdrt;
import 'assistant/assistant_exception.dart' as _ixtf2j4x;
import 'assistant/assistant_message.dart' as _ix3wp1gt;
import 'assistant/assistant_request_log.dart' as _i3uav29g;
import 'assistant/assistant_token.dart' as _ictlaa9l;
import 'assistant/enum_assistant_error.dart' as _itiz3l16;
import 'assistant/enum_dashboard_author.dart' as _iv4kpqf4;
import 'assistant/user_dashboard.dart' as _ieb6zq8b;
import 'assistant/user_dashboard_version.dart' as _if7oging;
import 'bot/bot.dart' as _iij7x2jd;
import 'bot/enum_bot_level.dart' as _i65o1ott;
import 'friends/enum_friend_presence.dart' as _ifm42sdi;
import 'friends/enum_friend_relation.dart' as _it2shy0i;
import 'friends/enum_friends_error.dart' as _if0hp53x;
import 'friends/enum_friendship_status.dart' as _iiv2c9gb;
import 'friends/friend_activity_dto.dart' as _iubkg2x5;
import 'friends/friend_challenge_dto.dart' as _iqz9h2tk;
import 'friends/friend_user_dto.dart' as _in6lw5u5;
import 'friends/friends_exception.dart' as _i9j1nep3;
import 'friends/friends_overview_dto.dart' as _ibsg885b;
import 'friends/friendship.dart' as _ix1l50pg;
import 'friends/friendship_dto.dart' as _if8yjfer;
import 'friends/player_search_result_dto.dart' as _izsp853n;
import 'friends/rivalry_dto.dart' as _iouwl73l;
import 'game/enum_color.dart' as _im0plaxm;
import 'game/enum_game_end_reason.dart' as _ilcsv24h;
import 'game/enum_game_error.dart' as _isw7cqst;
import 'game/enum_game_event_type.dart' as _i5v03mnn;
import 'game/enum_match_result.dart' as _iyr3fkva;
import 'game/enum_outcome.dart' as _imvh44pi;
import 'game/enum_statut.dart' as _ip6diune;
import 'game/enum_type.dart' as _ig2x4mxg;
import 'game/game_event.dart' as _ifqd2v7f;
import 'game/game_exception.dart' as _ij9ms74z;
import 'game/game_player_info.dart' as _idzpkmwn;
import 'game/offline_match_result.dart' as _ir8nzxqr;
import 'game/partie.dart' as _iuas6tq9;
import 'game/player.dart' as _id5q07gg;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'history/history_dto.dart' as _inn2tdi6;
import 'history/replay_dto.dart' as _iwti84ex;
import 'leaderboard/leaderboard_dto.dart' as _i6lckwy9;
import 'live/enum_live_event_type.dart' as _ikanpab0;
import 'live/live_event.dart' as _ixdzvre4;
import 'multiplayer/lobby_room.dart' as _i39mlunu;
import 'multiplayer/lobby_snapshot.dart' as _idvrexla;
import 'profile/enum_profile_update_error.dart' as _ib6s6ke7;
import 'profile/profile_update_exception.dart' as _i1cvnna1;
import 'profile/user.dart' as _iytd8mlf;
import 'profile/user_profile_dto.dart' as _ivqmpbel;
import 'ranked/elo_history.dart' as _i8na2re5;
import 'review/enum_review_error.dart' as _ialq3a2v;
import 'review/move_explanation.dart' as _i0n08bga;
import 'review/review_exception.dart' as _i7k2kt7u;
export 'assistant/assistant_conversation.dart';
export 'assistant/assistant_exception.dart';
export 'assistant/assistant_message.dart';
export 'assistant/assistant_request_log.dart';
export 'assistant/assistant_token.dart';
export 'assistant/enum_assistant_error.dart';
export 'assistant/enum_dashboard_author.dart';
export 'assistant/user_dashboard.dart';
export 'assistant/user_dashboard_version.dart';
export 'bot/bot.dart';
export 'bot/enum_bot_level.dart';
export 'friends/enum_friend_presence.dart';
export 'friends/enum_friend_relation.dart';
export 'friends/enum_friends_error.dart';
export 'friends/enum_friendship_status.dart';
export 'friends/friend_activity_dto.dart';
export 'friends/friend_challenge_dto.dart';
export 'friends/friend_user_dto.dart';
export 'friends/friends_exception.dart';
export 'friends/friends_overview_dto.dart';
export 'friends/friendship.dart';
export 'friends/friendship_dto.dart';
export 'friends/player_search_result_dto.dart';
export 'friends/rivalry_dto.dart';
export 'game/enum_color.dart';
export 'game/enum_game_end_reason.dart';
export 'game/enum_game_error.dart';
export 'game/enum_game_event_type.dart';
export 'game/enum_match_result.dart';
export 'game/enum_outcome.dart';
export 'game/enum_statut.dart';
export 'game/enum_type.dart';
export 'game/game_event.dart';
export 'game/game_exception.dart';
export 'game/game_player_info.dart';
export 'game/offline_match_result.dart';
export 'game/partie.dart';
export 'game/player.dart';
export 'greetings/greeting.dart';
export 'history/history_dto.dart';
export 'history/replay_dto.dart';
export 'leaderboard/leaderboard_dto.dart';
export 'live/enum_live_event_type.dart';
export 'live/live_event.dart';
export 'multiplayer/lobby_room.dart';
export 'multiplayer/lobby_snapshot.dart';
export 'profile/enum_profile_update_error.dart';
export 'profile/profile_update_exception.dart';
export 'profile/user.dart';
export 'profile/user_profile_dto.dart';
export 'ranked/elo_history.dart';
export 'review/enum_review_error.dart';
export 'review/move_explanation.dart';
export 'review/review_exception.dart';
export 'sync_tables.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'assistant_conversation',
      dartName: 'AssistantConversation',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'assistant_conversation_fk_0',
          columns: ['userId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'assistant_conversation_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'updatedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'assistant_message',
      dartName: 'AssistantMessage',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'conversationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'position',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'contentJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'assistant_message_fk_0',
          columns: ['conversationId'],
          referenceTable: 'assistant_conversation',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'assistant_message_position_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'conversationId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'position',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'assistant_request_log',
      dartName: 'AssistantRequestLog',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'conversationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'model',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'inputTokens',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'outputTokens',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'toolsJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'turns',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'durationMs',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'errorCode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'assistant_request_log_fk_0',
          columns: ['userId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'assistant_request_log_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'assistant_token',
      dartName: 'AssistantToken',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'conversationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'token',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'ref',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'assistant_token_fk_0',
          columns: ['conversationId'],
          referenceTable: 'assistant_conversation',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'assistant_token_token_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'conversationId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'token',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'assistant_token_ref_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'conversationId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ref',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'bot',
      dartName: 'Bot',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'botName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'elo',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'pathModel',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'elo_history',
      dartName: 'EloHistory',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'partieId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'eloVariation',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'newElo',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'elo_history_fk_0',
          columns: ['userId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'elo_history_fk_1',
          columns: ['partieId'],
          referenceTable: 'partie',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'friendship',
      dartName: 'Friendship',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'requesterId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'addresseeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'pairKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EnumFriendshipStatus',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'respondedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'friendship_fk_0',
          columns: ['requesterId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'friendship_fk_1',
          columns: ['addresseeId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'friendship_pair_key_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'pairKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'friendship_requester_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'requesterId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'friendship_addressee_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'addresseeId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'move_explanation',
      dartName: 'MoveExplanation',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'positionKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'language',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'explanation',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'model',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'requestedBy',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'move_explanation_position_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'positionKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'language',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'move_explanation_requester_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'requestedBy',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'offline_match_result',
      dartName: 'OfflineMatchResult',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'spaceId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EnumStatut',
        ),
        _isp.ColumnDefinition(
          name: 'result',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:EnumMatchResult?',
        ),
        _isp.ColumnDefinition(
          name: 'botId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'botName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'playedAs',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EnumColor',
        ),
        _isp.ColumnDefinition(
          name: 'moves',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<int>',
        ),
        _isp.ColumnDefinition(
          name: 'playedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'reconciled',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'offline_match_result_fk_0',
          columns: ['spaceId'],
          referenceTable: 'offline_sync_spaces',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'partie',
      dartName: 'Partie',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'code',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'typePartie',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EnumType',
        ),
        _isp.ColumnDefinition(
          name: 'playerRougeId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'playerJauneId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'winner',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:EnumOutcome?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EnumStatut',
        ),
        _isp.ColumnDefinition(
          name: 'moves',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<int>',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'rougeConnectionId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'rougeDisconnectedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'jauneConnectionId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'jauneDisconnectedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'endReason',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:EnumGameEndReason?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'partie_fk_0',
          columns: ['playerRougeId'],
          referenceTable: 'player',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'partie_fk_1',
          columns: ['playerJauneId'],
          referenceTable: 'player',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'player',
      dartName: 'Player',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'botId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'player_fk_0',
          columns: ['botId'],
          referenceTable: 'bot',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'player_fk_1',
          columns: ['userId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'user',
      dartName: 'User',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'username',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'thumbnailPath',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'elo',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1000',
        ),
        _isp.ColumnDefinition(
          name: 'friendCode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'lastSeenAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'user_fk_0',
          columns: ['authUserId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'user_auth_user_id_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'user_friend_code_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'friendCode',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'user_username_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'username',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'user_dashboard',
      dartName: 'UserDashboard',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'definitionJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'user_dashboard_fk_0',
          columns: ['userId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'user_dashboard_user_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'user_dashboard_version',
      dartName: 'UserDashboardVersion',
      schema: 'public',
      module: 'puissance4',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'dashboardId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'definitionJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'author',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:EnumDashboardAuthor',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'user_dashboard_version_fk_0',
          columns: ['dashboardId'],
          referenceTable: 'user_dashboard',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'user_dashboard_version_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'dashboardId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'version',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iacs.Protocol.targetTableDefinitions,
    ..._iais.Protocol.targetTableDefinitions,
    ..._izehhkf5.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _ikd6xdrt.AssistantConversation) {
      return _ikd6xdrt.AssistantConversation.fromJson(data) as T;
    }
    if (t == _ixtf2j4x.AssistantException) {
      return _ixtf2j4x.AssistantException.fromJson(data) as T;
    }
    if (t == _ix3wp1gt.AssistantMessage) {
      return _ix3wp1gt.AssistantMessage.fromJson(data) as T;
    }
    if (t == _i3uav29g.AssistantRequestLog) {
      return _i3uav29g.AssistantRequestLog.fromJson(data) as T;
    }
    if (t == _ictlaa9l.AssistantToken) {
      return _ictlaa9l.AssistantToken.fromJson(data) as T;
    }
    if (t == _itiz3l16.EnumAssistantError) {
      return _itiz3l16.EnumAssistantError.fromJson(data) as T;
    }
    if (t == _iv4kpqf4.EnumDashboardAuthor) {
      return _iv4kpqf4.EnumDashboardAuthor.fromJson(data) as T;
    }
    if (t == _ieb6zq8b.UserDashboard) {
      return _ieb6zq8b.UserDashboard.fromJson(data) as T;
    }
    if (t == _if7oging.UserDashboardVersion) {
      return _if7oging.UserDashboardVersion.fromJson(data) as T;
    }
    if (t == _iij7x2jd.Bot) {
      return _iij7x2jd.Bot.fromJson(data) as T;
    }
    if (t == _i65o1ott.EnumBotLevel) {
      return _i65o1ott.EnumBotLevel.fromJson(data) as T;
    }
    if (t == _ifm42sdi.EnumFriendPresence) {
      return _ifm42sdi.EnumFriendPresence.fromJson(data) as T;
    }
    if (t == _it2shy0i.EnumFriendRelation) {
      return _it2shy0i.EnumFriendRelation.fromJson(data) as T;
    }
    if (t == _if0hp53x.EnumFriendsError) {
      return _if0hp53x.EnumFriendsError.fromJson(data) as T;
    }
    if (t == _iiv2c9gb.EnumFriendshipStatus) {
      return _iiv2c9gb.EnumFriendshipStatus.fromJson(data) as T;
    }
    if (t == _iubkg2x5.FriendActivityDto) {
      return _iubkg2x5.FriendActivityDto.fromJson(data) as T;
    }
    if (t == _iqz9h2tk.FriendChallengeDto) {
      return _iqz9h2tk.FriendChallengeDto.fromJson(data) as T;
    }
    if (t == _in6lw5u5.FriendUserDto) {
      return _in6lw5u5.FriendUserDto.fromJson(data) as T;
    }
    if (t == _i9j1nep3.FriendsException) {
      return _i9j1nep3.FriendsException.fromJson(data) as T;
    }
    if (t == _ibsg885b.FriendsOverviewDto) {
      return _ibsg885b.FriendsOverviewDto.fromJson(data) as T;
    }
    if (t == _ix1l50pg.Friendship) {
      return _ix1l50pg.Friendship.fromJson(data) as T;
    }
    if (t == _if8yjfer.FriendshipDto) {
      return _if8yjfer.FriendshipDto.fromJson(data) as T;
    }
    if (t == _izsp853n.PlayerSearchResultDto) {
      return _izsp853n.PlayerSearchResultDto.fromJson(data) as T;
    }
    if (t == _iouwl73l.RivalryDto) {
      return _iouwl73l.RivalryDto.fromJson(data) as T;
    }
    if (t == _im0plaxm.EnumColor) {
      return _im0plaxm.EnumColor.fromJson(data) as T;
    }
    if (t == _ilcsv24h.EnumGameEndReason) {
      return _ilcsv24h.EnumGameEndReason.fromJson(data) as T;
    }
    if (t == _isw7cqst.EnumGameError) {
      return _isw7cqst.EnumGameError.fromJson(data) as T;
    }
    if (t == _i5v03mnn.EnumGameEventType) {
      return _i5v03mnn.EnumGameEventType.fromJson(data) as T;
    }
    if (t == _iyr3fkva.EnumMatchResult) {
      return _iyr3fkva.EnumMatchResult.fromJson(data) as T;
    }
    if (t == _imvh44pi.EnumOutcome) {
      return _imvh44pi.EnumOutcome.fromJson(data) as T;
    }
    if (t == _ip6diune.EnumStatut) {
      return _ip6diune.EnumStatut.fromJson(data) as T;
    }
    if (t == _ig2x4mxg.EnumType) {
      return _ig2x4mxg.EnumType.fromJson(data) as T;
    }
    if (t == _ifqd2v7f.GameEvent) {
      return _ifqd2v7f.GameEvent.fromJson(data) as T;
    }
    if (t == _ij9ms74z.GameException) {
      return _ij9ms74z.GameException.fromJson(data) as T;
    }
    if (t == _idzpkmwn.GamePlayerInfo) {
      return _idzpkmwn.GamePlayerInfo.fromJson(data) as T;
    }
    if (t == _ir8nzxqr.OfflineMatchResult) {
      return _ir8nzxqr.OfflineMatchResult.fromJson(data) as T;
    }
    if (t == _iuas6tq9.Partie) {
      return _iuas6tq9.Partie.fromJson(data) as T;
    }
    if (t == _id5q07gg.Player) {
      return _id5q07gg.Player.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _inn2tdi6.HistoryDto) {
      return _inn2tdi6.HistoryDto.fromJson(data) as T;
    }
    if (t == _iwti84ex.ReplayDto) {
      return _iwti84ex.ReplayDto.fromJson(data) as T;
    }
    if (t == _i6lckwy9.LeaderboardEntryDto) {
      return _i6lckwy9.LeaderboardEntryDto.fromJson(data) as T;
    }
    if (t == _ikanpab0.EnumLiveEventType) {
      return _ikanpab0.EnumLiveEventType.fromJson(data) as T;
    }
    if (t == _ixdzvre4.LiveEvent) {
      return _ixdzvre4.LiveEvent.fromJson(data) as T;
    }
    if (t == _i39mlunu.LobbyRoom) {
      return _i39mlunu.LobbyRoom.fromJson(data) as T;
    }
    if (t == _idvrexla.LobbySnapshot) {
      return _idvrexla.LobbySnapshot.fromJson(data) as T;
    }
    if (t == _ib6s6ke7.EnumProfileUpdateError) {
      return _ib6s6ke7.EnumProfileUpdateError.fromJson(data) as T;
    }
    if (t == _i1cvnna1.ProfileUpdateException) {
      return _i1cvnna1.ProfileUpdateException.fromJson(data) as T;
    }
    if (t == _iytd8mlf.User) {
      return _iytd8mlf.User.fromJson(data) as T;
    }
    if (t == _ivqmpbel.UserProfileDto) {
      return _ivqmpbel.UserProfileDto.fromJson(data) as T;
    }
    if (t == _i8na2re5.EloHistory) {
      return _i8na2re5.EloHistory.fromJson(data) as T;
    }
    if (t == _ialq3a2v.EnumReviewError) {
      return _ialq3a2v.EnumReviewError.fromJson(data) as T;
    }
    if (t == _i0n08bga.MoveExplanation) {
      return _i0n08bga.MoveExplanation.fromJson(data) as T;
    }
    if (t == _i7k2kt7u.ReviewException) {
      return _i7k2kt7u.ReviewException.fromJson(data) as T;
    }
    if (t == _is.getType<_ikd6xdrt.AssistantConversation?>()) {
      return (data != null
              ? _ikd6xdrt.AssistantConversation.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ixtf2j4x.AssistantException?>()) {
      return (data != null ? _ixtf2j4x.AssistantException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ix3wp1gt.AssistantMessage?>()) {
      return (data != null ? _ix3wp1gt.AssistantMessage.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i3uav29g.AssistantRequestLog?>()) {
      return (data != null
              ? _i3uav29g.AssistantRequestLog.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ictlaa9l.AssistantToken?>()) {
      return (data != null ? _ictlaa9l.AssistantToken.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_itiz3l16.EnumAssistantError?>()) {
      return (data != null ? _itiz3l16.EnumAssistantError.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iv4kpqf4.EnumDashboardAuthor?>()) {
      return (data != null
              ? _iv4kpqf4.EnumDashboardAuthor.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ieb6zq8b.UserDashboard?>()) {
      return (data != null ? _ieb6zq8b.UserDashboard.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_if7oging.UserDashboardVersion?>()) {
      return (data != null
              ? _if7oging.UserDashboardVersion.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iij7x2jd.Bot?>()) {
      return (data != null ? _iij7x2jd.Bot.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i65o1ott.EnumBotLevel?>()) {
      return (data != null ? _i65o1ott.EnumBotLevel.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ifm42sdi.EnumFriendPresence?>()) {
      return (data != null ? _ifm42sdi.EnumFriendPresence.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_it2shy0i.EnumFriendRelation?>()) {
      return (data != null ? _it2shy0i.EnumFriendRelation.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_if0hp53x.EnumFriendsError?>()) {
      return (data != null ? _if0hp53x.EnumFriendsError.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iiv2c9gb.EnumFriendshipStatus?>()) {
      return (data != null
              ? _iiv2c9gb.EnumFriendshipStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iubkg2x5.FriendActivityDto?>()) {
      return (data != null ? _iubkg2x5.FriendActivityDto.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iqz9h2tk.FriendChallengeDto?>()) {
      return (data != null ? _iqz9h2tk.FriendChallengeDto.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_in6lw5u5.FriendUserDto?>()) {
      return (data != null ? _in6lw5u5.FriendUserDto.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i9j1nep3.FriendsException?>()) {
      return (data != null ? _i9j1nep3.FriendsException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ibsg885b.FriendsOverviewDto?>()) {
      return (data != null ? _ibsg885b.FriendsOverviewDto.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ix1l50pg.Friendship?>()) {
      return (data != null ? _ix1l50pg.Friendship.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_if8yjfer.FriendshipDto?>()) {
      return (data != null ? _if8yjfer.FriendshipDto.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izsp853n.PlayerSearchResultDto?>()) {
      return (data != null
              ? _izsp853n.PlayerSearchResultDto.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iouwl73l.RivalryDto?>()) {
      return (data != null ? _iouwl73l.RivalryDto.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_im0plaxm.EnumColor?>()) {
      return (data != null ? _im0plaxm.EnumColor.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ilcsv24h.EnumGameEndReason?>()) {
      return (data != null ? _ilcsv24h.EnumGameEndReason.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_isw7cqst.EnumGameError?>()) {
      return (data != null ? _isw7cqst.EnumGameError.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i5v03mnn.EnumGameEventType?>()) {
      return (data != null ? _i5v03mnn.EnumGameEventType.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iyr3fkva.EnumMatchResult?>()) {
      return (data != null ? _iyr3fkva.EnumMatchResult.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_imvh44pi.EnumOutcome?>()) {
      return (data != null ? _imvh44pi.EnumOutcome.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ip6diune.EnumStatut?>()) {
      return (data != null ? _ip6diune.EnumStatut.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ig2x4mxg.EnumType?>()) {
      return (data != null ? _ig2x4mxg.EnumType.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ifqd2v7f.GameEvent?>()) {
      return (data != null ? _ifqd2v7f.GameEvent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ij9ms74z.GameException?>()) {
      return (data != null ? _ij9ms74z.GameException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_idzpkmwn.GamePlayerInfo?>()) {
      return (data != null ? _idzpkmwn.GamePlayerInfo.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ir8nzxqr.OfflineMatchResult?>()) {
      return (data != null ? _ir8nzxqr.OfflineMatchResult.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iuas6tq9.Partie?>()) {
      return (data != null ? _iuas6tq9.Partie.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_id5q07gg.Player?>()) {
      return (data != null ? _id5q07gg.Player.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_inn2tdi6.HistoryDto?>()) {
      return (data != null ? _inn2tdi6.HistoryDto.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iwti84ex.ReplayDto?>()) {
      return (data != null ? _iwti84ex.ReplayDto.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i6lckwy9.LeaderboardEntryDto?>()) {
      return (data != null
              ? _i6lckwy9.LeaderboardEntryDto.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ikanpab0.EnumLiveEventType?>()) {
      return (data != null ? _ikanpab0.EnumLiveEventType.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ixdzvre4.LiveEvent?>()) {
      return (data != null ? _ixdzvre4.LiveEvent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i39mlunu.LobbyRoom?>()) {
      return (data != null ? _i39mlunu.LobbyRoom.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_idvrexla.LobbySnapshot?>()) {
      return (data != null ? _idvrexla.LobbySnapshot.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ib6s6ke7.EnumProfileUpdateError?>()) {
      return (data != null
              ? _ib6s6ke7.EnumProfileUpdateError.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i1cvnna1.ProfileUpdateException?>()) {
      return (data != null
              ? _i1cvnna1.ProfileUpdateException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iytd8mlf.User?>()) {
      return (data != null ? _iytd8mlf.User.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ivqmpbel.UserProfileDto?>()) {
      return (data != null ? _ivqmpbel.UserProfileDto.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i8na2re5.EloHistory?>()) {
      return (data != null ? _i8na2re5.EloHistory.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ialq3a2v.EnumReviewError?>()) {
      return (data != null ? _ialq3a2v.EnumReviewError.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i0n08bga.MoveExplanation?>()) {
      return (data != null ? _i0n08bga.MoveExplanation.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i7k2kt7u.ReviewException?>()) {
      return (data != null ? _i7k2kt7u.ReviewException.fromJson(data) : null)
          as T;
    }
    if (t == List<_if8yjfer.FriendshipDto>) {
      return (data as List)
              .map((e) => deserialize<_if8yjfer.FriendshipDto>(e))
              .toList()
          as T;
    }
    if (t == List<_is.UuidValue>) {
      return (data as List).map((e) => deserialize<_is.UuidValue>(e)).toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == _is.getType<List<int>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<int>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i39mlunu.LobbyRoom>) {
      return (data as List)
              .map((e) => deserialize<_i39mlunu.LobbyRoom>(e))
              .toList()
          as T;
    }
    if (t == List<_i259h1cp.PlayerSearchResultDto>) {
      return (data as List)
              .map((e) => deserialize<_i259h1cp.PlayerSearchResultDto>(e))
              .toList()
          as T;
    }
    if (t == List<_ixwte3qx.RivalryDto>) {
      return (data as List)
              .map((e) => deserialize<_ixwte3qx.RivalryDto>(e))
              .toList()
          as T;
    }
    if (t == List<_io800lu2.FriendActivityDto>) {
      return (data as List)
              .map((e) => deserialize<_io800lu2.FriendActivityDto>(e))
              .toList()
          as T;
    }
    if (t == List<_ifqc6g4v.FriendChallengeDto>) {
      return (data as List)
              .map((e) => deserialize<_ifqc6g4v.FriendChallengeDto>(e))
              .toList()
          as T;
    }
    if (t == List<_islja9se.HistoryDto>) {
      return (data as List)
              .map((e) => deserialize<_islja9se.HistoryDto>(e))
              .toList()
          as T;
    }
    if (t == List<_i5549tex.LeaderboardEntryDto>) {
      return (data as List)
              .map((e) => deserialize<_i5549tex.LeaderboardEntryDto>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _izehhkf5.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _ikd6xdrt.AssistantConversation => 'AssistantConversation',
      _ixtf2j4x.AssistantException => 'AssistantException',
      _ix3wp1gt.AssistantMessage => 'AssistantMessage',
      _i3uav29g.AssistantRequestLog => 'AssistantRequestLog',
      _ictlaa9l.AssistantToken => 'AssistantToken',
      _itiz3l16.EnumAssistantError => 'EnumAssistantError',
      _iv4kpqf4.EnumDashboardAuthor => 'EnumDashboardAuthor',
      _ieb6zq8b.UserDashboard => 'UserDashboard',
      _if7oging.UserDashboardVersion => 'UserDashboardVersion',
      _iij7x2jd.Bot => 'Bot',
      _i65o1ott.EnumBotLevel => 'EnumBotLevel',
      _ifm42sdi.EnumFriendPresence => 'EnumFriendPresence',
      _it2shy0i.EnumFriendRelation => 'EnumFriendRelation',
      _if0hp53x.EnumFriendsError => 'EnumFriendsError',
      _iiv2c9gb.EnumFriendshipStatus => 'EnumFriendshipStatus',
      _iubkg2x5.FriendActivityDto => 'FriendActivityDto',
      _iqz9h2tk.FriendChallengeDto => 'FriendChallengeDto',
      _in6lw5u5.FriendUserDto => 'FriendUserDto',
      _i9j1nep3.FriendsException => 'FriendsException',
      _ibsg885b.FriendsOverviewDto => 'FriendsOverviewDto',
      _ix1l50pg.Friendship => 'Friendship',
      _if8yjfer.FriendshipDto => 'FriendshipDto',
      _izsp853n.PlayerSearchResultDto => 'PlayerSearchResultDto',
      _iouwl73l.RivalryDto => 'RivalryDto',
      _im0plaxm.EnumColor => 'EnumColor',
      _ilcsv24h.EnumGameEndReason => 'EnumGameEndReason',
      _isw7cqst.EnumGameError => 'EnumGameError',
      _i5v03mnn.EnumGameEventType => 'EnumGameEventType',
      _iyr3fkva.EnumMatchResult => 'EnumMatchResult',
      _imvh44pi.EnumOutcome => 'EnumOutcome',
      _ip6diune.EnumStatut => 'EnumStatut',
      _ig2x4mxg.EnumType => 'EnumType',
      _ifqd2v7f.GameEvent => 'GameEvent',
      _ij9ms74z.GameException => 'GameException',
      _idzpkmwn.GamePlayerInfo => 'GamePlayerInfo',
      _ir8nzxqr.OfflineMatchResult => 'OfflineMatchResult',
      _iuas6tq9.Partie => 'Partie',
      _id5q07gg.Player => 'Player',
      _izw8z7ou.Greeting => 'Greeting',
      _inn2tdi6.HistoryDto => 'HistoryDto',
      _iwti84ex.ReplayDto => 'ReplayDto',
      _i6lckwy9.LeaderboardEntryDto => 'LeaderboardEntryDto',
      _ikanpab0.EnumLiveEventType => 'EnumLiveEventType',
      _ixdzvre4.LiveEvent => 'LiveEvent',
      _i39mlunu.LobbyRoom => 'LobbyRoom',
      _idvrexla.LobbySnapshot => 'LobbySnapshot',
      _ib6s6ke7.EnumProfileUpdateError => 'EnumProfileUpdateError',
      _i1cvnna1.ProfileUpdateException => 'ProfileUpdateException',
      _iytd8mlf.User => 'User',
      _ivqmpbel.UserProfileDto => 'UserProfileDto',
      _i8na2re5.EloHistory => 'EloHistory',
      _ialq3a2v.EnumReviewError => 'EnumReviewError',
      _i0n08bga.MoveExplanation => 'MoveExplanation',
      _i7k2kt7u.ReviewException => 'ReviewException',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('puissance4.', '');
    }

    switch (data) {
      case _ikd6xdrt.AssistantConversation():
        return 'AssistantConversation';
      case _ixtf2j4x.AssistantException():
        return 'AssistantException';
      case _ix3wp1gt.AssistantMessage():
        return 'AssistantMessage';
      case _i3uav29g.AssistantRequestLog():
        return 'AssistantRequestLog';
      case _ictlaa9l.AssistantToken():
        return 'AssistantToken';
      case _itiz3l16.EnumAssistantError():
        return 'EnumAssistantError';
      case _iv4kpqf4.EnumDashboardAuthor():
        return 'EnumDashboardAuthor';
      case _ieb6zq8b.UserDashboard():
        return 'UserDashboard';
      case _if7oging.UserDashboardVersion():
        return 'UserDashboardVersion';
      case _iij7x2jd.Bot():
        return 'Bot';
      case _i65o1ott.EnumBotLevel():
        return 'EnumBotLevel';
      case _ifm42sdi.EnumFriendPresence():
        return 'EnumFriendPresence';
      case _it2shy0i.EnumFriendRelation():
        return 'EnumFriendRelation';
      case _if0hp53x.EnumFriendsError():
        return 'EnumFriendsError';
      case _iiv2c9gb.EnumFriendshipStatus():
        return 'EnumFriendshipStatus';
      case _iubkg2x5.FriendActivityDto():
        return 'FriendActivityDto';
      case _iqz9h2tk.FriendChallengeDto():
        return 'FriendChallengeDto';
      case _in6lw5u5.FriendUserDto():
        return 'FriendUserDto';
      case _i9j1nep3.FriendsException():
        return 'FriendsException';
      case _ibsg885b.FriendsOverviewDto():
        return 'FriendsOverviewDto';
      case _ix1l50pg.Friendship():
        return 'Friendship';
      case _if8yjfer.FriendshipDto():
        return 'FriendshipDto';
      case _izsp853n.PlayerSearchResultDto():
        return 'PlayerSearchResultDto';
      case _iouwl73l.RivalryDto():
        return 'RivalryDto';
      case _im0plaxm.EnumColor():
        return 'EnumColor';
      case _ilcsv24h.EnumGameEndReason():
        return 'EnumGameEndReason';
      case _isw7cqst.EnumGameError():
        return 'EnumGameError';
      case _i5v03mnn.EnumGameEventType():
        return 'EnumGameEventType';
      case _iyr3fkva.EnumMatchResult():
        return 'EnumMatchResult';
      case _imvh44pi.EnumOutcome():
        return 'EnumOutcome';
      case _ip6diune.EnumStatut():
        return 'EnumStatut';
      case _ig2x4mxg.EnumType():
        return 'EnumType';
      case _ifqd2v7f.GameEvent():
        return 'GameEvent';
      case _ij9ms74z.GameException():
        return 'GameException';
      case _idzpkmwn.GamePlayerInfo():
        return 'GamePlayerInfo';
      case _ir8nzxqr.OfflineMatchResult():
        return 'OfflineMatchResult';
      case _iuas6tq9.Partie():
        return 'Partie';
      case _id5q07gg.Player():
        return 'Player';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _inn2tdi6.HistoryDto():
        return 'HistoryDto';
      case _iwti84ex.ReplayDto():
        return 'ReplayDto';
      case _i6lckwy9.LeaderboardEntryDto():
        return 'LeaderboardEntryDto';
      case _ikanpab0.EnumLiveEventType():
        return 'EnumLiveEventType';
      case _ixdzvre4.LiveEvent():
        return 'LiveEvent';
      case _i39mlunu.LobbyRoom():
        return 'LobbyRoom';
      case _idvrexla.LobbySnapshot():
        return 'LobbySnapshot';
      case _ib6s6ke7.EnumProfileUpdateError():
        return 'EnumProfileUpdateError';
      case _i1cvnna1.ProfileUpdateException():
        return 'ProfileUpdateException';
      case _iytd8mlf.User():
        return 'User';
      case _ivqmpbel.UserProfileDto():
        return 'UserProfileDto';
      case _i8na2re5.EloHistory():
        return 'EloHistory';
      case _ialq3a2v.EnumReviewError():
        return 'EnumReviewError';
      case _i0n08bga.MoveExplanation():
        return 'MoveExplanation';
      case _i7k2kt7u.ReviewException():
        return 'ReviewException';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _izehhkf5.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_offline_sync.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AssistantConversation') {
      return deserialize<_ikd6xdrt.AssistantConversation>(data['data']);
    }
    if (dataClassName == 'AssistantException') {
      return deserialize<_ixtf2j4x.AssistantException>(data['data']);
    }
    if (dataClassName == 'AssistantMessage') {
      return deserialize<_ix3wp1gt.AssistantMessage>(data['data']);
    }
    if (dataClassName == 'AssistantRequestLog') {
      return deserialize<_i3uav29g.AssistantRequestLog>(data['data']);
    }
    if (dataClassName == 'AssistantToken') {
      return deserialize<_ictlaa9l.AssistantToken>(data['data']);
    }
    if (dataClassName == 'EnumAssistantError') {
      return deserialize<_itiz3l16.EnumAssistantError>(data['data']);
    }
    if (dataClassName == 'EnumDashboardAuthor') {
      return deserialize<_iv4kpqf4.EnumDashboardAuthor>(data['data']);
    }
    if (dataClassName == 'UserDashboard') {
      return deserialize<_ieb6zq8b.UserDashboard>(data['data']);
    }
    if (dataClassName == 'UserDashboardVersion') {
      return deserialize<_if7oging.UserDashboardVersion>(data['data']);
    }
    if (dataClassName == 'Bot') {
      return deserialize<_iij7x2jd.Bot>(data['data']);
    }
    if (dataClassName == 'EnumBotLevel') {
      return deserialize<_i65o1ott.EnumBotLevel>(data['data']);
    }
    if (dataClassName == 'EnumFriendPresence') {
      return deserialize<_ifm42sdi.EnumFriendPresence>(data['data']);
    }
    if (dataClassName == 'EnumFriendRelation') {
      return deserialize<_it2shy0i.EnumFriendRelation>(data['data']);
    }
    if (dataClassName == 'EnumFriendsError') {
      return deserialize<_if0hp53x.EnumFriendsError>(data['data']);
    }
    if (dataClassName == 'EnumFriendshipStatus') {
      return deserialize<_iiv2c9gb.EnumFriendshipStatus>(data['data']);
    }
    if (dataClassName == 'FriendActivityDto') {
      return deserialize<_iubkg2x5.FriendActivityDto>(data['data']);
    }
    if (dataClassName == 'FriendChallengeDto') {
      return deserialize<_iqz9h2tk.FriendChallengeDto>(data['data']);
    }
    if (dataClassName == 'FriendUserDto') {
      return deserialize<_in6lw5u5.FriendUserDto>(data['data']);
    }
    if (dataClassName == 'FriendsException') {
      return deserialize<_i9j1nep3.FriendsException>(data['data']);
    }
    if (dataClassName == 'FriendsOverviewDto') {
      return deserialize<_ibsg885b.FriendsOverviewDto>(data['data']);
    }
    if (dataClassName == 'Friendship') {
      return deserialize<_ix1l50pg.Friendship>(data['data']);
    }
    if (dataClassName == 'FriendshipDto') {
      return deserialize<_if8yjfer.FriendshipDto>(data['data']);
    }
    if (dataClassName == 'PlayerSearchResultDto') {
      return deserialize<_izsp853n.PlayerSearchResultDto>(data['data']);
    }
    if (dataClassName == 'RivalryDto') {
      return deserialize<_iouwl73l.RivalryDto>(data['data']);
    }
    if (dataClassName == 'EnumColor') {
      return deserialize<_im0plaxm.EnumColor>(data['data']);
    }
    if (dataClassName == 'EnumGameEndReason') {
      return deserialize<_ilcsv24h.EnumGameEndReason>(data['data']);
    }
    if (dataClassName == 'EnumGameError') {
      return deserialize<_isw7cqst.EnumGameError>(data['data']);
    }
    if (dataClassName == 'EnumGameEventType') {
      return deserialize<_i5v03mnn.EnumGameEventType>(data['data']);
    }
    if (dataClassName == 'EnumMatchResult') {
      return deserialize<_iyr3fkva.EnumMatchResult>(data['data']);
    }
    if (dataClassName == 'EnumOutcome') {
      return deserialize<_imvh44pi.EnumOutcome>(data['data']);
    }
    if (dataClassName == 'EnumStatut') {
      return deserialize<_ip6diune.EnumStatut>(data['data']);
    }
    if (dataClassName == 'EnumType') {
      return deserialize<_ig2x4mxg.EnumType>(data['data']);
    }
    if (dataClassName == 'GameEvent') {
      return deserialize<_ifqd2v7f.GameEvent>(data['data']);
    }
    if (dataClassName == 'GameException') {
      return deserialize<_ij9ms74z.GameException>(data['data']);
    }
    if (dataClassName == 'GamePlayerInfo') {
      return deserialize<_idzpkmwn.GamePlayerInfo>(data['data']);
    }
    if (dataClassName == 'OfflineMatchResult') {
      return deserialize<_ir8nzxqr.OfflineMatchResult>(data['data']);
    }
    if (dataClassName == 'Partie') {
      return deserialize<_iuas6tq9.Partie>(data['data']);
    }
    if (dataClassName == 'Player') {
      return deserialize<_id5q07gg.Player>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'HistoryDto') {
      return deserialize<_inn2tdi6.HistoryDto>(data['data']);
    }
    if (dataClassName == 'ReplayDto') {
      return deserialize<_iwti84ex.ReplayDto>(data['data']);
    }
    if (dataClassName == 'LeaderboardEntryDto') {
      return deserialize<_i6lckwy9.LeaderboardEntryDto>(data['data']);
    }
    if (dataClassName == 'EnumLiveEventType') {
      return deserialize<_ikanpab0.EnumLiveEventType>(data['data']);
    }
    if (dataClassName == 'LiveEvent') {
      return deserialize<_ixdzvre4.LiveEvent>(data['data']);
    }
    if (dataClassName == 'LobbyRoom') {
      return deserialize<_i39mlunu.LobbyRoom>(data['data']);
    }
    if (dataClassName == 'LobbySnapshot') {
      return deserialize<_idvrexla.LobbySnapshot>(data['data']);
    }
    if (dataClassName == 'EnumProfileUpdateError') {
      return deserialize<_ib6s6ke7.EnumProfileUpdateError>(data['data']);
    }
    if (dataClassName == 'ProfileUpdateException') {
      return deserialize<_i1cvnna1.ProfileUpdateException>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_iytd8mlf.User>(data['data']);
    }
    if (dataClassName == 'UserProfileDto') {
      return deserialize<_ivqmpbel.UserProfileDto>(data['data']);
    }
    if (dataClassName == 'EloHistory') {
      return deserialize<_i8na2re5.EloHistory>(data['data']);
    }
    if (dataClassName == 'EnumReviewError') {
      return deserialize<_ialq3a2v.EnumReviewError>(data['data']);
    }
    if (dataClassName == 'MoveExplanation') {
      return deserialize<_i0n08bga.MoveExplanation>(data['data']);
    }
    if (dataClassName == 'ReviewException') {
      return deserialize<_i7k2kt7u.ReviewException>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_offline_sync.')) {
      data['className'] = dataClassName.substring(23);
      return _izehhkf5.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iacs.Protocol().registerHostProtocol('puissance4', this);
    _iais.Protocol().registerHostProtocol('puissance4', this);
    _izehhkf5.Protocol().registerHostProtocol('puissance4', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _izehhkf5.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _ikd6xdrt.AssistantConversation:
        return _ikd6xdrt.AssistantConversation.t;
      case _ix3wp1gt.AssistantMessage:
        return _ix3wp1gt.AssistantMessage.t;
      case _i3uav29g.AssistantRequestLog:
        return _i3uav29g.AssistantRequestLog.t;
      case _ictlaa9l.AssistantToken:
        return _ictlaa9l.AssistantToken.t;
      case _ieb6zq8b.UserDashboard:
        return _ieb6zq8b.UserDashboard.t;
      case _if7oging.UserDashboardVersion:
        return _if7oging.UserDashboardVersion.t;
      case _iij7x2jd.Bot:
        return _iij7x2jd.Bot.t;
      case _ix1l50pg.Friendship:
        return _ix1l50pg.Friendship.t;
      case _ir8nzxqr.OfflineMatchResult:
        return _ir8nzxqr.OfflineMatchResult.t;
      case _iuas6tq9.Partie:
        return _iuas6tq9.Partie.t;
      case _id5q07gg.Player:
        return _id5q07gg.Player.t;
      case _iytd8mlf.User:
        return _iytd8mlf.User.t;
      case _i8na2re5.EloHistory:
        return _i8na2re5.EloHistory.t;
      case _i0n08bga.MoveExplanation:
        return _i0n08bga.MoveExplanation.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'puissance4';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _izehhkf5.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
