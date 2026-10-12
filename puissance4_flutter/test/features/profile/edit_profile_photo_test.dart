import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:puissance4_client/puissance4_client.dart';
import 'package:puissance4_flutter/features/profile/model/profile_photo.dart';
import 'package:puissance4_flutter/features/profile/model/profile_repository.dart';
import 'package:puissance4_flutter/features/profile/viewmodel/edit_profile_viewmodel.dart';
import 'package:puissance4_flutter/features/profile/viewmodel/profile_provider.dart';

import '../../helpers/l10n.dart';

class _FakePicker implements PhotoPicker {
  Object? result;

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    final r = result;
    if (r is Exception) throw r;
    return r as Uint8List?;
  }
}

class _FakeRepository implements ProfileRepository {
  final uploads = <Uint8List>[];
  var removals = 0;
  ProfileUpdateException? refusal;

  UserProfileDto get _profile => UserProfileDto(
    id: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
    username: 'alice',
    elo: 1000,
    nbParties: 0,
    nbVictoires: 0,
  );

  @override
  Future<UserProfileDto> uploadPhoto(Uint8List photo) async {
    if (refusal != null) throw refusal!;
    uploads.add(photo);
    return _profile;
  }

  @override
  Future<UserProfileDto> removePhoto() async {
    removals++;
    return _profile;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('a photo becomes a centred 256×256 JPEG thumbnail', () async {
    final wide = img.encodePng(img.Image(width: 400, height: 300));

    final thumbnail = await squareThumbnail(wide);

    final decoded = img.decodeJpg(thumbnail)!;
    expect((decoded.width, decoded.height), (256, 256));
  });

  test('a file that is not an image is refused', () async {
    await expectLater(
      squareThumbnail(Uint8List.fromList('hello'.codeUnits)),
      throwsA(anything),
    );
  });

  group('Given the edit-profile viewmodel', () {
    late _FakePicker picker;
    late _FakeRepository repository;
    late ProviderContainer container;

    EditProfileViewModel viewModel() =>
        container.read(editProfileViewModelProvider.notifier);
    EditProfileState read() => container.read(editProfileViewModelProvider);

    setUp(() {
      picker = _FakePicker();
      repository = _FakeRepository();
      container = ProviderContainer(
        overrides: [
          ...l10nOverrides,
          photoPickerProvider.overrideWithValue(picker),
          profileRepositoryProvider.overrideWithValue(repository),
          myProfileProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      container.listen(editProfileViewModelProvider, (_, _) {});
    });

    tearDown(() => container.dispose());

    test('when a photo is picked then it is uploaded', () async {
      picker.result = Uint8List.fromList([1, 2, 3]);

      expect(await viewModel().changePhoto(PhotoSource.camera), isTrue);

      expect(repository.uploads.single, [1, 2, 3]);
      expect(read().isUpdatingPhoto, isFalse);
      expect(read().photoError, isNull);
    });

    test('when the player cancels then nothing is sent', () async {
      picker.result = null;

      expect(await viewModel().changePhoto(PhotoSource.gallery), isFalse);

      expect(repository.uploads, isEmpty);
      expect(read().photoError, isNull);
    });

    test(
      'when the server refuses the photo then the reason is shown',
      () async {
        picker.result = Uint8List.fromList([1]);
        repository.refusal = ProfileUpdateException(
          reason: EnumProfileUpdateError.photoTooLarge,
        );

        expect(await viewModel().changePhoto(PhotoSource.gallery), isFalse);

        expect(read().photoError, 'Cette image est trop grande.');
      },
    );

    test('when the picked file is unreadable then it says so', () async {
      picker.result = const FormatException('bad');

      expect(await viewModel().changePhoto(PhotoSource.gallery), isFalse);

      expect(read().photoError, "Ce fichier n'est pas une image lisible.");
      expect(repository.uploads, isEmpty);
    });

    test('when removing the photo then the server is asked to', () async {
      expect(await viewModel().removePhoto(), isTrue);
      expect(repository.removals, 1);
    });
  });
}
