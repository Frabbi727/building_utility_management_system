import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/services/flat_context_service.dart';
import '../../data/datasources/payments_remote_data_source.dart';
import '../../data/repositories/payments_repository_impl.dart';
import '../../domain/repositories/payments_repository.dart';
import '../../domain/usecases/get_payment_submissions_usecase.dart';
import '../../domain/usecases/get_payments_usecase.dart';
import '../../domain/usecases/submit_payment_usecase.dart';
import '../controllers/payments_controller.dart';

class PaymentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentsRemoteDataSource>(
      () => PaymentsRemoteDataSourceImpl(dio: Get.find<DioClient>().dio),
    );

    Get.lazyPut<PaymentsRepository>(
      () => PaymentsRepositoryImpl(remoteDataSource: Get.find<PaymentsRemoteDataSource>()),
    );

    Get.lazyPut<GetPaymentsUseCase>(
      () => GetPaymentsUseCase(Get.find<PaymentsRepository>()),
    );

    Get.lazyPut<GetPaymentSubmissionsUseCase>(
      () => GetPaymentSubmissionsUseCase(Get.find<PaymentsRepository>()),
    );

    Get.lazyPut<SubmitPaymentUseCase>(
      () => SubmitPaymentUseCase(Get.find<PaymentsRepository>()),
    );

    Get.lazyPut<PaymentsController>(
      () => PaymentsController(
        getPaymentsUseCase: Get.find<GetPaymentsUseCase>(),
        getSubmissionsUseCase: Get.find<GetPaymentSubmissionsUseCase>(),
        submitPaymentUseCase: Get.find<SubmitPaymentUseCase>(),
        flatService: Get.find<FlatContextService>(),
      ),
    );
  }
}
