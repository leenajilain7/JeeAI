import 'package:flutter/foundation.dart';

/// Resolves the API URL once for the app instead of scattering device URLs.
///
/// Override it for a physical device with:
/// `--dart-define=JEEAI_API_BASE_URL=http://192.168.x.x:3000/api`
class ApiEnvironment {
  const ApiEnvironment._(this.baseUrl);

  static const _configuredBaseUrl = String.fromEnvironment(
    'JEEAI_API_BASE_URL',
  );

  final String baseUrl;

  factory ApiEnvironment.fromEnvironment({
    TargetPlatform? targetPlatform,
    String? configuredBaseUrl,
  }) {
    final override = configuredBaseUrl ?? _configuredBaseUrl;
    if (override.trim().isNotEmpty) {
      return ApiEnvironment._(_normalizeBaseUrl(override));
    }

    final platform = targetPlatform ?? defaultTargetPlatform;
    final defaultUrl = switch (platform) {
      TargetPlatform.android => 'http://10.0.2.2:3000/api',
      _ => 'http://localhost:3000/api',
    };
    return ApiEnvironment._(defaultUrl);
  }

  factory ApiEnvironment.forBaseUrl(String value) =>
      ApiEnvironment._(_normalizeBaseUrl(value));

  static String _normalizeBaseUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        !uri.hasScheme ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ArgumentError.value(
        value,
        'baseUrl',
        'Must be an HTTP(S) URL without embedded credentials, query, or fragment.',
      );
    }

    final normalizedPath = uri.path.replaceFirst(RegExp(r'/+$'), '');
    return uri.replace(path: normalizedPath).toString();
  }
}
