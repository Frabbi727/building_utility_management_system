import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';
import '../controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    final dioClient = Get.find<DioClient>();

    if (!Get.isRegistered<NotificationRepository>()) {
      Get.lazyPut<NotificationRepository>(
        () => NotificationRepositoryImpl(dioClient: dioClient),
      );
    }

    Get.lazyPut<NotificationController>(
      () => NotificationController(
        repository: Get.find<NotificationRepository>(),
      ),
    );
  }
}
