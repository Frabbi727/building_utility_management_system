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

    test('passes error through if path is refreshToken', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.refreshToken),
        response: Response(
          requestOptions: RequestOptions(path: ApiEndpoints.refreshToken),
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

    test('successful token refresh saves tokens, retries original request, and resolves handler', () async {
      final reqOptions = RequestOptions(
        path: '/profile',
        headers: {'Authorization': 'Bearer old-token'},
      );
      final err = DioException(
        requestOptions: reqOptions,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 401,
        ),
      );

      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => 'old-token');
      when(() => mockStorage.getRefreshToken())
          .thenAnswer((_) async => 'refresh-token-123');
      when(
        () => mockRefreshDio.post<Map<String, dynamic>>(
          ApiEndpoints.refreshToken,
          data: {'refreshToken': 'refresh-token-123'},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.refreshToken),
          statusCode: 200,
          data: {
            'accessToken': 'new-access-token',
            'refreshToken': 'new-refresh-token',
          },
        ),
      );
      when(
        () => mockStorage.saveTokens(
          accessToken: 'new-access-token',
          refreshToken: 'new-refresh-token',
        ),
      ).thenAnswer((_) async {});

      final retryResponse = Response<dynamic>(
        requestOptions: reqOptions,
        statusCode: 200,
        data: {'user': 'test'},
      );
      when(() => mockRefreshDio.fetch<dynamic>(any()))
          .thenAnswer((_) async => retryResponse);

      await interceptor.onError(err, errorHandler);

      verify(
        () => mockStorage.saveTokens(
          accessToken: 'new-access-token',
          refreshToken: 'new-refresh-token',
        ),
      ).called(1);
      expect(reqOptions.headers['Authorization'], 'Bearer new-access-token');
      verify(() => errorHandler.resolve(retryResponse)).called(1);
      verifyNever(() => errorHandler.next(any()));
    });

    test('queued race condition: retries immediately with currentToken if concurrent request already refreshed token', () async {
      final reqOptions = RequestOptions(
        path: '/orders',
        headers: {'Authorization': 'Bearer old-token'},
      );
      final err = DioException(
        requestOptions: reqOptions,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 401,
        ),
      );

      when(() => mockStorage.getAccessToken())
          .thenAnswer((_) async => 'already-refreshed-token');

      final retryResponse = Response<dynamic>(
        requestOptions: reqOptions,
        statusCode: 200,
        data: <String, dynamic>{'orders': <dynamic>[]},
      );
      when(() => mockRefreshDio.fetch<dynamic>(any()))
          .thenAnswer((_) async => retryResponse);

      await interceptor.onError(err, errorHandler);

      verifyNever(() => mockRefreshDio.post<Map<String, dynamic>>(any(), data: any(named: 'data')));
      verifyNever(() => mockStorage.saveTokens(accessToken: any(named: 'accessToken'), refreshToken: any(named: 'refreshToken')));

      expect(reqOptions.headers['Authorization'], 'Bearer already-refreshed-token');
      verify(() => errorHandler.resolve(retryResponse)).called(1);
    });

    test('transient network error during refresh does NOT wipe tokens or trigger logout', () async {
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
      when(() => mockStorage.getRefreshToken())
          .thenAnswer((_) async => 'valid-refresh-token');

      final transientDioErr = DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.refreshToken),
        type: DioExceptionType.connectionTimeout,
      );
      when(
        () => mockRefreshDio.post<Map<String, dynamic>>(
          ApiEndpoints.refreshToken,
          data: {'refreshToken': 'valid-refresh-token'},
        ),
      ).thenThrow(transientDioErr);

      await interceptor.onError(err, errorHandler);

      verifyNever(() => mockStorage.clearTokens());
      expect(expiredCallbackCalled, isFalse);
      verify(() => errorHandler.next(transientDioErr)).called(1);
    });

    test('non-transient 401 during refresh purges session and triggers logout callback', () async {
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
      when(() => mockStorage.getRefreshToken())
          .thenAnswer((_) async => 'expired-refresh-token');
      when(() => mockStorage.clearTokens()).thenAnswer((_) async {});

      final authDioErr = DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.refreshToken),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ApiEndpoints.refreshToken),
          statusCode: 401,
        ),
      );
      when(
        () => mockRefreshDio.post<Map<String, dynamic>>(
          ApiEndpoints.refreshToken,
          data: {'refreshToken': 'expired-refresh-token'},
        ),
      ).thenThrow(authDioErr);

      await interceptor.onError(err, errorHandler);

      verify(() => mockStorage.clearTokens()).called(1);
      expect(expiredCallbackCalled, isTrue);
      verify(() => errorHandler.next(authDioErr)).called(1);
    });
  });
}
