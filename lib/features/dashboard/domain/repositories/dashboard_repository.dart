import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/flat_entity.dart';
import '../entities/dashboard_data_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardDataEntity>> getDashboardData({
    required int flatId,
  });

  Future<Either<Failure, List<FlatEntity>>> getResidentFlats();
}
