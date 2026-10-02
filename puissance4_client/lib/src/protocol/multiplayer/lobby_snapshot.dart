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
import 'package:puissance4_client/src/protocol/protocol.dart' as _ixdd0t97;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../multiplayer/lobby_room.dart' as _i8of5w5h;

abstract class LobbySnapshot
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  LobbySnapshot._({required this.rooms});

  factory LobbySnapshot({required List<_i8of5w5h.LobbyRoom> rooms}) =
      _LobbySnapshotImpl;

  factory LobbySnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return LobbySnapshot(
      rooms: _ixdd0t97.Protocol().deserialize<List<_i8of5w5h.LobbyRoom>>(
        jsonSerialization['rooms'],
      ),
    );
  }

  List<_i8of5w5h.LobbyRoom> rooms;

  /// Returns a shallow copy of this [LobbySnapshot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  LobbySnapshot copyWith({List<_i8of5w5h.LobbyRoom>? rooms});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LobbySnapshot',
      'rooms': rooms.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LobbySnapshot',
      'rooms': rooms.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _LobbySnapshotImpl extends LobbySnapshot {
  _LobbySnapshotImpl({required List<_i8of5w5h.LobbyRoom> rooms})
    : super._(rooms: rooms);

  /// Returns a shallow copy of this [LobbySnapshot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  LobbySnapshot copyWith({List<_i8of5w5h.LobbyRoom>? rooms}) {
    return LobbySnapshot(
      rooms: rooms ?? this.rooms.map((e0) => e0.copyWith()).toList(),
    );
  }
}
