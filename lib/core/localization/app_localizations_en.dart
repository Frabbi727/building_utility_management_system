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
}
