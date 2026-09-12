import 'dart:io' show Platform;
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

    // Propagate audit correlation headers
    options.headers['X-Request-Id'] ??= _generateRequestId();
    options.headers['X-Client-Platform'] ??= _getClientPlatform();
    options.headers['X-App-Version'] ??= '1.0.0';

    return handler.next(options);
  }

  static String _generateRequestId() {
    final random = Random();
    final part1 = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final part2 = random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return 'req-$part1-$part2';
  }

  static String _getClientPlatform() {
    if (kIsWeb) return 'flutter_web';
    try {
      if (Platform.isAndroid) return 'flutter_android';
      if (Platform.isIOS) return 'flutter_ios';
      if (Platform.isMacOS) return 'flutter_macos';
      if (Platform.isWindows) return 'flutter_windows';
      if (Platform.isLinux) return 'flutter_linux';
    } catch (_) {
      return 'flutter';
    }
    return 'flutter';
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (err.requestOptions.path.contains(ApiEndpoints.login) ||
        err.requestOptions.path.contains(ApiEndpoints.refreshToken)) {
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
      } on DioException catch (refreshErr) {
        final statusCode = refreshErr.response?.statusCode;
        if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
          await _handleLogout();
        }
        return handler.next(refreshErr);
      } catch (_) {
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
