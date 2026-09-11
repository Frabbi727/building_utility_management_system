import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/maintenance_request_entity.dart';

abstract class MaintenanceRepository {
  Future<Either<Failure, List<MaintenanceRequestEntity>>> getRequests({
    required int flatId,
    String? status,
    int page = 1,
  });

  Future<Either<Failure, MaintenanceRequestEntity>> getRequestDetails(int id);

  Future<Either<Failure, MaintenanceRequestEntity>> createRequest({
    required int flatId,
    required String title,
    required String description,
    required String category,
    required String priority,
  });
}
