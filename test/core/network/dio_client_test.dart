import 'package:building_utility_management_system/core/network/dio_client.dart';
import 'package:building_utility_management_system/core/network/interceptors/auth_interceptor.dart';
import 'package:building_utility_management_system/core/network/interceptors/connectivity_interceptor.dart';
import 'package:building_utility_management_system/core/network/interceptors/error_interceptor.dart';
import 'package:building_utility_management_system/core/network/interceptors/logging_interceptor.dart';
import 'package:building_utility_management_system/core/network/network_info.dart';
import 'package:building_utility_management_system/core/storage/secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  test('DioClient initializes with expected options and interceptors', () {
    final storage = MockSecureStorageService();
    final networkInfo = MockNetworkInfo();

    final client = DioClient(
      baseUrl: 'https://api.example.com',
      storage: storage,
      networkInfo: networkInfo,
    );

    expect(client.dio.options.baseUrl, 'https://api.example.com');
    expect(client.dio.options.connectTimeout, const Duration(seconds: 30));
    expect(client.dio.options.receiveTimeout, const Duration(seconds: 30));
    expect(client.dio.options.sendTimeout, const Duration(seconds: 30));

    expect(client.dio.interceptors.any((i) => i is ConnectivityInterceptor), isTrue);
    expect(client.dio.interceptors.any((i) => i is AuthInterceptor), isTrue);
    expect(client.dio.interceptors.any((i) => i is LoggingInterceptor), isTrue);
    expect(client.dio.interceptors.any((i) => i is ErrorInterceptor), isTrue);
  });
}
