import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:building_utility_management_system/core/theme/app_colors.dart';
import 'package:building_utility_management_system/core/theme/app_theme.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(home: child),
    );
  }

  group('AppTheme', () {
    testWidgets('light theme returns valid Material 3 ThemeData with correct colors', (tester) async {
      await tester.pumpWidget(buildTestWidget(child: const SizedBox()));

      final theme = AppTheme.light();

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.surface, AppColors.surfaceLight);
      expect(theme.colorScheme.error, AppColors.error);
      expect(theme.scaffoldBackgroundColor, AppColors.backgroundLight);
      expect(theme.textTheme.headlineLarge?.color, AppColors.textPrimaryLight);
      expect(theme.textTheme.bodyMedium?.color, AppColors.textPrimaryLight);
      expect(theme.textTheme.labelMedium?.color, AppColors.textSecondaryLight);
    });

    testWidgets('dark theme returns valid Material 3 ThemeData with correct colors', (tester) async {
      await tester.pumpWidget(buildTestWidget(child: const SizedBox()));

      final theme = AppTheme.dark();

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.surface, AppColors.surfaceDark);
      expect(theme.colorScheme.error, AppColors.error);
      expect(theme.scaffoldBackgroundColor, AppColors.backgroundDark);
      expect(theme.textTheme.headlineLarge?.color, AppColors.textPrimaryDark);
      expect(theme.textTheme.bodyMedium?.color, AppColors.textPrimaryDark);
      expect(theme.textTheme.labelMedium?.color, AppColors.textSecondaryDark);
    });
  });
}
