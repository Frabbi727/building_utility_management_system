import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/services/flat_context_service.dart';
import '../../data/datasources/bills_remote_data_source.dart';
import '../../data/repositories/bills_repository_impl.dart';
import '../../domain/repositories/bills_repository.dart';
import '../../domain/usecases/get_bill_details_usecase.dart';
import '../../domain/usecases/get_bills_usecase.dart';
import '../controllers/bills_controller.dart';

class BillsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BillsRemoteDataSource>(
      () => BillsRemoteDataSourceImpl(dio: Get.find<DioClient>().dio),
    );

    Get.lazyPut<BillsRepository>(
      () => BillsRepositoryImpl(remoteDataSource: Get.find<BillsRemoteDataSource>()),
    );

    Get.lazyPut<GetBillsUseCase>(
      () => GetBillsUseCase(Get.find<BillsRepository>()),
    );

    Get.lazyPut<GetBillDetailsUseCase>(
      () => GetBillDetailsUseCase(Get.find<BillsRepository>()),
    );

    Get.lazyPut<BillsController>(
      () => BillsController(
        getBillsUseCase: Get.find<GetBillsUseCase>(),
        getBillDetailsUseCase: Get.find<GetBillDetailsUseCase>(),
        flatService: Get.find<FlatContextService>(),
      ),
    );
  }
}
