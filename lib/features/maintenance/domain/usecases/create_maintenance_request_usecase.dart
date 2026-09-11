import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/maintenance_request_entity.dart';
import '../repositories/maintenance_repository.dart';

class CreateMaintenanceRequestUseCase {
  final MaintenanceRepository repository;

  const CreateMaintenanceRequestUseCase(this.repository);

  Future<Either<Failure, MaintenanceRequestEntity>> call({
    required int flatId,
    required String title,
    required String description,
    required String category,
    required String priority,
  }) =>
      repository.createRequest(
        flatId: flatId,
        title: title,
        description: description,
        category: category,
        priority: priority,
      );
}
