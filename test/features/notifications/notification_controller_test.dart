import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:building_utility_management_system/core/base/view_state.dart';
import 'package:building_utility_management_system/features/notifications/domain/entities/notification_entity.dart';
import 'package:building_utility_management_system/features/notifications/domain/repositories/notification_repository.dart';
import 'package:building_utility_management_system/features/notifications/presentation/controllers/notification_controller.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepo;
  late NotificationController controller;

  final tNotification = NotificationEntity(
    id: 1,
    type: 'BILL_GENERATED',
    title: 'New Bill Issued',
    body: 'Bill for Sept 2026',
    data: const {'screen': 'bills'},
    isRead: false,
    createdAt: DateTime(2026, 9, 12),
  );

  setUp(() {
    mockRepo = MockNotificationRepository();

    when(() => mockRepo.getUnreadCount())
        .thenAnswer((_) async => const Right(3));
    when(() => mockRepo.getNotifications(isRead: any(named: 'isRead'), page: any(named: 'page')))
        .thenAnswer((_) async => Right([tNotification]));

    controller = NotificationController(repository: mockRepo);
  });

  group('NotificationController', () {
    test('fetches unread count and notifications on init', () async {
      await controller.fetchUnreadCount();
      await controller.fetchNotifications();

      expect(controller.unreadCount.value, 3);
      expect(controller.notifications.length, 1);
      expect(controller.state.value, isA<SuccessState<List<NotificationEntity>>>());
    });

    test('markAsRead updates state optimistically', () async {
      when(() => mockRepo.markAsRead(1))
          .thenAnswer((_) async => Right(tNotification.copyWith(isRead: true)));

      controller.unreadCount.value = 3;
      controller.notifications.assignAll([tNotification]);

      await controller.markAsRead(tNotification);

      expect(controller.unreadCount.value, 2);
      expect(controller.notifications.first.isRead, true);
    });

    test('markAllAsRead marks all notifications read and resets unreadCount', () async {
      when(() => mockRepo.markAllAsRead())
          .thenAnswer((_) async => const Right(3));

      controller.unreadCount.value = 3;
      controller.notifications.assignAll([tNotification, tNotification.copyWith(id: 2)]);

      await controller.markAllAsRead();

      expect(controller.unreadCount.value, 0);
      expect(controller.notifications.every((n) => n.isRead), true);
    });

    test('setFilter triggers reload with proper parameter', () async {
      when(() => mockRepo.getNotifications(isRead: false, page: any(named: 'page')))
          .thenAnswer((_) async => Right([tNotification]));

      await controller.setFilter('unread');

      expect(controller.selectedFilter.value, 'unread');
      verify(() => mockRepo.getNotifications(isRead: false, page: any(named: 'page'))).called(1);
    });
  });
}
