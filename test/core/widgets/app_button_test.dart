import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:building_utility_management_system/core/widgets/app_button.dart';

void main() {
  Widget buildTestWidget({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: Scaffold(
          body: AppButton(
            text: text,
            onPressed: onPressed,
            isLoading: isLoading,
          ),
        ),
      ),
    );
  }

  group('AppButton', () {
    testWidgets('displays text and responds to tap when not loading', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        buildTestWidget(
          text: 'Submit',
          onPressed: () => pressed = true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('displays CircularProgressIndicator and does not call onPressed when isLoading is true', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        buildTestWidget(
          text: 'Submit',
          isLoading: true,
          onPressed: () => pressed = true,
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);

      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(pressed, isFalse);
    });
  });
}
