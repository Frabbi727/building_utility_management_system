import 'package:building_utility_management_system/core/localization/app_localizations.dart';
import 'package:building_utility_management_system/features/dashboard/domain/entities/resident_balances_entity.dart';
import 'package:building_utility_management_system/features/dashboard/presentation/widgets/balance_hero_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('renders total due, breakdown, and Pay Now button when due > 0',
      (tester) async {
    bool payNowTapped = false;
    const balances = ResidentBalancesEntity(
      totalDue: '5000.00',
      advanceHeld: '500.00',
      currentMonthCharges: '4500.00',
      arrears: '500.00',
    );

    await tester.pumpWidget(
      buildTestWidget(
        child: BalanceHeroCard(
          balances: balances,
          onPayNow: () => payNowTapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('৳ 5000.00'), findsOneWidget);
    expect(find.text('Advance Held: ৳ 500.00'), findsOneWidget);
    expect(find.text('৳ 4500.00'), findsOneWidget);
    expect(find.text('৳ 500.00'), findsOneWidget);
    expect(find.text('Pay Now'), findsOneWidget);

    await tester.tap(find.text('Pay Now'));
    expect(payNowTapped, isTrue);
  });

  testWidgets('renders All Clear badge and hides Pay Now button when due == 0',
      (tester) async {
    const balances = ResidentBalancesEntity(
      totalDue: '0.00',
      advanceHeld: '0.00',
      currentMonthCharges: '0.00',
      arrears: '0.00',
    );

    await tester.pumpWidget(
      buildTestWidget(
        child: const BalanceHeroCard(balances: balances),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('৳ 0.00'), findsAtLeast(1));
    expect(find.text('All Clear'), findsOneWidget);
    expect(find.text('Pay Now'), findsNothing);
  });
}
