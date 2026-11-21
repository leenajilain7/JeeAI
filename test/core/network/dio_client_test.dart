import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jeeai/core/network/api_environment.dart';
import 'package:jeeai/core/network/api_exception.dart';
import 'package:jeeai/core/network/dio_client.dart';

void main() {
  group('ApiEnvironment', () {
    test('uses the iOS Simulator host by default on iOS', () {
      final environment = ApiEnvironment.fromEnvironment(
        targetPlatform: TargetPlatform.iOS,
        configuredBaseUrl: '',
      );

      expect(environment.baseUrl, 'http://localhost:3000/api');
    });

    test('uses the Android Emulator host on Android', () {
      final environment = ApiEnvironment.fromEnvironment(
        targetPlatform: TargetPlatform.android,
        configuredBaseUrl: '',
      );

      expect(environment.baseUrl, 'http://10.0.2.2:3000/api');
    });

    test('allows a physical-device LAN URL override and removes trailing slash', () {
      final environment = ApiEnvironment.fromEnvironment(
        targetPlatform: TargetPlatform.iOS,
        configuredBaseUrl: 'http://192.168.1.15:3000/api/',
      );

      expect(environment.baseUrl, 'http://192.168.1.15:3000/api');
    });

    test('rejects URLs containing embedded credentials or non-HTTP schemes', () {
      expect(
        () => ApiEnvironment.forBaseUrl('http://user:password@localhost/api'),
        throwsArgumentError,
      );
      expect(
        () => ApiEnvironment.forBaseUrl('file:///tmp/api'),
        throwsArgumentError,
      );
    });
  });

  group('createDioClient', () {
    test('configures shared JSON defaults, timeouts and debug-only logging', () {
      final dio = createDioClient(
        environment: ApiEnvironment.forBaseUrl('http://localhost:3000/api'),
      );

      expect(dio.options.baseUrl, 'http://localhost:3000/api');
      expect(dio.options.connectTimeout, const Duration(seconds: 15));
      expect(dio.options.sendTimeout, const Duration(seconds: 15));
      expect(dio.options.receiveTimeout, const Duration(seconds: 30));
      expect(dio.options.contentType, Headers.jsonContentType);
      expect(dio.options.responseType, ResponseType.json);
      expect(dio.options.headers[Headers.acceptHeader], Headers.jsonContentType);
      expect(
        dio.interceptors.any((interceptor) => interceptor is ApiErrorInterceptor),
        isTrue,
      );
      expect(
        dio.interceptors.any(
          (interceptor) => interceptor is DevelopmentNetworkLogInterceptor,
        ),
        kDebugMode,
      );
      dio.close(force: true);
    });

    test('encodes JSON requests and decodes JSON responses', () async {
      final dio = createDioClient(
        environment: ApiEnvironment.forBaseUrl('http://localhost:3000/api'),
      );
      final adapter = StaticResponseAdapter(
        statusCode: 200,
        body: '{"ok":true}',
      );
      dio.httpClientAdapter = adapter;

      final response = await dio.post<dynamic>(
        '/test',
        data: {'message': 'hello'},
      );

      expect(adapter.lastRequest?.contentType, Headers.jsonContentType);
      expect(adapter.lastRequest?.headers[Headers.acceptHeader], Headers.jsonContentType);
      expect(adapter.requestBody, '{"message":"hello"}');
      expect(response.data, {'ok': true});
      dio.close(force: true);
    });

    test('maps timeout failures to the shared ApiException', () async {
      final dio = createDioClient(
        environment: ApiEnvironment.forBaseUrl('http://localhost:3000/api'),
      );
      dio.httpClientAdapter = ThrowingAdapter(
        DioExceptionType.connectionTimeout,
      );

      try {
        await dio.get<dynamic>('/health');
        fail('Expected a DioException.');
      } on DioException catch (error) {
        expect(error.error, isA<ApiException>());
        final apiException = error.error! as ApiException;
        expect(apiException.kind, ApiErrorKind.connectionTimeout);
        expect(apiException.message, contains('too long'));
      } finally {
        dio.close(force: true);
      }
    });

    test('maps server failures to a safe generic message', () async {
      final dio = createDioClient(
        environment: ApiEnvironment.forBaseUrl('http://localhost:3000/api'),
      );
      dio.httpClientAdapter = StaticResponseAdapter(
        statusCode: 503,
        body: '{"error":{"message":"Database unavailable at secret-host"}}',
      );

      try {
        await dio.get<dynamic>('/health/db');
        fail('Expected a DioException.');
      } on DioException catch (error) {
        expect(error.error, isA<ApiException>());
        final apiException = error.error! as ApiException;
        expect(apiException.kind, ApiErrorKind.server);
        expect(apiException.statusCode, 503);
        expect(apiException.message, 'The JeeAI service is temporarily unavailable.');
        expect(apiException.message, isNot(contains('secret-host')));
      } finally {
        dio.close(force: true);
      }
    });
  });
}

class StaticResponseAdapter implements HttpClientAdapter {
  StaticResponseAdapter({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
  RequestOptions? lastRequest;
  String? requestBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    if (requestStream != null) {
      requestBody = String.fromCharCodes(await requestStream.expand((chunk) => chunk).toList());
    }
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }

  @override
  void close({bool force = false}) {}
}

class ThrowingAdapter implements HttpClientAdapter {
  ThrowingAdapter(this.type);

  final DioExceptionType type;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(requestOptions: options, type: type);
  }

  @override
  void close({bool force = false}) {}
}
