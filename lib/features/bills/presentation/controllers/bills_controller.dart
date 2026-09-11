import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../shared/domain/entities/flat_entity.dart';
import '../../../../shared/services/flat_context_service.dart';
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

  StreamSubscription<FlatEntity?>? _flatSubscription;

  BillsController({
    required this.getBillsUseCase,
    required this.getBillDetailsUseCase,
    required this.flatService,
  });

  @override
  void onInit() {
    super.onInit();
    _flatSubscription = flatService.selectedFlat.listen((flat) {
      if (flat != null) {
        loadBills(flatId: flat.id, status: selectedStatus.value);
      }
    });

    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null) {
      loadBills(flatId: currentFlat.id, status: selectedStatus.value);
    }
  }

  Future<void> loadBills({
    required int flatId,
    String? status,
    int? year,
    int? month,
  }) async {
    state.value = const LoadingState();
    final result = await getBillsUseCase(
      flatId: flatId,
      status: status,
      year: year,
      month: month,
    );

    result.fold(
      (failure) => state.value = ErrorState(failure.message),
      (data) {
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
      await loadBills(flatId: currentFlat.id, status: selectedStatus.value);
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
