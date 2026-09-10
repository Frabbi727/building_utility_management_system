class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException([this.message = 'A server error occurred', this.statusCode]);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Failed to access cache']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);
}
