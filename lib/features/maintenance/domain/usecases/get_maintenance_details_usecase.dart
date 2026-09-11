import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/maintenance_request_entity.dart';
import '../repositories/maintenance_repository.dart';

class GetMaintenanceDetailsUseCase {
  final MaintenanceRepository repository;

  const GetMaintenanceDetailsUseCase(this.repository);

  Future<Either<Failure, MaintenanceRequestEntity>> call(int id) =>
      repository.getRequestDetails(id);
}
