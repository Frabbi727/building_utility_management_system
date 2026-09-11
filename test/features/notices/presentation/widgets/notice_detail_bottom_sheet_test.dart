import 'package:building_utility_management_system/core/localization/app_localizations.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/notice_snippet_entity.dart';
import 'package:building_utility_management_system/features/notices/presentation/widgets/notice_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const notice = NoticeSnippetEntity(
    id: 1,
    title: 'Water Supply Interruption',
    content: 'Water supply will be suspended on Sunday from 10 AM to 2 PM for pipe repairs.',
    publishedAt: '2026-09-10',
  );

  Widget buildTestWidget() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: NoticeDetailBottomSheet(notice: notice),
        ),
      ),
    );
  }

  testWidgets('NoticeDetailBottomSheet renders title, date, and content', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Water Supply Interruption'), findsOneWidget);
    expect(find.textContaining('Water supply will be suspended'), findsOneWidget);
    expect(find.textContaining('2026-09-10'), findsOneWidget);
  });
}
