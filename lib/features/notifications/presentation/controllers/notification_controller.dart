import 'package:get/get.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/routing/notification_router.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository repository;

  NotificationController({required this.repository});

  final Rx<ViewState> state = Rx<ViewState>(const IdleState());
  final RxList<NotificationEntity> notifications = <NotificationEntity>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxString selectedFilter = 'all'.obs;
  final RxBool isMarkingAll = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUnreadCount();
    fetchNotifications();
  }

  Future<void> fetchUnreadCount() async {
    final result = await repository.getUnreadCount();
    result.fold(
      (failure) => null,
      (count) => unreadCount.value = count,
    );
  }

  Future<void> fetchNotifications({bool isRefresh = false}) async {
    if (!isRefresh) {
      state.value = const LoadingState();
    }

    bool? isReadParam;
    if (selectedFilter.value == 'unread') {
      isReadParam = false;
    } else if (selectedFilter.value == 'read') {
      isReadParam = true;
    }

    final result = await repository.getNotifications(isRead: isReadParam);

    result.fold(
      (failure) => state.value = ErrorState(failure.message),
      (data) {
        notifications.assignAll(data);
        state.value = SuccessState<List<NotificationEntity>>(data);
      },
    );
  }

  Future<void> setFilter(String filter) async {
    if (selectedFilter.value == filter) return;
    selectedFilter.value = filter;
    await fetchNotifications();
  }

  Future<void> markAsRead(NotificationEntity notification) async {
    if (notification.isRead) return;

    // Optimistic update
    final index = notifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      notifications[index] = notification.copyWith(isRead: true, readAt: DateTime.now());
      if (unreadCount.value > 0) {
        unreadCount.value--;
      }
    }

    final result = await repository.markAsRead(notification.id);
    result.fold(
      (failure) {
        // Revert on failure
        if (index != -1) {
          notifications[index] = notification;
          unreadCount.value++;
        }
      },
      (updated) {
        if (index != -1) {
          notifications[index] = updated;
        }
      },
    );
  }

  Future<void> markAllAsRead() async {
    if (isMarkingAll.value || unreadCount.value == 0) return;
    isMarkingAll.value = true;

    // Optimistic update
    final previousList = List<NotificationEntity>.from(notifications);
    final previousCount = unreadCount.value;

    notifications.assignAll(
      notifications.map((n) => n.copyWith(isRead: true, readAt: DateTime.now())).toList(),
    );
    unreadCount.value = 0;

    final result = await repository.markAllAsRead();
    result.fold(
      (failure) {
        notifications.assignAll(previousList);
        unreadCount.value = previousCount;
      },
      (updatedCount) {
        // Success
      },
    );

    isMarkingAll.value = false;
  }

  void onNotificationTap(NotificationEntity notification) {
    markAsRead(notification);

    final payload = <String, dynamic>{
      'type': notification.type,
      'reference_id': notification.referenceId,
    };

    if (notification.data != null) {
      payload.addAll(notification.data!);
    }

    NotificationRouter.handlePayload(payload);
  }
}
