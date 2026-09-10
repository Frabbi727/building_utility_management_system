import 'package:flutter/foundation.dart';

enum FlavorEnvironment { dev, staging, prod }

abstract final class AppFlavor {
  static FlavorEnvironment? _environment;
  static String? _baseUrl;
  static String? _appName;

  static FlavorEnvironment get environment {
    final env = _environment;
    if (env == null) {
      throw StateError('AppFlavor not initialized');
    }
    return env;
  }

  static String get baseUrl {
    final url = _baseUrl;
    if (url == null) {
      throw StateError('AppFlavor not initialized');
    }
    return url;
  }

  static String get appName {
    final name = _appName;
    if (name == null) {
      throw StateError('AppFlavor not initialized');
    }
    return name;
  }

  static bool get isDev => _environment == FlavorEnvironment.dev;
  static bool get isStaging => _environment == FlavorEnvironment.staging;
  static bool get isProd => _environment == FlavorEnvironment.prod;

  static void initialize({
    required FlavorEnvironment env,
    required String apiBaseUrl,
    required String title,
  }) {
    _environment = env;
    _baseUrl = apiBaseUrl;
    _appName = title;
  }

  @visibleForTesting
  static void reset() {
    _environment = null;
    _baseUrl = null;
    _appName = null;
  }
}
