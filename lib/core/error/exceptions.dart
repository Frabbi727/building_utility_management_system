class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException([this.message = 'A server error occurred', this.statusCode]);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Failed to access cache']);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => message;
}
