import 'package:building_utility_management_system/core/constants/storage_keys.dart';
import 'package:building_utility_management_system/core/storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageService service;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageService(storage: mockStorage);
  });

  test('init reads authToken into cache', () async {
    when(() => mockStorage.read(key: StorageKeys.authToken))
        .thenAnswer((_) async => 'stored_token');

    await service.init();

    expect(service.hasToken, isTrue);
    expect(service.cachedAccessToken, equals('stored_token'));
    verify(() => mockStorage.read(key: StorageKeys.authToken)).called(1);
  });

  test('getAccessToken reads from storage and updates cachedAccessToken', () async {
    when(() => mockStorage.read(key: StorageKeys.authToken))
        .thenAnswer((_) async => 'fresh_token');

    final token = await service.getAccessToken();

    expect(token, equals('fresh_token'));
    expect(service.cachedAccessToken, equals('fresh_token'));
    verify(() => mockStorage.read(key: StorageKeys.authToken)).called(1);
  });

  test('getRefreshToken reads refreshToken from storage', () async {
    when(() => mockStorage.read(key: StorageKeys.refreshToken))
        .thenAnswer((_) async => 'refresh_token_val');

    final token = await service.getRefreshToken();

    expect(token, equals('refresh_token_val'));
    verify(() => mockStorage.read(key: StorageKeys.refreshToken)).called(1);
  });

  test('saveTokens caches accessToken in-memory and writes to secure storage', () async {
    when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});

    await service.saveTokens(accessToken: 'token123', refreshToken: 'refresh456');

    expect(service.hasToken, isTrue);
    expect(service.cachedAccessToken, equals('token123'));
    verify(() => mockStorage.write(key: StorageKeys.authToken, value: 'token123')).called(1);
    verify(() => mockStorage.write(key: StorageKeys.refreshToken, value: 'refresh456')).called(1);
  });

  test('saveTokens does not cache accessToken if write fails', () async {
    when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenThrow(Exception('Storage write failure'));

    expect(
      () => service.saveTokens(accessToken: 'token123', refreshToken: 'refresh456'),
      throwsA(isA<Exception>()),
    );

    expect(service.hasToken, isFalse);
    expect(service.cachedAccessToken, isNull);
  });

  test('clearTokens removes cached accessToken and deletes keys in storage', () async {
    when(() => mockStorage.delete(key: any(named: 'key'))).thenAnswer((_) async {});

    await service.clearTokens();

    expect(service.hasToken, isFalse);
    expect(service.cachedAccessToken, isNull);
    verify(() => mockStorage.delete(key: StorageKeys.authToken)).called(1);
    verify(() => mockStorage.delete(key: StorageKeys.refreshToken)).called(1);
  });
}
