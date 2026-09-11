import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../shared/services/flat_context_service.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        dioClient: Get.find<DioClient>(),
        cacheService: Get.find<LocalCacheService>(),
        flatService: Get.find<FlatContextService>(),
        secureStorageService: Get.isRegistered<SecureStorageService>()
            ? Get.find<SecureStorageService>()
            : null,
      ),
    );
  }
}
