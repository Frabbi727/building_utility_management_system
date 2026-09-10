import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/flat_entity.dart';
import '../../domain/entities/dashboard_data_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  const DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DashboardDataEntity>> getDashboardData({
    required int flatId,
  }) async {
    try {
      final model = await remoteDataSource.getDashboardData(flatId: flatId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      final failure = e.error is Failure
          ? e.error! as Failure
          : ServerFailure(e.message ?? 'Server error occurred');
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FlatEntity>>> getResidentFlats() async {
    try {
      final models = await remoteDataSource.getResidentFlats();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      final failure = e.error is Failure
          ? e.error! as Failure
          : ServerFailure(e.message ?? 'Server error occurred');
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
