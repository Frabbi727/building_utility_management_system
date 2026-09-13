import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:building_utility_management_system/core/widgets/confirm_dialog.dart';

void main() {
  Widget buildTestWidget({
    required String title,
    required String message,
    Map<String, String>? details,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDanger = false,
    required void Function(bool? result) onResult,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                final res = await ConfirmDialog.show(
                  ctx,
                  title: title,
                  message: message,
                  details: details,
                  confirmText: confirmText,
                  cancelText: cancelText,
                  isDanger: isDanger,
                );
                onResult(res);
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  group('ConfirmDialog', () {
    testWidgets('renders title, message, and details table', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          title: 'Confirm Payment',
          message: 'Please review before proceeding.',
          details: {
            'Amount': '৳ 5,000',
            'Method': 'bKash',
          },
          onResult: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Payment'), findsOneWidget);
      expect(find.text('Please review before proceeding.'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('৳ 5,000'), findsOneWidget);
      expect(find.text('Method'), findsOneWidget);
      expect(find.text('bKash'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('tapping confirm returns true', (tester) async {
      bool? result;

      await tester.pumpWidget(
        buildTestWidget(
          title: 'Confirm Action',
          message: 'Are you sure?',
          confirmText: 'Yes, Submit',
          cancelText: 'No, Cancel',
          onResult: (res) => result = res,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yes, Submit'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tapping cancel returns false', (tester) async {
      bool? result;

      await tester.pumpWidget(
        buildTestWidget(
          title: 'Confirm Action',
          message: 'Are you sure?',
          confirmText: 'Yes',
          cancelText: 'Dismiss',
          onResult: (res) => result = res,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('supports isDanger mode with warning icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          title: 'Delete Item',
          message: 'This cannot be undone.',
          isDanger: true,
          onResult: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });
}
