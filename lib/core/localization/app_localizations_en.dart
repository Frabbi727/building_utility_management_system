// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Building Utility Management';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginButton => 'Login';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailValidation => 'Please enter a valid email address';

  @override
  String get passwordValidation => 'Password must be at least 6 characters';

  @override
  String get homeTitle => 'Dashboard';

  @override
  String get navHome => 'Home';

  @override
  String get navBills => 'Bills';

  @override
  String get navPayments => 'Payments';

  @override
  String get navMaintenance => 'Maintenance';

  @override
  String get totalDue => 'Total Due';

  @override
  String get advanceHeld => 'Advance Held';

  @override
  String get currentMonthCharges => 'Current Month Charges';

  @override
  String get arrears => 'Arrears';

  @override
  String get payNow => 'Pay Now';

  @override
  String get allClear => 'All Clear';

  @override
  String get noDues => 'No Dues';

  @override
  String get latestBill => 'Latest Bill';

  @override
  String get viewBill => 'View Bill';

  @override
  String get dueDate => 'Due Date';

  @override
  String get buildingNotices => 'Building Notices';

  @override
  String get noNotices => 'No Notices';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get selectFlat => 'Select Flat';

  @override
  String get switchFlat => 'Switch Flat';

  @override
  String get noFlatsAssigned => 'No flats assigned';

  @override
  String get retry => 'Retry';
}
