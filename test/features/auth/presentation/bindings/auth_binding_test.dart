import 'package:building_utility_management_system/core/network/dio_client.dart';
import 'package:building_utility_management_system/core/storage/secure_storage_service.dart';
import 'package:building_utility_management_system/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:building_utility_management_system/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:building_utility_management_system/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:building_utility_management_system/features/auth/domain/repositories/auth_repository.dart';
import 'package:building_utility_management_system/features/auth/domain/usecases/login_usecase.dart';
import 'package:building_utility_management_system/features/auth/presentation/bindings/auth_binding.dart';
import 'package:building_utility_management_system/features/auth/presentation/controllers/auth_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

class MockDioClient extends Mock implements DioClient {}
class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockDioClient mockDioClient;
  late MockSecureStorageService mockSecureStorage;
  late AuthBinding binding;

  setUp(() {
    Get.reset();
    mockDioClient = MockDioClient();
    mockSecureStorage = MockSecureStorageService();
    when(() => mockDioClient.dio).thenReturn(Dio());

    Get.put<DioClient>(mockDioClient);
    Get.put<SecureStorageService>(mockSecureStorage);
    binding = AuthBinding();
  });

  tearDown(() {
    Get.reset();
  });

  test('AuthBinding registers all auth slice dependencies via lazyPut', () {
    binding.dependencies();

    expect(Get.isRegistered<AuthRemoteDataSource>(), isTrue);
    expect(Get.isRegistered<AuthLocalDataSource>(), isTrue);
    expect(Get.isRegistered<AuthRepository>(), isTrue);
    expect(Get.isRegistered<LoginUseCase>(), isTrue);
    expect(Get.isRegistered<AuthController>(), isTrue);

    expect(Get.find<AuthRemoteDataSource>(), isA<AuthRemoteDataSourceImpl>());
    expect(Get.find<AuthLocalDataSource>(), isA<AuthLocalDataSourceImpl>());
    expect(Get.find<AuthRepository>(), isA<AuthRepositoryImpl>());
    expect(Get.find<LoginUseCase>(), isA<LoginUseCase>());
    expect(Get.find<AuthController>(), isA<AuthController>());
  });
}
