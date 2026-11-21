import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_client.dart';

/// Shared networking client for feature repositories and data sources.
final dioProvider = Provider<Dio>((ref) {
  final dio = createDioClient();
  ref.onDispose(() => dio.close(force: true));
  return dio;
});
