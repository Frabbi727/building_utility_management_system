import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../shared/domain/entities/flat_entity.dart';
import '../../../../shared/services/flat_context_service.dart';
import '../../domain/entities/dashboard_data_entity.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';

class DashboardController extends GetxController {
  final GetDashboardDataUseCase getDashboardDataUseCase;
  final FlatContextService flatService;

  final Rx<ViewState> state = Rx<ViewState>(const IdleState());
  StreamSubscription<FlatEntity?>? _flatSubscription;

  DashboardController({
    required this.getDashboardDataUseCase,
    required this.flatService,
  });

  @override
  void onInit() {
    super.onInit();
    _flatSubscription = flatService.selectedFlat.listen((flat) {
      if (flat != null) {
        loadDashboard(flatId: flat.id);
      }
    });

    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null) {
      loadDashboard(flatId: currentFlat.id);
    }
  }

  Future<void> loadDashboard({required int flatId}) async {
    state.value = const LoadingState();
    final result = await getDashboardDataUseCase(flatId: flatId);
    result.fold(
      (failure) => state.value = ErrorState(failure.message),
      (data) => state.value = SuccessState<DashboardDataEntity>(data),
    );
  }

  Future<void> refreshDashboard() async {
    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null) {
      await loadDashboard(flatId: currentFlat.id);
    }
  }

  @override
  void onClose() {
    _flatSubscription?.cancel();
    super.onClose();
  }
}
