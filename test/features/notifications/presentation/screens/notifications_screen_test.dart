import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:building_utility_management_system/core/localization/app_localizations.dart';
import 'package:building_utility_management_system/core/widgets/confirm_dialog.dart';
import 'package:building_utility_management_system/features/notifications/domain/entities/notification_entity.dart';
import 'package:building_utility_management_system/features/notifications/domain/repositories/notification_repository.dart';
import 'package:building_utility_management_system/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:building_utility_management_system/features/notifications/presentation/screens/notifications_screen.dart';

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
    when(() => mockRepo.getUnreadCount()).thenAnswer((_) async => const Right(1));
    when(() => mockRepo.getNotifications(isRead: any(named: 'isRead'), page: any(named: 'page')))
        .thenAnswer((_) async => Right([tNotification]));
    when(() => mockRepo.markAllAsRead()).thenAnswer((_) async => const Right(1));

    controller = NotificationController(repository: mockRepo);
    Get.replace<NotificationController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  Widget createWidget() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => const GetMaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: NotificationsScreen(),
      ),
    );
  }

  testWidgets('tapping Mark all read displays ConfirmDialog before executing', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    final markAllButton = find.text('Mark all read');
    expect(markAllButton, findsOneWidget);

    // Tap button to open safety dialog
    await tester.tap(markAllButton);
    await tester.pumpAndSettle();

    expect(find.byType(ConfirmDialog), findsOneWidget);
    expect(find.text('Are you sure you want to mark all notifications as read?'), findsOneWidget);

    // Cancel does not invoke repository
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => mockRepo.markAllAsRead());

    // Tap again and confirm
    await tester.tap(markAllButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    verify(() => mockRepo.markAllAsRead()).called(1);
  });
}
