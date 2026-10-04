import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:serverpod/serverpod.dart';

/// Photo de profil (E2, US2.1) : format, stockage et URL publique.
///
/// L'app envoie déjà une miniature carrée de [size] px ; le serveur la
/// re-décode et la réencode quand même — il ne fait pas confiance au client,
/// et le réencodage retire les métadonnées (EXIF : position GPS…).
abstract final class ProfilePhoto {
  static const storageId = 'public';

  /// Côté de la miniature stockée (même valeur que `profilePhotoSize` côté
  /// app).
  static const size = 256;

  /// Garde-fous contre une image piégée (petit fichier, image géante une
  /// fois décodée) : l'app n'envoie que du [size]×[size].
  static const maxBytes = 512 * 1024;
  static const maxSide = 1024;

  /// Chemin d'une nouvelle photo : un nom différent à chaque envoi, pour que
  /// les appareils ne gardent pas l'ancienne image en cache.
  static String pathFor(UuidValue userId) =>
      'avatars/${userId.uuid}/${DateTime.now().millisecondsSinceEpoch}.jpg';

  /// Miniature JPEG carrée, recadrée au centre. Lève
  /// [PhotoTooLargeException] au-delà de [maxSide] px, [FormatException] si
  /// [bytes] n'est pas une image lisible.
  static Future<Uint8List> normalize(Uint8List bytes) =>
      Isolate.run(() => _normalize(bytes));

  static Uint8List _normalize(Uint8List bytes) {
    // JPEG et PNG seulement (ce qu'envoie l'app) : pas de décodeur exotique
    // exposé aux fichiers des joueurs.
    final img.Decoder decoder = _startsWith(bytes, const [0xFF, 0xD8, 0xFF])
        ? img.JpegDecoder()
        : _startsWith(bytes, const [0x89, 0x50, 0x4E, 0x47])
        ? img.PngDecoder()
        : throw const FormatException('Not a JPEG or PNG image');
    final info = decoder.startDecode(bytes);
    if (info == null) throw const FormatException('Unreadable image');
    if (info.width > maxSide || info.height > maxSide) {
      throw const PhotoTooLargeException();
    }
    final image = decoder.decode(bytes);
    if (image == null) throw const FormatException('Unreadable image');
    final square = img.copyResizeCropSquare(
      img.bakeOrientation(image),
      size: size,
      interpolation: img.Interpolation.average,
    );
    return img.encodeJpg(square, quality: 85);
  }

  static bool _startsWith(Uint8List bytes, List<int> magic) =>
      bytes.length >= magic.length &&
      [for (var i = 0; i < magic.length; i++) bytes[i] == magic[i]].every(
        (same) => same,
      );

  /// URL publique d'une photo stockée ([path] = `User.thumbnailPath`),
  /// `null` si le fichier a disparu du stockage — le profil s'affiche alors
  /// avec les initiales plutôt que d'échouer.
  static Future<String?> url(Session session, String? path) async {
    if (path == null) return null;
    try {
      final uri = await session.storage.publicDownloadUrl(
        storageId: storageId,
        path: path,
      );
      return uri.toString();
    } on CloudStorageException catch (e) {
      session.log(
        'Profile photo $path unavailable: $e',
        level: LogLevel.warning,
      );
      return null;
    }
  }

  /// [url] pour plusieurs photos d'un coup (classement).
  static Future<Map<String, String>> urls(
    Session session,
    Iterable<String?> paths,
  ) async {
    final distinct = paths.whereType<String>().toSet().toList();
    if (distinct.isEmpty) return {};
    final uris = await session.storage.publicDownloadUrls(
      storageId: storageId,
      paths: distinct,
    );
    return {
      for (var i = 0; i < distinct.length; i++)
        if (uris[i] != null) distinct[i]: uris[i].toString(),
    };
  }
}

/// Image plus grande que [ProfilePhoto.maxSide] px de côté.
class PhotoTooLargeException implements Exception {
  const PhotoTooLargeException();
}
