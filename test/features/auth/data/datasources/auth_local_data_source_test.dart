import 'package:building_utility_management_system/core/storage/secure_storage_service.dart';
import 'package:building_utility_management_system/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockSecureStorageService mockStorageService;
  late AuthLocalDataSourceImpl dataSource;

  setUp(() {
    mockStorageService = MockSecureStorageService();
    dataSource = AuthLocalDataSourceImpl(storageService: mockStorageService);
  });

  const accessToken = 'access_123';
  const refreshToken = 'refresh_456';

  test('saveTokens delegates to SecureStorageService.saveTokens', () async {
    when(
      () => mockStorageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
    ).thenAnswer((_) async {});

    await dataSource.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    verify(
      () => mockStorageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
    ).called(1);
  });

  test('clearTokens delegates to SecureStorageService.clearTokens', () async {
    when(() => mockStorageService.clearTokens()).thenAnswer((_) async {});

    await dataSource.clearTokens();

    verify(() => mockStorageService.clearTokens()).called(1);
  });
}
