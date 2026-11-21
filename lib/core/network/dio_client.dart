import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_environment.dart';
import 'api_exception.dart';

const _connectTimeout = Duration(seconds: 15);
const _sendTimeout = Duration(seconds: 15);
const _receiveTimeout = Duration(seconds: 30);

/// Builds the application's shared Dio instance.
Dio createDioClient({ApiEnvironment? environment}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: (environment ?? ApiEnvironment.fromEnvironment()).baseUrl,
      connectTimeout: _connectTimeout,
      sendTimeout: _sendTimeout,
      receiveTimeout: _receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: const {Headers.acceptHeader: Headers.jsonContentType},
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(DevelopmentNetworkLogInterceptor());
  }
  dio.interceptors.add(ApiErrorInterceptor());
  return dio;
}

class ApiErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      err.copyWith(error: ApiException.fromDioException(err)),
    );
  }
}

/// Logs paths and status only. Request/response bodies, headers, and query
/// parameters can contain private data and are intentionally omitted.
class DevelopmentNetworkLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[Dio] --> ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    debugPrint(
      '[Dio] <-- ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[Dio] xx ${err.response?.statusCode ?? err.type.name} '
      '${err.requestOptions.method} ${err.requestOptions.path}',
    );
    handler.next(err);
  }
}
