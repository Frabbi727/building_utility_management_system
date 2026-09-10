import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/dashboard_data_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardDataUseCase {
  final DashboardRepository repository;

  const GetDashboardDataUseCase(this.repository);

  Future<Either<Failure, DashboardDataEntity>> call({
    required int flatId,
  }) =>
      repository.getDashboardData(flatId: flatId);
}
