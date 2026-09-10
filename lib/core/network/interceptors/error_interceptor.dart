import 'package:dio/dio.dart';
import '../../error/failures.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = mapToFailure(err);
    final enrichedException = err.copyWith(error: failure);
    handler.next(enrichedException);
  }

  Failure mapToFailure(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.transformTimeout:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return const AuthFailure();
        }
        final data = err.response?.data;
        if (data is Map<String, dynamic> && data['message'] is String) {
          return ServerFailure(data['message'] as String);
        }
        return ServerFailure('Server returned status code $statusCode');
      case DioExceptionType.cancel:
        return const ServerFailure('Request was cancelled');
      case DioExceptionType.badCertificate:
        return const ServerFailure('Bad SSL certificate');
      case DioExceptionType.unknown:
        return ServerFailure(err.message ?? 'An unexpected network error occurred');
    }
  }
}
