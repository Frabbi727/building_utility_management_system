import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../shared/domain/entities/flat_entity.dart';
import '../../../../shared/services/flat_context_service.dart';
import '../../../navigation/presentation/controllers/navigation_controller.dart';
import '../../domain/entities/bill_entity.dart';
import '../../domain/usecases/get_bill_details_usecase.dart';
import '../../domain/usecases/get_bills_usecase.dart';

class BillsController extends GetxController {
  final GetBillsUseCase getBillsUseCase;
  final GetBillDetailsUseCase getBillDetailsUseCase;
  final FlatContextService flatService;

  final RxString selectedStatus = 'all'.obs;
  final Rx<ViewState> state = Rx<ViewState>(const IdleState());
  final RxList<BillEntity> bills = <BillEntity>[].obs;
  final RxBool isRefreshing = false.obs;

  int? _lastLoadedFlatId;
  StreamSubscription<FlatEntity?>? _flatSubscription;

  BillsController({
    required this.getBillsUseCase,
    required this.getBillDetailsUseCase,
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
        if (_isBillsTabActive()) {
          loadBills(flatId: flat.id, status: selectedStatus.value);
        } else {
          _lastLoadedFlatId = null;
        }
      }
    });

    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null && _isBillsTabActive()) {
      loadBills(flatId: currentFlat.id, status: selectedStatus.value);
    }
  }

  bool _isBillsTabActive() {
    if (Get.isRegistered<NavigationController>()) {
      return Get.find<NavigationController>().currentIndex.value == 1;
    }
    return false;
  }

  void onTabVisible() {
    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null && _lastLoadedFlatId != currentFlat.id) {
      loadBills(flatId: currentFlat.id, status: selectedStatus.value);
    }
  }

  void invalidateCache() {
    _lastLoadedFlatId = null;
  }

  Future<void> loadBills({
    required int flatId,
    String? status,
    int? year,
    int? month,
    bool isRefresh = false,
  }) async {
    if (bills.isEmpty || !isRefresh) {
      state.value = const LoadingState();
    }
    if (isRefresh) {
      isRefreshing.value = true;
    }

    final result = await getBillsUseCase(
      flatId: flatId,
      status: status,
      year: year,
      month: month,
    );

    isRefreshing.value = false;

    result.fold(
      (failure) {
        if (bills.isEmpty) {
          state.value = ErrorState(failure.message);
        }
      },
      (data) {
        _lastLoadedFlatId = flatId;
        bills.assignAll(data);
        state.value = SuccessState<List<BillEntity>>(data);
      },
    );
  }

  Future<void> filterByStatus(String status) async {
    selectedStatus.value = status;
    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null) {
      await loadBills(flatId: currentFlat.id, status: status);
    }
  }

  Future<void> refreshBills() async {
    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null) {
      await loadBills(
        flatId: currentFlat.id,
        status: selectedStatus.value,
        isRefresh: true,
      );
    }
  }

  Future<BillEntity?> getBillDetails(int id) async {
    final result = await getBillDetailsUseCase(id);
    return result.fold(
      (failure) {
        Get.snackbar('Error', failure.message);
        return null;
      },
      (data) => data,
    );
  }

  @override
  void onClose() {
    _flatSubscription?.cancel();
    super.onClose();
  }
}
