import 'package:building_utility_management_system/core/constants/api_endpoints.dart';
import 'package:building_utility_management_system/core/network/interceptors/auth_interceptor.dart';
import 'package:building_utility_management_system/core/storage/secure_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}
class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}
class MockDio extends Mock implements Dio {}
class FakeDioException extends Fake implements DioException {}
class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  late MockSecureStorageService mockStorage;
  late MockDio mockRefreshDio;
  late AuthInterceptor interceptor;
  late MockRequestInterceptorHandler requestHandler;
  late MockErrorInterceptorHandler errorHandler;
  bool expiredCallbackCalled = false;

  setUpAll(() {
    registerFallbackValue(FakeDioException());
    registerFallbackValue(FakeRequestOptions());
  });

  setUp(() {
    mockStorage = MockSecureStorageService();
    mockRefreshDio = MockDio();
    expiredCallbackCalled = false;

    interceptor = AuthInterceptor(
      storage: mockStorage,
      baseUrl: 'https://api.example.com',
      refreshDio: mockRefreshDio,
      onAuthenticationExpired: () {
        expiredCallbackCalled = true;
      },
    );
    requestHandler = MockRequestInterceptorHandler();
    errorHandler = MockErrorInterceptorHandler();
  });

  group('AuthInterceptor onRequest', () {
    test('adds Authorization Bearer header when token exists', () async {
      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => 'mock-jwt-token');
      final options = RequestOptions(path: '/profile');

      await interceptor.onRequest(options, requestHandler);

      expect(options.headers['Authorization'], 'Bearer mock-jwt-token');
      verify(() => requestHandler.next(options)).called(1);
    });

    test('does not add Authorization header when token is null or empty', () async {
      when(() => mockStorage.getAccessToken()).thenAnswer((_) async => null);
      final options = RequestOptions(path: '/public');

      await interceptor.onRequest(options, requestHandler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verify(() => requestHandler.next(options)).called(1);
    });
  });

  group('AuthInterceptor onError', () {
    test('passes error through if status code is not 401', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/profile'),
        response: Response(
          requestOptions: RequestOptions(path: '/profile'),
          statusCode: 500,
        ),
      );

      await interceptor.onError(err, errorHandler);

      verify(() => errorHandler.next(err)).called(1);
      verifyNever(() => mockStorage.getRefreshToken());
    });

    test('passes error through if path is login', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        response: Response(
          requestOptions: RequestOptions(path: ApiEndpoints.login),
          statusCode: 401,
        ),
      );

      await interceptor.onError(err, errorHandler);

      verify(() => errorHandler.next(err)).called(1);
      verifyNever(() => mockStorage.getRefreshToken());
    });

    test('logs out and triggers callback if refreshToken is null on 401', () async {
      final reqOptions = RequestOptions(
        path: '/profile',
        headers: {'Authorization': 'Bearer current-token'},
      );
      final err = DioException(
        requestOptions: reqOptions,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 401,
        ),
      );

      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => 'current-token');
      when(() => mockStorage.getRefreshToken()).thenAnswer((_) async => null);
      when(() => mockStorage.clearTokens()).thenAnswer((_) async {});

      await interceptor.onError(err, errorHandler);

      verify(() => mockStorage.clearTokens()).called(1);
      expect(expiredCallbackCalled, isTrue);
      verify(() => errorHandler.next(err)).called(1);
    });
  });
}
