import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/maintenance_request_entity.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../datasources/maintenance_remote_data_source.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final MaintenanceRemoteDataSource remoteDataSource;

  const MaintenanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MaintenanceRequestEntity>>> getRequests({
    required int flatId,
    String? status,
    int page = 1,
  }) async {
    try {
      final models = await remoteDataSource.getRequests(
        flatId: flatId,
        status: status,
        page: page,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      final failure = e.error is Failure
          ? e.error! as Failure
          : ServerFailure(e.message ?? 'Server error occurred');
      return Left(failure);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceRequestEntity>> getRequestDetails(int id) async {
    try {
      final model = await remoteDataSource.getRequestDetails(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      final failure = e.error is Failure
          ? e.error! as Failure
          : ServerFailure(e.message ?? 'Server error occurred');
      return Left(failure);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceRequestEntity>> createRequest({
    required int flatId,
    required String title,
    required String description,
    required String category,
    required String priority,
  }) async {
    try {
      final model = await remoteDataSource.createRequest(
        flatId: flatId,
        title: title,
        description: description,
        category: category,
        priority: priority,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      final failure = e.error is Failure
          ? e.error! as Failure
          : ServerFailure(e.message ?? 'Server error occurred');
      return Left(failure);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
