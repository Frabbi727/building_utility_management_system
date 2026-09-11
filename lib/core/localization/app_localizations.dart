import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Building Utility Management'**
  String get appName;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @emailValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailValidation;

  /// No description provided for @passwordValidation.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordValidation;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get homeTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get navBills;

  /// No description provided for @navPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get navPayments;

  /// No description provided for @navMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get navMaintenance;

  /// No description provided for @totalDue.
  ///
  /// In en, this message translates to:
  /// **'Total Due'**
  String get totalDue;

  /// No description provided for @advanceHeld.
  ///
  /// In en, this message translates to:
  /// **'Advance Held'**
  String get advanceHeld;

  /// No description provided for @currentMonthCharges.
  ///
  /// In en, this message translates to:
  /// **'Current Month Charges'**
  String get currentMonthCharges;

  /// No description provided for @arrears.
  ///
  /// In en, this message translates to:
  /// **'Arrears'**
  String get arrears;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @allClear.
  ///
  /// In en, this message translates to:
  /// **'All Clear'**
  String get allClear;

  /// No description provided for @noDues.
  ///
  /// In en, this message translates to:
  /// **'No Dues'**
  String get noDues;

  /// No description provided for @latestBill.
  ///
  /// In en, this message translates to:
  /// **'Latest Bill'**
  String get latestBill;

  /// No description provided for @viewBill.
  ///
  /// In en, this message translates to:
  /// **'View Bill'**
  String get viewBill;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @buildingNotices.
  ///
  /// In en, this message translates to:
  /// **'Building Notices'**
  String get buildingNotices;

  /// No description provided for @noNotices.
  ///
  /// In en, this message translates to:
  /// **'No Notices'**
  String get noNotices;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @selectFlat.
  ///
  /// In en, this message translates to:
  /// **'Select Flat'**
  String get selectFlat;

  /// No description provided for @switchFlat.
  ///
  /// In en, this message translates to:
  /// **'Switch Flat'**
  String get switchFlat;

  /// No description provided for @noFlatsAssigned.
  ///
  /// In en, this message translates to:
  /// **'No flats assigned'**
  String get noFlatsAssigned;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get empty;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @maintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Requests'**
  String get maintenanceTitle;

  /// No description provided for @createTicket.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get createTicket;

  /// No description provided for @ticketTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get ticketTitle;

  /// No description provided for @ticketCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get ticketCategory;

  /// No description provided for @ticketPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get ticketPriority;

  /// No description provided for @ticketDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get ticketDescription;

  /// No description provided for @enterTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter issue title'**
  String get enterTicketTitle;

  /// No description provided for @enterTicketDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue in detail'**
  String get enterTicketDescription;

  /// No description provided for @assignedTo.
  ///
  /// In en, this message translates to:
  /// **'Assigned To'**
  String get assignedTo;

  /// No description provided for @resolutionNotes.
  ///
  /// In en, this message translates to:
  /// **'Resolution Notes'**
  String get resolutionNotes;

  /// No description provided for @resolvedAt.
  ///
  /// In en, this message translates to:
  /// **'Resolved At'**
  String get resolvedAt;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get priorityEmergency;

  /// No description provided for @categoryPlumbing.
  ///
  /// In en, this message translates to:
  /// **'Plumbing'**
  String get categoryPlumbing;

  /// No description provided for @categoryElectrical.
  ///
  /// In en, this message translates to:
  /// **'Electrical'**
  String get categoryElectrical;

  /// No description provided for @categoryElevator.
  ///
  /// In en, this message translates to:
  /// **'Elevator'**
  String get categoryElevator;

  /// No description provided for @categoryCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get categoryCleaning;

  /// No description provided for @categorySecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get categorySecurity;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @ticketSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request submitted successfully'**
  String get ticketSubmitted;

  /// No description provided for @noMaintenanceRequests.
  ///
  /// In en, this message translates to:
  /// **'No maintenance requests found'**
  String get noMaintenanceRequests;

  /// No description provided for @verifiedPayments.
  ///
  /// In en, this message translates to:
  /// **'Verified Payments'**
  String get verifiedPayments;

  /// No description provided for @paymentSubmissions.
  ///
  /// In en, this message translates to:
  /// **'Submissions'**
  String get paymentSubmissions;

  /// No description provided for @submitPaymentProof.
  ///
  /// In en, this message translates to:
  /// **'Submit Payment Proof'**
  String get submitPaymentProof;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference / TrxID'**
  String get referenceNumber;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// No description provided for @uploadSlip.
  ///
  /// In en, this message translates to:
  /// **'Attach Receipt / Slip'**
  String get uploadSlip;

  /// No description provided for @pickCamera.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get pickCamera;

  /// No description provided for @pickGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get pickGallery;

  /// No description provided for @slipImageRequired.
  ///
  /// In en, this message translates to:
  /// **'Slip attachment is optional'**
  String get slipImageRequired;

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get rejectionReason;

  /// No description provided for @downloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get downloadReceipt;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Verification'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @paymentSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Payment proof submitted successfully'**
  String get paymentSubmitted;

  /// No description provided for @methodBkash.
  ///
  /// In en, this message translates to:
  /// **'bKash'**
  String get methodBkash;

  /// No description provided for @methodNagad.
  ///
  /// In en, this message translates to:
  /// **'Nagad'**
  String get methodNagad;

  /// No description provided for @methodBank.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get methodBank;

  /// No description provided for @methodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get methodCash;

  /// No description provided for @noPaymentsFound.
  ///
  /// In en, this message translates to:
  /// **'No payments found'**
  String get noPaymentsFound;

  /// No description provided for @noSubmissionsFound.
  ///
  /// In en, this message translates to:
  /// **'No submissions found'**
  String get noSubmissionsFound;

  /// No description provided for @billsTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Charge Bills'**
  String get billsTitle;

  /// No description provided for @billBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Bill Breakdown'**
  String get billBreakdown;

  /// No description provided for @itemizedCharges.
  ///
  /// In en, this message translates to:
  /// **'Itemized Charges'**
  String get itemizedCharges;

  /// No description provided for @monthCharges.
  ///
  /// In en, this message translates to:
  /// **'Current Month Charges'**
  String get monthCharges;

  /// No description provided for @totalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total Payable'**
  String get totalPayable;

  /// No description provided for @printBill.
  ///
  /// In en, this message translates to:
  /// **'Print Bill PDF'**
  String get printBill;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get statusUnpaid;

  /// No description provided for @statusPartiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get statusPartiallyPaid;

  /// No description provided for @noBillsFound.
  ///
  /// In en, this message translates to:
  /// **'No bills found'**
  String get noBillsFound;

  /// No description provided for @allNotices.
  ///
  /// In en, this message translates to:
  /// **'All Notices'**
  String get allNotices;

  /// No description provided for @noticeDetails.
  ///
  /// In en, this message translates to:
  /// **'Notice Details'**
  String get noticeDetails;

  /// No description provided for @pinnedNotice.
  ///
  /// In en, this message translates to:
  /// **'Pinned Notice'**
  String get pinnedNotice;

  /// No description provided for @publishedOn.
  ///
  /// In en, this message translates to:
  /// **'Published on'**
  String get publishedOn;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Resident Profile'**
  String get profileTitle;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordChanged;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @assignedFlats.
  ///
  /// In en, this message translates to:
  /// **'Assigned Flats'**
  String get assignedFlats;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleTenant.
  ///
  /// In en, this message translates to:
  /// **'Tenant'**
  String get roleTenant;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
