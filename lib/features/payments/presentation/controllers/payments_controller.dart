import 'dart:async';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/base/view_state.dart';
import '../../../../shared/domain/entities/flat_entity.dart';
import '../../../../shared/services/flat_context_service.dart';
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

  StreamSubscription<FlatEntity?>? _flatSubscription;

  PaymentsController({
    required this.getPaymentsUseCase,
    required this.getSubmissionsUseCase,
    required this.submitPaymentUseCase,
    required this.flatService,
  });

  @override
  void onInit() {
    super.onInit();
    _flatSubscription = flatService.selectedFlat.listen((flat) {
      if (flat != null) {
        loadData(flatId: flat.id);
      }
    });

    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null) {
      loadData(flatId: currentFlat.id);
    }
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  Future<void> loadData({required int flatId}) async {
    await Future.wait([
      loadPayments(flatId: flatId),
      loadSubmissions(flatId: flatId),
    ]);
  }

  Future<void> loadPayments({required int flatId}) async {
    paymentsState.value = const LoadingState();
    final result = await getPaymentsUseCase(flatId: flatId);
    result.fold(
      (failure) => paymentsState.value = ErrorState(failure.message),
      (data) {
        payments.assignAll(data);
        paymentsState.value = SuccessState<List<PaymentEntity>>(data);
      },
    );
  }

  Future<void> loadSubmissions({required int flatId}) async {
    submissionsState.value = const LoadingState();
    final result = await getSubmissionsUseCase(flatId: flatId);
    result.fold(
      (failure) => submissionsState.value = ErrorState(failure.message),
      (data) {
        submissions.assignAll(data);
        submissionsState.value = SuccessState<List<PaymentSubmissionEntity>>(data);
      },
    );
  }

  Future<void> refreshAll() async {
    final currentFlat = flatService.selectedFlat.value;
    if (currentFlat != null) {
      await loadData(flatId: currentFlat.id);
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
