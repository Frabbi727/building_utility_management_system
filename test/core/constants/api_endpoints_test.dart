import 'package:flutter_test/flutter_test.dart';
import 'package:building_utility_management_system/core/constants/api_endpoints.dart';

void main() {
  group('ApiEndpoints parity check', () {
    test('contains all resident web parity routes and parameterized helpers', () {
      expect(ApiEndpoints.residentBills, '/resident/bills');
      expect(ApiEndpoints.residentBillDetails(1), '/resident/bills/1');
      expect(ApiEndpoints.residentPaymentSubmissions, '/resident/payment-submissions');
      expect(ApiEndpoints.residentPayments, '/resident/payments');
      expect(ApiEndpoints.residentPaymentReceipt(1), '/resident/payments/1/receipt');
      expect(ApiEndpoints.residentMaintenance, '/resident/maintenance-requests');
      expect(ApiEndpoints.residentMaintenanceDetails(1), '/resident/maintenance-requests/1');
      expect(ApiEndpoints.residentNotices, '/resident/notices');
      expect(ApiEndpoints.residentNoticeDetails(1), '/resident/notices/1');
      expect(ApiEndpoints.changePassword, '/auth/change-password');
    });
  });
}
