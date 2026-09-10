import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/services/flat_context_service.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';
import '../../domain/usecases/get_resident_flats_usecase.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DashboardRemoteDataSource>()) {
      Get.lazyPut<DashboardRemoteDataSource>(
        () => DashboardRemoteDataSourceImpl(dio: Get.find<DioClient>().dio),
      );
    }

    if (!Get.isRegistered<DashboardRepository>()) {
      Get.lazyPut<DashboardRepository>(
        () => DashboardRepositoryImpl(
          remoteDataSource: Get.find<DashboardRemoteDataSource>(),
        ),
      );
    }

    if (!Get.isRegistered<GetDashboardDataUseCase>()) {
      Get.lazyPut<GetDashboardDataUseCase>(
        () => GetDashboardDataUseCase(Get.find<DashboardRepository>()),
      );
    }

    if (!Get.isRegistered<GetResidentFlatsUseCase>()) {
      Get.lazyPut<GetResidentFlatsUseCase>(
        () => GetResidentFlatsUseCase(Get.find<DashboardRepository>()),
      );
    }

    if (!Get.isRegistered<DashboardController>()) {
      Get.lazyPut<DashboardController>(
        () => DashboardController(
          getDashboardDataUseCase: Get.find<GetDashboardDataUseCase>(),
          flatService: Get.find<FlatContextService>(),
        ),
      );
    }
  }
}
