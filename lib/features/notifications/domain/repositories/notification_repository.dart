import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    bool? isRead,
    int page = 1,
  });

  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, NotificationEntity>> markAsRead(int notificationId);

  Future<Either<Failure, int>> markAllAsRead();
}
