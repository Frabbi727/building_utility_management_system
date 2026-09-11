import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/services/flat_context_service.dart';
import '../../data/datasources/maintenance_remote_data_source.dart';
import '../../data/repositories/maintenance_repository_impl.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../../domain/usecases/create_maintenance_request_usecase.dart';
import '../../domain/usecases/get_maintenance_details_usecase.dart';
import '../../domain/usecases/get_maintenance_requests_usecase.dart';
import '../controllers/maintenance_controller.dart';

class MaintenanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MaintenanceRemoteDataSource>(
      () => MaintenanceRemoteDataSourceImpl(dio: Get.find<DioClient>().dio),
    );

    Get.lazyPut<MaintenanceRepository>(
      () => MaintenanceRepositoryImpl(remoteDataSource: Get.find<MaintenanceRemoteDataSource>()),
    );

    Get.lazyPut<GetMaintenanceRequestsUseCase>(
      () => GetMaintenanceRequestsUseCase(Get.find<MaintenanceRepository>()),
    );

    Get.lazyPut<GetMaintenanceDetailsUseCase>(
      () => GetMaintenanceDetailsUseCase(Get.find<MaintenanceRepository>()),
    );

    Get.lazyPut<CreateMaintenanceRequestUseCase>(
      () => CreateMaintenanceRequestUseCase(Get.find<MaintenanceRepository>()),
    );

    Get.lazyPut<MaintenanceController>(
      () => MaintenanceController(
        getRequestsUseCase: Get.find<GetMaintenanceRequestsUseCase>(),
        createRequestUseCase: Get.find<CreateMaintenanceRequestUseCase>(),
        flatService: Get.find<FlatContextService>(),
      ),
    );
  }
}
