import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  String? _cachedAccessToken;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  bool get hasToken => _cachedAccessToken != null && _cachedAccessToken!.isNotEmpty;
  String? get cachedAccessToken => _cachedAccessToken;

  Future<void> init() async {
    _cachedAccessToken = await _storage.read(key: StorageKeys.authToken);
  }

  Future<String?> getAccessToken() async {
    _cachedAccessToken = await _storage.read(key: StorageKeys.authToken);
    return _cachedAccessToken;
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: StorageKeys.refreshToken);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: StorageKeys.authToken, value: accessToken);
    await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
    _cachedAccessToken = accessToken;
  }

  Future<void> clearTokens() async {
    _cachedAccessToken = null;
    await _storage.delete(key: StorageKeys.authToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }
}
