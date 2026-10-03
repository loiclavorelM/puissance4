import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:puissance4_server/src/generated/protocol.dart';
import 'package:puissance4_server/src/profile/profile_photo.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Image PNG unie de [width]×[height] px.
ByteData _png(int width, int height) => ByteData.sublistView(
  img.encodePng(
    img.Image(width: width, height: height)..clear(img.ColorRgb8(200, 40, 40)),
  ),
);

Matcher _refused(EnumProfileUpdateError reason) => throwsA(
  isA<ProfileUpdateException>().having((e) => e.reason, 'reason', reason),
);

void main() {
  withServerpod('Given a profile photo', (sessionBuilder, endpoints) {
    Future<(TestSessionBuilder, User)> signedInAs(String username) async {
      final session = sessionBuilder.build();
      final authUser = await const AuthUsers().create(session);
      final user = await User.db.insertRow(
        session,
        User(authUserId: authUser.id, username: username),
      );
      return (
        sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            authUser.id.uuid,
            {},
          ),
        ),
        user,
      );
    }

    Future<User> reload(User user) async =>
        (await User.db.findById(sessionBuilder.build(), user.id!))!;

    Future<bool> stored(String path) => sessionBuilder
        .build()
        .storage
        .fileExists(storageId: ProfilePhoto.storageId, path: path);

    test('when uploading a photo then a square thumbnail is stored and its '
        'URL is in the profile and the leaderboard', () async {
      final (alice, user) = await signedInAs('alice');

      final profile = await endpoints.profile.uploadProfilePhoto(
        alice,
        _png(400, 300),
      );

      final path = (await reload(user)).thumbnailPath!;
      expect(path, startsWith('avatars/${user.id!.uuid}/'));
      expect(await stored(path), isTrue);
      final file = await sessionBuilder.build().storage.retrieveFile(
        storageId: ProfilePhoto.storageId,
        path: path,
      );
      final thumbnail = img.decodeJpg(Uint8List.sublistView(file))!;
      expect((thumbnail.width, thumbnail.height), (256, 256));

      expect(profile.thumbnailUrl, isNotNull);
      expect(profile.thumbnailUrl, contains(Uri.encodeQueryComponent(path)));
      final board = await endpoints.leaderboard.getLeaderboard(
        alice,
        limit: 10,
        offset: 0,
      );
      expect(board.single.thumbnailUrl, profile.thumbnailUrl);
    });

    test('when replacing the photo then the old file is deleted', () async {
      final (alice, user) = await signedInAs('alice');
      await endpoints.profile.uploadProfilePhoto(alice, _png(300, 300));
      final first = (await reload(user)).thumbnailPath!;

      await Future<void>.delayed(const Duration(milliseconds: 5));
      await endpoints.profile.uploadProfilePhoto(alice, _png(300, 300));

      final second = (await reload(user)).thumbnailPath!;
      expect(second, isNot(first));
      expect(await stored(first), isFalse);
      expect(await stored(second), isTrue);
    });

    test(
      'when removing the photo then the profile goes back to none',
      () async {
        final (alice, user) = await signedInAs('alice');
        await endpoints.profile.uploadProfilePhoto(alice, _png(300, 300));
        final path = (await reload(user)).thumbnailPath!;

        final profile = await endpoints.profile.removeProfilePhoto(alice);

        expect(profile.thumbnailUrl, isNull);
        expect((await reload(user)).thumbnailPath, isNull);
        expect(await stored(path), isFalse);
      },
    );

    test('when the stored file has vanished then the profile has no photo '
        'instead of failing', () async {
      final (alice, user) = await signedInAs('alice');
      await User.db.updateRow(
        sessionBuilder.build(),
        user.copyWith(thumbnailPath: 'avatars/${user.id!.uuid}/gone.jpg'),
      );

      final profile = await endpoints.profile.getMyProfile(alice);
      expect(profile.thumbnailUrl, isNull);
      final board = await endpoints.leaderboard.getLeaderboard(
        alice,
        limit: 10,
        offset: 0,
      );
      expect(board.single.thumbnailUrl, isNull);
    });

    test('when the file is not an image then it is refused', () async {
      final (alice, _) = await signedInAs('alice');
      await expectLater(
        endpoints.profile.uploadProfilePhoto(
          alice,
          ByteData.sublistView(Uint8List.fromList('hello'.codeUnits)),
        ),
        _refused(EnumProfileUpdateError.invalidPhoto),
      );
    });

    test('when the image is too big then it is refused', () async {
      final (alice, _) = await signedInAs('alice');
      // Petit fichier, mais image géante une fois décodée.
      await expectLater(
        endpoints.profile.uploadProfilePhoto(alice, _png(3000, 3000)),
        _refused(EnumProfileUpdateError.photoTooLarge),
      );
      await expectLater(
        endpoints.profile.uploadProfilePhoto(
          alice,
          ByteData(ProfilePhoto.maxBytes + 1),
        ),
        _refused(EnumProfileUpdateError.photoTooLarge),
      );
    });
  });
}
