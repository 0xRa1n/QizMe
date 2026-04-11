import 'package:flutter/foundation.dart';

const String baseUrl = 'http://localhost:8000';
// 143.198.209.74 - endpoint
// 10.0.2.2 - Android emulator localhost bridge

String get resolvedBaseUrl {
  final isAndroidDebug =
      kDebugMode && !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  if (!isAndroidDebug) return baseUrl;

  return baseUrl
      .replaceFirst('://localhost', '://10.0.2.2')
      .replaceFirst('://127.0.0.1', '://10.0.2.2');
}
