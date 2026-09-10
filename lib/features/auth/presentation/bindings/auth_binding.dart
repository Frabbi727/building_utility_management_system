import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../shared/services/flat_context_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(dio: Get.find<DioClient>().dio),
    );
    Get.lazyPut<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(storageService: Get.find<SecureStorageService>()),
    );
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        localDataSource: Get.find<AuthLocalDataSource>(),
        flatContextService: Get.find<FlatContextService>(),
      ),
    );
    Get.lazyPut<LoginUseCase>(() => LoginUseCase(repository: Get.find<AuthRepository>()));
    Get.lazyPut<AuthController>(() => AuthController(loginUseCase: Get.find<LoginUseCase>()));
  }
}
