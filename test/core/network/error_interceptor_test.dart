import 'package:building_utility_management_system/core/error/failures.dart';
import 'package:building_utility_management_system/core/network/interceptors/error_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}
class FakeDioException extends Fake implements DioException {}

void main() {
  late ErrorInterceptor interceptor;
  late MockErrorInterceptorHandler handler;

  setUpAll(() {
    registerFallbackValue(FakeDioException());
  });

  setUp(() {
    interceptor = ErrorInterceptor();
    handler = MockErrorInterceptorHandler();
  });

  group('ErrorInterceptor.mapToFailure', () {
    test('returns existing failure directly if err.error is already a Failure', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        error: const ValidationFailure('Validation error'),
      );

      final failure = interceptor.mapToFailure(dioError);
      expect(failure, equals(const ValidationFailure('Validation error')));
    });

    test('maps connectionTimeout to NetworkFailure', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final failure = interceptor.mapToFailure(dioError);
      expect(failure, isA<NetworkFailure>());
    });

    test('maps badResponse with 401 to AuthFailure', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      final failure = interceptor.mapToFailure(dioError);
      expect(failure, isA<AuthFailure>());
    });

    test('maps badResponse with 403 to AuthFailure', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 403,
        ),
      );

      final failure = interceptor.mapToFailure(dioError);
      expect(failure, isA<AuthFailure>());
    });

    test('maps badResponse with server error message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
          data: {'message': 'Database connection failed'},
        ),
      );

      final failure = interceptor.mapToFailure(dioError);
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Database connection failed');
    });

    test('maps cancel to ServerFailure', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.cancel,
      );

      final failure = interceptor.mapToFailure(dioError);
      expect(failure, isA<ServerFailure>());
    });
  });

  group('ErrorInterceptor.onError', () {
    test('enriches DioException with Failure and forwards to handler.next', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      interceptor.onError(dioError, handler);

      final captured = verify(() => handler.next(captureAny())).captured;
      expect(captured.length, 1);
      final enriched = captured.first as DioException;
      expect(enriched.error, isA<NetworkFailure>());
    });
  });
}
