import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:building_utility_management_system/core/widgets/app_text_field.dart';

void main() {
  Widget buildTestWidget({
    required String labelText,
    TextEditingController? controller,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        home: Scaffold(
          body: AppTextField(
            labelText: labelText,
            controller: controller,
            obscureText: obscureText,
            validator: validator,
          ),
        ),
      ),
    );
  }

  group('AppTextField', () {
    testWidgets('renders with label text and accepts text input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Email',
          controller: controller,
        ),
      );

      expect(find.text('Email'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      expect(controller.text, 'test@example.com');
    });

    testWidgets('obscureText obscures password input', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          labelText: 'Password',
          obscureText: true,
        ),
      );

      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField),
          matching: find.byType(TextField),
        ),
      );
      expect(textField.obscureText, isTrue);
    });
  });
}
