import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'network_info.dart';

class DioClient {
  late final Dio dio;

  DioClient({
    required String baseUrl,
    required SecureStorageService storage,
    required NetworkInfo networkInfo,
    void Function()? onAuthenticationExpired,
    Dio? customDio,
  }) {
    dio = customDio ??
        Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

    dio.interceptors.removeImplyContentTypeInterceptor();
    dio.interceptors.addAll([
      ConnectivityInterceptor(networkInfo),
      AuthInterceptor(
        storage: storage,
        baseUrl: baseUrl,
        onAuthenticationExpired: onAuthenticationExpired,
      ),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }
}
