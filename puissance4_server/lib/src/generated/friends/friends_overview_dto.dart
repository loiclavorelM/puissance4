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
import 'package:puissance4_server/src/generated/protocol.dart' as _irho11n9;
import 'package:serverpod/serverpod.dart' as _is;
import '../friends/friendship_dto.dart' as _ijdnlokl;

abstract class FriendsOverviewDto
    implements _is.SerializableModel, _is.ProtocolSerialization {
  FriendsOverviewDto._({
    required this.friendCode,
    required this.friends,
    required this.incoming,
    required this.outgoing,
  });

  factory FriendsOverviewDto({
    required String friendCode,
    required List<_ijdnlokl.FriendshipDto> friends,
    required List<_ijdnlokl.FriendshipDto> incoming,
    required List<_ijdnlokl.FriendshipDto> outgoing,
  }) = _FriendsOverviewDtoImpl;

  factory FriendsOverviewDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return FriendsOverviewDto(
      friendCode: jsonSerialization['friendCode'] as String,
      friends: _irho11n9.Protocol().deserialize<List<_ijdnlokl.FriendshipDto>>(
        jsonSerialization['friends'],
      ),
      incoming: _irho11n9.Protocol().deserialize<List<_ijdnlokl.FriendshipDto>>(
        jsonSerialization['incoming'],
      ),
      outgoing: _irho11n9.Protocol().deserialize<List<_ijdnlokl.FriendshipDto>>(
        jsonSerialization['outgoing'],
      ),
    );
  }

  String friendCode;

  List<_ijdnlokl.FriendshipDto> friends;

  List<_ijdnlokl.FriendshipDto> incoming;

  List<_ijdnlokl.FriendshipDto> outgoing;

  /// Returns a shallow copy of this [FriendsOverviewDto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FriendsOverviewDto copyWith({
    String? friendCode,
    List<_ijdnlokl.FriendshipDto>? friends,
    List<_ijdnlokl.FriendshipDto>? incoming,
    List<_ijdnlokl.FriendshipDto>? outgoing,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FriendsOverviewDto',
      'friendCode': friendCode,
      'friends': friends.toJson(valueToJson: (v) => v.toJson()),
      'incoming': incoming.toJson(valueToJson: (v) => v.toJson()),
      'outgoing': outgoing.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FriendsOverviewDto',
      'friendCode': friendCode,
      'friends': friends.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'incoming': incoming.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'outgoing': outgoing.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _FriendsOverviewDtoImpl extends FriendsOverviewDto {
  _FriendsOverviewDtoImpl({
    required String friendCode,
    required List<_ijdnlokl.FriendshipDto> friends,
    required List<_ijdnlokl.FriendshipDto> incoming,
    required List<_ijdnlokl.FriendshipDto> outgoing,
  }) : super._(
         friendCode: friendCode,
         friends: friends,
         incoming: incoming,
         outgoing: outgoing,
       );

  /// Returns a shallow copy of this [FriendsOverviewDto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FriendsOverviewDto copyWith({
    String? friendCode,
    List<_ijdnlokl.FriendshipDto>? friends,
    List<_ijdnlokl.FriendshipDto>? incoming,
    List<_ijdnlokl.FriendshipDto>? outgoing,
  }) {
    return FriendsOverviewDto(
      friendCode: friendCode ?? this.friendCode,
      friends: friends ?? this.friends.map((e0) => e0.copyWith()).toList(),
      incoming: incoming ?? this.incoming.map((e0) => e0.copyWith()).toList(),
      outgoing: outgoing ?? this.outgoing.map((e0) => e0.copyWith()).toList(),
    );
  }
}
