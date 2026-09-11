import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/bill_entity.dart';
import '../repositories/bills_repository.dart';

class GetBillsUseCase {
  final BillsRepository repository;

  const GetBillsUseCase(this.repository);

  Future<Either<Failure, List<BillEntity>>> call({
    required int flatId,
    String? status,
    int? year,
    int? month,
    int page = 1,
  }) =>
      repository.getBills(
        flatId: flatId,
        status: status,
        year: year,
        month: month,
        page: page,
      );
}
