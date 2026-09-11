import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_entity.dart';
import '../repositories/payments_repository.dart';

class GetPaymentsUseCase {
  final PaymentsRepository repository;

  const GetPaymentsUseCase(this.repository);

  Future<Either<Failure, List<PaymentEntity>>> call({
    required int flatId,
    int page = 1,
  }) =>
      repository.getPayments(flatId: flatId, page: page);
}
