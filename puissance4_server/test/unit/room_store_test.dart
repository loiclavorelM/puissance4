import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:puissance4_server/src/multiplayer/room_store.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('Given an InMemoryRoomStore', () {
    late InMemoryRoomStore store;
    final host = const Uuid().v4obj();
    final guest = const Uuid().v4obj();
    final other = const Uuid().v4obj();

    setUp(() => store = InMemoryRoomStore());

    Future<Room> open({Duration lifetime = const Duration(minutes: 1)}) async =>
        (await store.create(
          hostAuthUserId: host,
          hostUserId: host,
          lifetime: lifetime,
        )).room;

    test(
      'when a guest claims the code then only the first claim gets it',
      () async {
        final room = await open();
        expect(room.code, hasLength(InMemoryRoomStore.codeLength));

        final first = await store.claim(
          room.code.toLowerCase(),
          guestAuthUserId: guest,
        );
        final second = await store.claim(room.code, guestAuthUserId: other);

        expect(first?.code, room.code);
        expect(second, isNull);
      },
    );

    test(
      'when the host claims its own room then it is refused and kept',
      () async {
        final room = await open();

        await expectLater(
          store.claim(room.code, guestAuthUserId: host),
          throwsA(
            isA<GameException>().having(
              (e) => e.reason,
              'reason',
              EnumGameError.ownRoom,
            ),
          ),
        );
        expect(await store.claim(room.code, guestAuthUserId: guest), isNotNull);
      },
    );

    test(
      'when the host opens a second room then the first is replaced',
      () async {
        final first = await open();
        final second = await store.create(
          hostAuthUserId: host,
          hostUserId: host,
          lifetime: const Duration(minutes: 1),
        );

        expect(second.replaced?.code, first.code);
        expect(await store.claim(first.code, guestAuthUserId: guest), isNull);
      },
    );

    test(
      'when the host removes its room then it can no longer be claimed',
      () async {
        final room = await open();
        await store.remove(room.code, host);
        expect(await store.claim(room.code, guestAuthUserId: guest), isNull);
      },
    );

    test(
      'when the room has expired then it can no longer be claimed',
      () async {
        final room = await open(lifetime: Duration.zero);
        expect(await store.claim(room.code, guestAuthUserId: guest), isNull);
      },
    );
  });
}
