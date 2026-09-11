import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/maintenance_request_entity.dart';
import '../repositories/maintenance_repository.dart';

class GetMaintenanceRequestsUseCase {
  final MaintenanceRepository repository;

  const GetMaintenanceRequestsUseCase(this.repository);

  Future<Either<Failure, List<MaintenanceRequestEntity>>> call({
    required int flatId,
    String? status,
    int page = 1,
  }) =>
      repository.getRequests(
        flatId: flatId,
        status: status,
        page: page,
      );
}
