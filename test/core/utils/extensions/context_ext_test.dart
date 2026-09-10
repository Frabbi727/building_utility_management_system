import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:building_utility_management_system/core/utils/extensions/context_ext.dart';

void main() {
  group('ContextExt', () {
    testWidgets('provides screen dimensions and theme properties via extensions', (tester) async {
      late double width;
      late double height;
      late ThemeData theme;
      late ColorScheme colors;
      late TextTheme textTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              width = context.screenWidth;
              height = context.screenHeight;
              theme = context.theme;
              colors = context.colors;
              textTheme = context.textTheme;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(width, greaterThan(0));
      expect(height, greaterThan(0));
      expect(theme, isNotNull);
      expect(colors, isNotNull);
      expect(textTheme, isNotNull);
    });
  });
}
