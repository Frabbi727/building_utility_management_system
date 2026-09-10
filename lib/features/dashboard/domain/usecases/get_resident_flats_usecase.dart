import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/flat_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetResidentFlatsUseCase {
  final DashboardRepository repository;

  const GetResidentFlatsUseCase(this.repository);

  Future<Either<Failure, List<FlatEntity>>> call() =>
      repository.getResidentFlats();
}
