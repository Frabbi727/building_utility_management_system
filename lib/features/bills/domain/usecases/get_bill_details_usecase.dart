import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/bill_entity.dart';
import '../repositories/bills_repository.dart';

class GetBillDetailsUseCase {
  final BillsRepository repository;

  const GetBillDetailsUseCase(this.repository);

  Future<Either<Failure, BillEntity>> call(int billId) =>
      repository.getBillDetails(billId);
}
