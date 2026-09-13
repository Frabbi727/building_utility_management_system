import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final DioClient dioClient;

  const NotificationRepositoryImpl({required this.dioClient});

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    bool? isRead,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (isRead != null) {
        queryParams['is_read'] = isRead ? '1' : '0';
      }

      final response = await dioClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.notifications,
        queryParameters: queryParams,
      );

      final rawData = response.data;
      if (rawData == null) return const Right(<NotificationEntity>[]);

      final dataList = rawData['data'] is List ? rawData['data'] as List : <dynamic>[];
      final models = dataList
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .map((m) => m.toEntity())
          .toList();

      return Right(models);
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
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final response = await dioClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.unreadNotificationsCount,
      );

      final rawData = response.data;
      final dataMap = rawData?['data'] as Map<String, dynamic>?;
      final count = dataMap?['unread_count'] as int? ?? 0;

      return Right(count);
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
  Future<Either<Failure, NotificationEntity>> markAsRead(int notificationId) async {
    try {
      final response = await dioClient.dio.patch<Map<String, dynamic>>(
        ApiEndpoints.markNotificationRead(notificationId),
      );

      final rawData = response.data;
      final dataMap = rawData?['data'] as Map<String, dynamic>? ?? {};
      final model = NotificationModel.fromJson(dataMap);

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
  Future<Either<Failure, int>> markAllAsRead() async {
    try {
      final response = await dioClient.dio.patch<Map<String, dynamic>>(
        ApiEndpoints.markAllNotificationsRead,
      );

      final rawData = response.data;
      final dataMap = rawData?['data'] as Map<String, dynamic>?;
      final count = dataMap?['updated_count'] as int? ?? 0;

      return Right(count);
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
