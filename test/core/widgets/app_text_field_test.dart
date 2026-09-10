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

    testWidgets('passes keyboardType, textInputAction, icons, and fires onChanged', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: AppTextField(
                labelText: 'Username',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.person),
                suffixIcon: const Icon(Icons.check),
                onChanged: (val) => changedValue = val,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField),
          matching: find.byType(TextField),
        ),
      );
      expect(textField.keyboardType, TextInputType.emailAddress);
      expect(textField.textInputAction, TextInputAction.next);

      await tester.enterText(find.byType(TextFormField), 'alice');
      expect(changedValue, 'alice');
    });

    testWidgets('executes validator with GlobalKey<FormState>', (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: AppTextField(
                  labelText: 'Required Field',
                  controller: controller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Field cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final isInitialValid = formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(isInitialValid, isFalse);
      expect(find.text('Field cannot be empty'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Valid text');
      final isAfterInputValid = formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(isAfterInputValid, isTrue);
      expect(find.text('Field cannot be empty'), findsNothing);
    });
  });
}
