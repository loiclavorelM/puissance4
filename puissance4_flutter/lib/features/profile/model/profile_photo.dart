import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// Côté de la miniature envoyée (même valeur que `ProfilePhoto.size` côté
/// serveur, qui la réencode de toute façon).
const profilePhotoSize = 256;

/// D'où vient la photo de profil.
enum PhotoSource { camera, gallery }

/// Prend ou choisit une photo et la réduit en miniature carrée (E2, US2.1).
/// Remplacé dans les tests.
abstract interface class PhotoPicker {
  /// Miniature JPEG prête à envoyer, ou `null` si le joueur a annulé.
  Future<Uint8List?> pick(PhotoSource source);
}

class DevicePhotoPicker implements PhotoPicker {
  DevicePhotoPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: switch (source) {
        PhotoSource.camera => ImageSource.camera,
        PhotoSource.gallery => ImageSource.gallery,
      },
      preferredCameraDevice: CameraDevice.front,
      // Pré-réduite par le système : moins de mémoire à décoder ensuite.
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (file == null) return null;
    return squareThumbnail(await file.readAsBytes());
  }
}

/// Recadre [bytes] au centre en carré de [profilePhotoSize] px, en JPEG.
/// Hors du thread UI (décodage d'une photo de plusieurs mégapixels).
/// Lève [FormatException] si ce n'est pas une image lisible.
Future<Uint8List> squareThumbnail(Uint8List bytes) =>
    compute(_squareThumbnail, bytes);

Uint8List _squareThumbnail(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) throw const FormatException('Unreadable image');
  final square = img.copyResizeCropSquare(
    img.bakeOrientation(image),
    size: profilePhotoSize,
    interpolation: img.Interpolation.average,
  );
  return img.encodeJpg(square, quality: 85);
}
