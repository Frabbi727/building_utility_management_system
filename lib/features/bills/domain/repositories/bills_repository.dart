import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/bill_entity.dart';

abstract class BillsRepository {
  Future<Either<Failure, List<BillEntity>>> getBills({
    required int flatId,
    String? status,
    int? year,
    int? month,
    int page = 1,
  });

  Future<Either<Failure, BillEntity>> getBillDetails(int billId);
}
