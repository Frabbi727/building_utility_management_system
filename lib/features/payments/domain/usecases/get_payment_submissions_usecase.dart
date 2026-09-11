import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_submission_entity.dart';
import '../repositories/payments_repository.dart';

class GetPaymentSubmissionsUseCase {
  final PaymentsRepository repository;

  const GetPaymentSubmissionsUseCase(this.repository);

  Future<Either<Failure, List<PaymentSubmissionEntity>>> call({
    required int flatId,
    String? status,
    int page = 1,
  }) =>
      repository.getSubmissions(flatId: flatId, status: status, page: page);
}
