import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger _logger;

  LoggingInterceptor({Logger? logger})
      : _logger = logger ??
            Logger(
              printer: PrettyPrinter(methodCount: 0, printEmojis: true),
            );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.d('--> ${options.method} ${options.uri}\nHeaders: ${options.headers}\nBody: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.i('<-- ${response.statusCode} ${response.requestOptions.uri}\nData: ${response.data}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.e('<-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri}\nMessage: ${err.message}');
    }
    super.onError(err, handler);
  }
}
