import 'package:dio/dio.dart';
import '../../error/failures.dart';
import '../network_info.dart';

class ConnectivityInterceptor extends Interceptor {
  final NetworkInfo _networkInfo;
  ConnectivityInterceptor(this._networkInfo);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!await _networkInfo.isConnected) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: const NetworkFailure(),
          type: DioExceptionType.connectionError,
        ),
      );
    }
    return handler.next(options);
  }
}
