import 'package:dio/dio.dart';
import '../../constants/api_endpoints.dart';
import '../../storage/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final SecureStorageService storage;
  final Dio _refreshDio;
  final void Function()? onAuthenticationExpired;

  AuthInterceptor({
    required this.storage,
    required String baseUrl,
    this.onAuthenticationExpired,
    Dio? refreshDio,
  }) : _refreshDio = refreshDio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            ));

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (err.requestOptions.path.contains(ApiEndpoints.login)) {
      return handler.next(err);
    }

    final sentToken = err.requestOptions.headers['Authorization'];
    final currentToken = await storage.getAccessToken();

    String? tokenToUse = currentToken;
    if (currentToken == null || (sentToken != null && sentToken == 'Bearer $currentToken')) {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null) {
        await _handleLogout();
        return handler.next(err);
      }

      try {
        final response = await _refreshDio.post<Map<String, dynamic>>(
          ApiEndpoints.refreshToken,
          data: {'refreshToken': refreshToken},
        );

        final newAccessToken = response.data?['accessToken'] as String?;
        final newRefreshToken = response.data?['refreshToken'] as String?;

        if (newAccessToken == null) {
          await _handleLogout();
          return handler.next(err);
        }

        await storage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken ?? refreshToken,
        );
        tokenToUse = newAccessToken;
      } on DioException {
        await _handleLogout();
        return handler.next(err);
      } catch (_) {
        await _handleLogout();
        return handler.next(err);
      }
    }

    try {
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $tokenToUse';
      final response = await _refreshDio.fetch<dynamic>(retryOptions);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }

  Future<void> _handleLogout() async {
    await storage.clearTokens();
    onAuthenticationExpired?.call();
  }
}
