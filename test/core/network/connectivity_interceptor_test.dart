import 'package:building_utility_management_system/core/error/failures.dart';
import 'package:building_utility_management_system/core/network/interceptors/connectivity_interceptor.dart';
import 'package:building_utility_management_system/core/network/network_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNetworkInfo extends Mock implements NetworkInfo {}
class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}
class FakeDioException extends Fake implements DioException {}
class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  late MockNetworkInfo mockNetworkInfo;
  late ConnectivityInterceptor interceptor;
  late MockRequestInterceptorHandler handler;

  setUpAll(() {
    registerFallbackValue(FakeDioException());
    registerFallbackValue(FakeRequestOptions());
  });

  setUp(() {
    mockNetworkInfo = MockNetworkInfo();
    interceptor = ConnectivityInterceptor(mockNetworkInfo);
    handler = MockRequestInterceptorHandler();
  });

  test('calls handler.next when connected', () async {
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    final options = RequestOptions(path: '/test');

    await interceptor.onRequest(options, handler);

    verify(() => handler.next(options)).called(1);
    verifyNever(() => handler.reject(any()));
  });

  test('rejects with NetworkFailure when disconnected', () async {
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
    final options = RequestOptions(path: '/test');

    await interceptor.onRequest(options, handler);

    final captured = verify(() => handler.reject(captureAny())).captured;
    expect(captured.length, 1);
    final error = captured.first as DioException;
    expect(error.type, DioExceptionType.connectionError);
    expect(error.error, isA<NetworkFailure>());
  });
}
