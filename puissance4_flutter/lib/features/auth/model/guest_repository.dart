import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'guest_profile.dart';

/// Persists the local guest profile on the device so "Continuer sans
/// compte" survives an app restart while the server stays unreachable.
class GuestRepository {
  GuestRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'guest_profile';

  final FlutterSecureStorage _storage;

  Future<GuestProfile?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    return GuestProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(GuestProfile profile) {
    return _storage.write(key: _key, value: jsonEncode(profile.toJson()));
  }

  Future<void> clear() {
    return _storage.delete(key: _key);
  }
}
