import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_submission_entity.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_remote_data_source.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource remoteDataSource;

  const PaymentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPayments({
    required int flatId,
    int page = 1,
  }) async {
    try {
      final models = await remoteDataSource.getPayments(flatId: flatId, page: page);
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
  Future<Either<Failure, String>> getReceipt(int paymentId) async {
    try {
      final url = await remoteDataSource.getReceipt(paymentId);
      return Right(url);
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
  Future<Either<Failure, List<PaymentSubmissionEntity>>> getSubmissions({
    required int flatId,
    String? status,
    int page = 1,
  }) async {
    try {
      final models = await remoteDataSource.getSubmissions(
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
  Future<Either<Failure, PaymentSubmissionEntity>> submitPayment({
    required int flatId,
    required String amount,
    required String method,
    required String referenceNumber,
    required String paymentDate,
    String? notes,
    String? slipFilePath,
  }) async {
    try {
      final model = await remoteDataSource.submitPayment(
        flatId: flatId,
        amount: amount,
        method: method,
        referenceNumber: referenceNumber,
        paymentDate: paymentDate,
        notes: notes,
        slipFilePath: slipFilePath,
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
