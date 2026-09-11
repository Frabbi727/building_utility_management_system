import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_entity.dart';
import '../entities/payment_submission_entity.dart';

abstract class PaymentsRepository {
  Future<Either<Failure, List<PaymentEntity>>> getPayments({
    required int flatId,
    int page = 1,
  });

  Future<Either<Failure, String>> getReceipt(int paymentId);

  Future<Either<Failure, List<PaymentSubmissionEntity>>> getSubmissions({
    required int flatId,
    String? status,
    int page = 1,
  });

  Future<Either<Failure, PaymentSubmissionEntity>> submitPayment({
    required int flatId,
    required String amount,
    required String method,
    required String referenceNumber,
    required String paymentDate,
    String? notes,
    String? slipFilePath,
  });
}
