abstract final class ApiEndpoints {
  static const login = '/auth/login';
  static const refreshToken = '/auth/refresh';
  static const userProfile = '/users/profile';
  static const me = '/auth/me';
  static const fcmToken = '/auth/fcm-token';

  static const residentFlats = '/resident/flats';
  static const residentDashboard = '/resident/dashboard';
  static const residentBills = '/resident/bills';
  static const residentSubmissions = '/resident/payment-submissions';
  static const residentPayments = '/resident/payments';
  static const residentMaintenance = '/resident/maintenance-requests';
  static const residentNotices = '/resident/notices';
}
