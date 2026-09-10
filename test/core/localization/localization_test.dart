import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:building_utility_management_system/core/localization/app_localizations.dart';
import 'package:building_utility_management_system/core/localization/l10n_ext.dart';

void main() {
  group('Localization', () {
    testWidgets('loads English translations correctly via context extension', (tester) async {
      late String appTitle;
      late String loginBtn;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              appTitle = context.l10n.appName;
              loginBtn = context.l10n.loginButton;
              return Scaffold(body: Text(appTitle));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(appTitle, 'Building Utility Management');
      expect(loginBtn, 'Login');
      expect(find.text('Building Utility Management'), findsOneWidget);
    });

    testWidgets('loads Bengali translations correctly via context extension', (tester) async {
      late String appTitle;
      late String loginBtn;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('bn'),
          home: Builder(
            builder: (context) {
              appTitle = context.l10n.appName;
              loginBtn = context.l10n.loginButton;
              return Scaffold(body: Text(appTitle));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(appTitle, 'বিল্ডিং ইউটিলিটি ম্যানেজমেন্ট');
      expect(loginBtn, 'লগইন');
      expect(find.text('বিল্ডিং ইউটিলিটি ম্যানেজমেন্ট'), findsOneWidget);
    });
  });
}
