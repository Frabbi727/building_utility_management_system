import 'dart:async';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/base/view_state.dart';
import '../../../../shared/domain/entities/flat_entity.dart';
import '../../../../shared/services/flat_context_service.dart';
import '../../../bills/presentation/controllers/bills_controller.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../navigation/presentation/controllers/navigation_controller.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_submission_entity.dart';
import '../../domain/usecases/get_payment_submissions_usecase.dart';
import '../../domain/usecases/get_payments_usecase.dart';
import '../../domain/usecases/submit_payment_usecase.dart';

class PaymentsController extends GetxController {
  final GetPaymentsUseCase getPaymentsUseCase;
  final GetPaymentSubmissionsUseCase getSubmissionsUseCase;
  final SubmitPaymentUseCase submitPaymentUseCase;
  final FlatContextService flatService;

  final RxInt selectedTabIndex = 0.obs;
  final Rx<ViewState> paymentsState = Rx<ViewState>(const IdleState());
  final Rx<ViewState> submissionsState = Rx<ViewState>(const IdleState());

  final RxList<PaymentEntity> payments = <PaymentEntity>[].obs;
  final RxList<PaymentSubmissionEntity> submissions = <PaymentSubmissionEntity>[].obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isRefreshing = false.obs;

  int? _lastLoadedFlatId;
  StreamSubscription<FlatEntity?>? _flatSubscription;

  PaymentsController({
    required this.getPaymentsUseCase,
    required this.getSubmissionsUseCase,
    required this.submitPaymentUseCase,
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
        if (_isPaymentsTabActive()) {
          loadData(flatId: flat.id);
        } else {
          _lastLoadedFlatId = null;
        }
      }
    });

    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null && _isPaymentsTabActive()) {
      loadData(flatId: currentFlat.id);
    }
  }

  bool _isPaymentsTabActive() {
    if (Get.isRegistered<NavigationController>()) {
      return Get.find<NavigationController>().currentIndex.value == 2;
    }
    return false;
  }

  void onTabVisible() {
    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null) {
      loadData(flatId: currentFlat.id, isRefresh: true);
    }
  }

  void invalidateCache() {
    _lastLoadedFlatId = null;
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null) {
      if (index == 0) {
        loadPayments(flatId: currentFlat.id, isRefresh: true);
      } else {
        loadSubmissions(flatId: currentFlat.id, isRefresh: true);
      }
    }
  }

  Future<void> loadData({required int flatId, bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    }
    await Future.wait([
      loadPayments(flatId: flatId, isRefresh: isRefresh),
      loadSubmissions(flatId: flatId, isRefresh: isRefresh),
    ]);
    _lastLoadedFlatId = flatId;
    isRefreshing.value = false;
  }

  Future<void> loadPayments({required int flatId, bool isRefresh = false}) async {
    if (payments.isEmpty || !isRefresh) {
      paymentsState.value = const LoadingState();
    }
    final result = await getPaymentsUseCase(flatId: flatId);
    result.fold(
      (failure) {
        if (payments.isEmpty) {
          paymentsState.value = ErrorState(failure.message);
        }
      },
      (data) {
        payments.assignAll(data);
        paymentsState.value = SuccessState<List<PaymentEntity>>(data);
      },
    );
  }

  Future<void> loadSubmissions({required int flatId, bool isRefresh = false}) async {
    if (submissions.isEmpty || !isRefresh) {
      submissionsState.value = const LoadingState();
    }
    final result = await getSubmissionsUseCase(flatId: flatId);
    result.fold(
      (failure) {
        if (submissions.isEmpty) {
          submissionsState.value = ErrorState(failure.message);
        }
      },
      (data) {
        submissions.assignAll(data);
        submissionsState.value = SuccessState<List<PaymentSubmissionEntity>>(data);
      },
    );
  }

  Future<void> refreshAll() async {
    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null) {
      await loadData(flatId: currentFlat.id, isRefresh: true);
    }
  }

  Future<bool> submitPaymentProof({
    required String amount,
    required String method,
    required String referenceNumber,
    required String paymentDate,
    String? notes,
    String? slipFilePath,
  }) async {
    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat == null) return false;

    isSubmitting.value = true;
    final result = await submitPaymentUseCase(
      flatId: currentFlat.id,
      amount: amount,
      method: method,
      referenceNumber: referenceNumber,
      paymentDate: paymentDate,
      notes: notes,
      slipFilePath: slipFilePath,
    );
    isSubmitting.value = false;

    return result.fold(
      (failure) {
        Get.snackbar('Error', failure.message);
        return false;
      },
      (submission) {
        submissions.insert(0, submission);
        submissionsState.value =
            SuccessState<List<PaymentSubmissionEntity>>(List.from(submissions));
        selectedTabIndex.value = 1; // switch to Submissions tab to show new item

        // Invalidate dashboard and bills caches to ensure synchronization
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().refreshDashboard();
        }
        if (Get.isRegistered<BillsController>()) {
          Get.find<BillsController>().refreshBills();
        }

        return true;
      },
    );
  }

  Future<void> openReceiptUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        final fallback = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (!fallback) {
          Get.snackbar('Error', 'Could not open receipt PDF link');
        }
      }
    } catch (_) {
      Get.snackbar('Error', 'Could not open receipt PDF link');
    }
  }

  @override
  void onClose() {
    _flatSubscription?.cancel();
    super.onClose();
  }
}
