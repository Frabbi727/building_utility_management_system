# Design Specification: Full Resident Web-Parity (Phase 2)

**Date:** 2026-09-11  
**Target Project:** `building_utility_management_system` (Flutter Mobile App)  
**Backend Reference:** `tonmoy/build-utility-accounts-system` (Laravel 12 / Sanctum API)  
**Status:** Under User Review  

---

## 1. Overview & Business Intent

The goal is to achieve complete functional parity between the Laravel web resident portal and the Flutter mobile app. Currently, the mobile app provides the authenticated shell, global flat context switcher, and the home dashboard overview, while Tabs 1 (`Bills`), 2 (`Payments`), and 3 (`Maintenance`) remain placeholders. 

Phase 2 replaces these placeholders with complete, production-grade feature modules:
1. **Maintenance Ticket Lifecycle & CRUD (Tab 3)**: Create issue tickets with category, priority, and description; track live resolution status; inspect assigned staff and technician notes.
2. **Payments & Proof of Payment Submissions (Tab 2)**: Submit payment slips with photo attachments (bKash, Nagad, Bank, Cash); track submission verification status (`pending`, `approved`, `rejected` with rejection reasons); view verified payment history and download official PDF receipts.
3. **Bills & Itemized Breakdown (Tab 1)**: Filter bills by status/month; view itemized breakdown of charges (metered utilities, fixed maintenance heads, arrears); view/print official PDF bills; quick "Pay Now" bridging.
4. **Notices & Announcements**: Expand dashboard notices into full detail modals; browse paginated building announcements.
5. **Resident Profile & Account Security**: Profile overview with assigned flats; password change flow; language switcher (`en` / `bn`); secure session logout.

---

## 2. Core Architectural Standards

- **Clean Architecture with Feature Isolation**:
  - `domain`: Pure Dart entities and usecases using `fpdart` (`Either<Failure, T>`).
  - `data`: Remote datasources using `Dio`, `@JsonSerializable` DTO models, repository implementations.
  - `presentation`: GetX controllers managing `Rx<ViewState<T>>` sealed states (`InitialState`, `LoadingState`, `SuccessState<T>`, `ErrorState`), modular widgets, and responsive layouts via `flutter_screenutil`.
- **Reactive Flat Context**: All resident queries react to `FlatContextService.selectedFlat.value?.id`. When the resident switches flats, all controllers refresh their data automatically.
- **Multipart Data Handling**: `image_picker` integrated with `Dio` `FormData` to upload payment slip images.
- **External PDF Launching**: `url_launcher` used to securely open backend PDF endpoints (`/payments/{payment}/receipt` and `/bills/{bill}/print`).
- **Complete Localization**: Full parity between `app_en.arb` and `app_bn.arb` for all new UI strings.
- **Strict Quality Gate**: 0 analyzer warnings (`flutter analyze --fatal-infos`) and 100% passing tests (`flutter test`).

---

## 3. Directory Layout & Feature Modules

```
lib/
├── core/
│   ├── constants/
│   │   └── api_endpoints.dart         # Extended with bills, payments, maintenance, notices routes
│   └── localization/l10n/
│       ├── app_en.arb                 # Added English strings for all 4 features
│       └── app_bn.arb                 # Added Bangla strings for all 4 features
├── features/
│   ├── maintenance/
│   │   ├── data/
│   │   │   ├── datasources/maintenance_remote_data_source.dart
│   │   │   ├── models/maintenance_request_model.dart
│   │   │   └── repositories/maintenance_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/maintenance_request_entity.dart
│   │   │   ├── repositories/maintenance_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_maintenance_requests_usecase.dart
│   │   │       ├── get_maintenance_details_usecase.dart
│   │   │       └── create_maintenance_request_usecase.dart
│   │   └── presentation/
│   │       ├── bindings/maintenance_binding.dart
│   │       ├── controllers/maintenance_controller.dart
│   │       ├── screens/
│   │       │   ├── maintenance_screen.dart
│   │       │   └── maintenance_details_screen.dart
│   │       └── widgets/
│   │           ├── maintenance_card.dart
│   │           ├── maintenance_filter_bar.dart
│   │           └── create_ticket_bottom_sheet.dart
│   ├── payments/
│   │   ├── data/
│   │   │   ├── datasources/payments_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   ├── payment_model.dart
│   │   │   │   └── payment_submission_model.dart
│   │   │   └── repositories/payments_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── payment_entity.dart
│   │   │   │   └── payment_submission_entity.dart
│   │   │   ├── repositories/payments_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_payments_usecase.dart
│   │   │       ├── get_payment_submissions_usecase.dart
│   │   │       └── submit_payment_usecase.dart
│   │   └── presentation/
│   │       ├── bindings/payments_binding.dart
│   │       ├── controllers/payments_controller.dart
│   │       ├── screens/payments_screen.dart
│   │       └── widgets/
│   │           ├── verified_payments_list.dart
│   │           ├── payment_submissions_list.dart
│   │           ├── submit_payment_bottom_sheet.dart
│   │           └── slip_image_picker_field.dart
│   ├── bills/
│   │   ├── data/
│   │   │   ├── datasources/bills_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   ├── bill_model.dart
│   │   │   │   └── bill_item_model.dart
│   │   │   └── repositories/bills_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── bill_entity.dart
│   │   │   │   └── bill_item_entity.dart
│   │   │   ├── repositories/bills_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_bills_usecase.dart
│   │   │       └── get_bill_details_usecase.dart
│   │   └── presentation/
│   │       ├── bindings/bills_binding.dart
│   │       ├── controllers/bills_controller.dart
│   │       ├── screens/
│   │       │   ├── bills_screen.dart
│   │       │   └── bill_details_screen.dart
│   │       └── widgets/
│   │           ├── bill_card.dart
│   │           ├── bill_items_list.dart
│   │           └── bill_status_chip.dart
│   ├── notices/
│   │   ├── presentation/
│   │   │   └── widgets/notice_detail_bottom_sheet.dart
│   └── profile/
│       └── presentation/
│           ├── screens/profile_screen.dart
│           └── widgets/change_password_dialog.dart
```

---

## 4. Detailed Feature Specifications

### 4.1 Maintenance Tickets (Tab 3)
- **API Endpoints**:
  - `GET /api/v1/resident/maintenance-requests?flat_id={flat_id}&status={status}&page={page}`
  - `POST /api/v1/resident/maintenance-requests` (JSON payload: `flat_id`, `title`, `description`, `category`, `priority`)
  - `GET /api/v1/resident/maintenance-requests/{id}`
- **Enums Supported**:
  - `category`: `plumbing`, `electrical`, `elevator`, `cleaning`, `security`, `other`
  - `priority`: `low`, `medium`, `high`, `emergency`
  - `status`: `open`, `in_progress`, `resolved`, `closed`
- **UI Flow**:
  - `MaintenanceScreen` features a status pill filter (`All`, `Open`, `In Progress`, `Resolved`, `Closed`).
  - Cards show category icons, priority chips with warning colors, and resolution status.
  - Floating Action Button triggers `CreateTicketBottomSheet`.
  - Form validation ensures required fields and max lengths match backend rules.
  - On submission: optimistic/immediate refresh with localized success snackbar.
  - Tapping a ticket opens `MaintenanceDetailsScreen` displaying a timeline (`Submitted` ➔ `In Progress` ➔ `Resolved` ➔ `Closed`), assigned staff/technician, and resolution notes.

### 4.2 Payments & Submissions (Tab 2)
- **API Endpoints**:
  - `GET /api/v1/resident/payment-submissions?flat_id={flat_id}&status={status}&page={page}`
  - `POST /api/v1/resident/payment-submissions` (`multipart/form-data`: `flat_id`, `amount`, `payment_method`, `reference_number`, `payment_date`, `resident_notes`, `slip` file)
  - `GET /api/v1/resident/payments?flat_id={flat_id}&page={page}`
  - `GET /api/v1/resident/payments/{id}/receipt` (returns receipt URL)
- **Enums Supported**:
  - `payment_method`: `bkash`, `nagad`, `bank`, `cash`
  - `submission_status`: `pending`, `approved`, `rejected`
- **UI Flow**:
  - Segmented control toggles between **Verified Payments** and **My Submissions**.
  - Top card displays ledger balances (`Total Due` and `Advance Held`).
  - "Submit Payment Proof" button opens `SubmitPaymentBottomSheet`:
    - Payment method selector with MFS branding (bKash pink, Nagad orange, Bank blue).
    - Date picker (defaults to today).
    - Amount field with currency formatting.
    - Reference Number / TrxID text input.
    - Camera/Gallery image picker for deposit slip / transaction screenshot with thumbnail preview and remove button.
  - Verified Payments card features a "Download Receipt" action that opens the PDF link using `url_launcher`.
  - Rejected Submissions card highlights the manager's `rejection_reason` in an alert callout.

### 4.3 Bills & Itemized Breakdown (Tab 1)
- **API Endpoints**:
  - `GET /api/v1/resident/bills?flat_id={flat_id}&status={status}&page={page}`
  - `GET /api/v1/resident/bills/{id}` (returns month charges, arrears, total amount, and items list)
- **Enums Supported**:
  - `status`: `unpaid`, `partially_paid`, `paid`
- **UI Flow**:
  - Filter chips: `All`, `Unpaid`, `Partially Paid`, `Paid`.
  - Bill card shows bill number, billing month (`September 2026`), total amount, due date, and overdue warning badge.
  - Tapping "View Breakdown" navigates to `BillDetailsScreen`:
    - Summary section: Current Month Charges + Prior Arrears = Total Payable.
    - Itemized charge list displaying description, unit calculation (`quantity @ unit_rate`), and total amount.
    - "Print Bill PDF" button launching the backend printable bill URL.
    - "Pay Now" shortcut passing amount and bill number directly into `SubmitPaymentBottomSheet`.

### 4.4 Notices & Profile
- **Notices**: Tapping any notice card on the Dashboard opens `NoticeDetailBottomSheet` displaying title, full body text, category tag, publication date, and pin badge.
- **Profile Screen**: Accessible via avatar button in the top AppBar:
  - Displays resident name, email, phone, role badge (Owner / Tenant), and linked flats.
  - "Change Password" dialog validating current password and confirming new password.
  - Language toggle (`English` / `বাংলা`).
  - "Logout" confirmation dialog that calls `POST /api/v1/auth/logout`, clears tokens from secure storage, and routes to `LoginScreen`.

---

## 5. Dependencies to Add

Add to `pubspec.yaml`:
```yaml
dependencies:
  image_picker: ^1.1.2
  url_launcher: ^6.3.0
```

---

## 6. Error Handling & Edge Cases

1. **Token Expiry / 401 Unauthorized**: Intercepted in `DioClient` to auto-clear session and route to `LoginScreen`.
2. **Offline / Network Drop**: Handled via `NetworkFailure` in repositories, displaying retry buttons and empty-state placeholders.
3. **No Linked Flats**: Gracefully handled by disabling action sheets and displaying warning to contact building manager.
4. **Large Slip Images**: Compressed/restricted to max 5MB prior to upload to prevent timeout or payload rejection.
5. **No Camera / Gallery Permission**: Gracefully caught with localized permission explanation dialogs.

---

## 7. Testing & Verification Plan

- **Unit Tests**:
  - DTO serialization/deserialization tests for `BillModel`, `BillItemModel`, `PaymentModel`, `PaymentSubmissionModel`, `MaintenanceRequestModel`.
  - Repository tests with mocked datasources verifying success and failure paths.
  - Controller tests verifying reactive state transitions across filter changes and submissions.
- **Widget Tests**:
  - `MaintenanceScreen` rendering ticket cards and empty states.
  - `SubmitPaymentBottomSheet` form validation and method selection.
  - `BillDetailsScreen` itemized charge table rendering.
- **Analysis Check**:
  - `flutter analyze --fatal-infos` (0 issues).
  - `flutter test` (100% passing).
