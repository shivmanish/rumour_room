class ServerException implements Exception {
  ServerException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final dynamic body;

  @override
  String toString() =>
      'ServerException(statusCode: $statusCode, message: $message)';
}

class NetworkException implements Exception {
  NetworkException([this.message = 'No internet connection.']);
  final String message;

  @override
  String toString() => 'NetworkException($message)';
}

class FirestoreException implements Exception {
  FirestoreException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'FirestoreException(code: $code, message: $message)';
}

class AuthException implements Exception {
  AuthException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'AuthException(code: $code, message: $message)';
}

class CacheException implements Exception {
  CacheException([this.message = 'Local cache read/write failed.']);
  final String message;

  @override
  String toString() => 'CacheException($message)';
}

class NotFoundException implements Exception {
  NotFoundException(this.message);
  final String message;

  @override
  String toString() => 'NotFoundException($message)';
}
