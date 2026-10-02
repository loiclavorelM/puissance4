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

    Future<Room> open({
      Duration lifetime = const Duration(minutes: 1),
      UuidValue? by,
      RoomHost? listedAs,
    }) async => (await store.create(
      hostAuthUserId: by ?? host,
      hostUserId: by ?? host,
      lifetime: lifetime,
      listedAs: listedAs,
    )).room;

    test(
      'when listing public rooms then private, own and expired ones are left out',
      () async {
        const shown = RoomHost(username: 'alice', elo: 1200);
        await open(); // privée
        final public = await open(by: guest, listedAs: shown);
        await open(
          by: other,
          listedAs: shown,
          lifetime: const Duration(milliseconds: 1),
        );
        await Future<void>.delayed(const Duration(milliseconds: 5));

        final listed = await store.listPublic(exceptHost: host);
        expect(listed.map((r) => r.code), [public.code]);
        expect(listed.single.toLobbyRoom().hostElo, 1200);
        expect(await store.listPublic(exceptHost: guest), isEmpty);
      },
    );

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

    test(
      'when a claimed room is restored then another guest can claim it',
      () async {
        final room = await open();
        final claimed = await store.claim(room.code, guestAuthUserId: guest);

        expect(await store.restore(claimed!), isTrue);
        expect(
          (await store.claim(room.code, guestAuthUserId: other))?.code,
          room.code,
        );
      },
    );

    test(
      'when the host opened another room meanwhile then the old one is not restored',
      () async {
        final room = await open();
        final claimed = await store.claim(room.code, guestAuthUserId: guest);
        await open();

        expect(await store.restore(claimed!), isFalse);
        expect(await store.claim(room.code, guestAuthUserId: other), isNull);
      },
    );
  });
}
