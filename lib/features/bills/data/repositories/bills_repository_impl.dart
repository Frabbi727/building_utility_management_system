import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/bill_entity.dart';
import '../../domain/repositories/bills_repository.dart';
import '../datasources/bills_remote_data_source.dart';

class BillsRepositoryImpl implements BillsRepository {
  final BillsRemoteDataSource remoteDataSource;

  const BillsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BillEntity>>> getBills({
    required int flatId,
    String? status,
    int? year,
    int? month,
    int page = 1,
  }) async {
    try {
      final models = await remoteDataSource.getBills(
        flatId: flatId,
        status: status,
        year: year,
        month: month,
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
  Future<Either<Failure, BillEntity>> getBillDetails(int billId) async {
    try {
      final model = await remoteDataSource.getBillDetails(billId);
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
