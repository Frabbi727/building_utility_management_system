import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_submission_entity.dart';
import '../repositories/payments_repository.dart';

class SubmitPaymentUseCase {
  final PaymentsRepository repository;

  const SubmitPaymentUseCase(this.repository);

  Future<Either<Failure, PaymentSubmissionEntity>> call({
    required int flatId,
    required String amount,
    required String method,
    required String referenceNumber,
    required String paymentDate,
    String? notes,
    String? slipFilePath,
  }) =>
      repository.submitPayment(
        flatId: flatId,
        amount: amount,
        method: method,
        referenceNumber: referenceNumber,
        paymentDate: paymentDate,
        notes: notes,
        slipFilePath: slipFilePath,
      );
}
