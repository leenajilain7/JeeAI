import 'package:dio/dio.dart';

enum ApiErrorKind {
  connectionTimeout,
  sendTimeout,
  receiveTimeout,
  transformTimeout,
  cancelled,
  connection,
  client,
  server,
  unknown,
}

class ApiException implements Exception {
  const ApiException({
    required this.kind,
    required this.message,
    this.statusCode,
  });

  final ApiErrorKind kind;
  final String message;
  final int? statusCode;

  factory ApiException.fromDioException(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final kind = switch (exception.type) {
      DioExceptionType.connectionTimeout => ApiErrorKind.connectionTimeout,
      DioExceptionType.sendTimeout => ApiErrorKind.sendTimeout,
      DioExceptionType.receiveTimeout => ApiErrorKind.receiveTimeout,
      DioExceptionType.transformTimeout => ApiErrorKind.transformTimeout,
      DioExceptionType.cancel => ApiErrorKind.cancelled,
      DioExceptionType.connectionError => ApiErrorKind.connection,
      DioExceptionType.badResponse =>
        statusCode != null && statusCode >= 500
            ? ApiErrorKind.server
            : ApiErrorKind.client,
      DioExceptionType.badCertificate => ApiErrorKind.connection,
      DioExceptionType.unknown => ApiErrorKind.unknown,
    };

    return ApiException(
      kind: kind,
      statusCode: statusCode,
      message: _messageFor(kind, statusCode),
    );
  }

  static String _messageFor(ApiErrorKind kind, int? statusCode) => switch (kind) {
    ApiErrorKind.connectionTimeout => 'The server took too long to respond.',
    ApiErrorKind.sendTimeout => 'The request took too long to send.',
    ApiErrorKind.receiveTimeout => 'The response took too long to arrive.',
    ApiErrorKind.transformTimeout => 'The response took too long to process.',
    ApiErrorKind.cancelled => 'The request was cancelled.',
    ApiErrorKind.connection => 'Could not connect to the JeeAI server.',
    ApiErrorKind.client => switch (statusCode) {
      400 => 'The server rejected the request.',
      401 => 'Authentication is required.',
      403 => 'You do not have permission to perform this action.',
      404 => 'The requested resource was not found.',
      409 => 'The request conflicts with the current resource state.',
      _ => 'The request could not be completed.',
    },
    ApiErrorKind.server => statusCode == 503
        ? 'The JeeAI service is temporarily unavailable.'
        : 'The JeeAI server encountered an error.',
    ApiErrorKind.unknown => 'An unexpected network error occurred.',
  };

  @override
  String toString() => 'ApiException($kind, statusCode: $statusCode): $message';
}
