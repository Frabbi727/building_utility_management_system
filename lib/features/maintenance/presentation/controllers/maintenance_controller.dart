import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../shared/domain/entities/flat_entity.dart';
import '../../../../shared/services/flat_context_service.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../navigation/presentation/controllers/navigation_controller.dart';
import '../../domain/entities/maintenance_request_entity.dart';
import '../../domain/usecases/create_maintenance_request_usecase.dart';
import '../../domain/usecases/get_maintenance_requests_usecase.dart';

class MaintenanceController extends GetxController {
  final GetMaintenanceRequestsUseCase getRequestsUseCase;
  final CreateMaintenanceRequestUseCase createRequestUseCase;
  final FlatContextService flatService;

  final Rx<ViewState> state = Rx<ViewState>(const IdleState());
  final RxString selectedStatus = 'all'.obs;
  final RxList<MaintenanceRequestEntity> requests = <MaintenanceRequestEntity>[].obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isRefreshing = false.obs;

  int? _lastLoadedFlatId;
  StreamSubscription<FlatEntity?>? _flatSubscription;

  MaintenanceController({
    required this.getRequestsUseCase,
    required this.createRequestUseCase,
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
        if (_isMaintenanceTabActive()) {
          loadRequests(flatId: flat.id, status: selectedStatus.value);
        } else {
          _lastLoadedFlatId = null;
        }
      }
    });

    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null && _isMaintenanceTabActive()) {
      loadRequests(flatId: currentFlat.id, status: selectedStatus.value);
    }
  }

  bool _isMaintenanceTabActive() {
    if (Get.isRegistered<NavigationController>()) {
      return Get.find<NavigationController>().currentIndex.value == 3;
    }
    return false;
  }

  void onTabVisible() {
    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null) {
      loadRequests(
        flatId: currentFlat.id,
        status: selectedStatus.value,
        isRefresh: true,
      );
    }
  }

  void invalidateCache() {
    _lastLoadedFlatId = null;
  }

  Future<void> loadRequests({
    required int flatId,
    String? status,
    bool isRefresh = false,
  }) async {
    if (requests.isEmpty || !isRefresh) {
      state.value = const LoadingState();
    }
    if (isRefresh) {
      isRefreshing.value = true;
    }

    final result = await getRequestsUseCase(
      flatId: flatId,
      status: status,
    );

    isRefreshing.value = false;

    result.fold(
      (failure) {
        if (requests.isEmpty) {
          state.value = ErrorState(failure.message);
        }
      },
      (data) {
        _lastLoadedFlatId = flatId;
        requests.assignAll(data);
        state.value = SuccessState<List<MaintenanceRequestEntity>>(data);
      },
    );
  }

  Future<void> filterByStatus(String status) async {
    selectedStatus.value = status;
    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null) {
      await loadRequests(flatId: currentFlat.id, status: status);
    }
  }

  Future<void> refreshRequests() async {
    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null) {
      await loadRequests(
        flatId: currentFlat.id,
        status: selectedStatus.value,
        isRefresh: true,
      );
    }
  }

  Future<bool> submitRequest({
    required String title,
    required String description,
    required String category,
    required String priority,
  }) async {
    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat == null) return false;

    isSubmitting.value = true;
    final result = await createRequestUseCase(
      flatId: currentFlat.id,
      title: title,
      description: description,
      category: category,
      priority: priority,
    );
    isSubmitting.value = false;

    return result.fold(
      (failure) {
        Get.snackbar('Error', failure.message);
        return false;
      },
      (created) {
        requests.insert(0, created);
        state.value = SuccessState<List<MaintenanceRequestEntity>>(List.from(requests));

        // Invalidate dashboard to sync recent tickets
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().refreshDashboard();
        }

        return true;
      },
    );
  }

  @override
  void onClose() {
    _flatSubscription?.cancel();
    super.onClose();
  }
}
