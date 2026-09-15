import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../shared/domain/entities/flat_entity.dart';
import '../../../../shared/services/flat_context_service.dart';
import '../../../navigation/presentation/controllers/navigation_controller.dart';
import '../../domain/entities/dashboard_data_entity.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';

class DashboardController extends GetxController {
  final GetDashboardDataUseCase getDashboardDataUseCase;
  final FlatContextService flatService;

  final Rx<ViewState> state = Rx<ViewState>(const IdleState());
  final RxBool isRefreshing = false.obs;
  int? _lastLoadedFlatId;
  StreamSubscription<FlatEntity?>? _flatSubscription;

  DashboardController({
    required this.getDashboardDataUseCase,
    required this.flatService,
  });

  int? get lastLoadedFlatId => _lastLoadedFlatId;
  bool get hasLoadedCurrentFlat =>
      _lastLoadedFlatId != null && _lastLoadedFlatId == flatService.selectedFlat.value?.id;

  @override
  void onInit() {
    super.onInit();
    _flatSubscription = flatService.selectedFlat.listen((flat) {
      if (flat != null) {
        if (_isDashboardTabActive()) {
          loadDashboard(flatId: flat.id);
        } else {
          _lastLoadedFlatId = null;
        }
      }
    });

    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null) {
      loadDashboard(flatId: currentFlat.id);
    }
  }

  bool _isDashboardTabActive() {
    if (Get.isRegistered<NavigationController>()) {
      return Get.find<NavigationController>().currentIndex.value == 0;
    }
    return true;
  }

  void onTabVisible() {
    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null && _lastLoadedFlatId != currentFlat.id) {
      loadDashboard(flatId: currentFlat.id);
    }
  }

  void invalidateCache() {
    _lastLoadedFlatId = null;
  }

  Future<void> loadDashboard({required int flatId, bool isRefresh = false}) async {
    if (state.value is! SuccessState<DashboardDataEntity> || !isRefresh) {
      state.value = const LoadingState();
    }
    if (isRefresh) {
      isRefreshing.value = true;
    }

    final result = await getDashboardDataUseCase(flatId: flatId);
    isRefreshing.value = false;

    result.fold(
      (failure) {
        if (state.value is! SuccessState<DashboardDataEntity>) {
          state.value = ErrorState(failure.message);
        }
      },
      (data) {
        _lastLoadedFlatId = flatId;
        state.value = SuccessState<DashboardDataEntity>(data);
      },
    );
  }

  Future<void> refreshDashboard() async {
    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null) {
      await loadDashboard(flatId: currentFlat.id, isRefresh: true);
    }
  }

  @override
  void onClose() {
    _flatSubscription?.cancel();
    super.onClose();
  }
}

