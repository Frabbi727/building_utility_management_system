abstract final class ApiEndpoints {
  static const login = '/auth/login';
  static const refreshToken = '/auth/refresh';
  static const userProfile = '/users/profile';
  static const me = '/auth/me';
  static const fcmToken = '/auth/fcm-token';

  static const residentFlats = '/resident/flats';
  static const residentDashboard = '/resident/dashboard';
  static const residentBills = '/resident/bills';
  static String residentBillDetails(int id) => '/resident/bills/$id';

  static const residentSubmissions = '/resident/payment-submissions';
  static const residentPaymentSubmissions = '/resident/payment-submissions';
  static const residentPayments = '/resident/payments';
  static String residentPaymentReceipt(int id) => '/resident/payments/$id/receipt';

  static const residentMaintenance = '/resident/maintenance-requests';
  static String residentMaintenanceDetails(int id) => '/resident/maintenance-requests/$id';

  static const residentNotices = '/resident/notices';
  static String residentNoticeDetails(int id) => '/resident/notices/$id';

  static const changePassword = '/auth/change-password';
}
