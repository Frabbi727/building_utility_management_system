import '../../../../core/storage/secure_storage_service.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<void> clearTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService storageService;
  const AuthLocalDataSourceImpl({required this.storageService});

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) {
    return storageService.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> clearTokens() {
    return storageService.clearTokens();
  }
}
