enum FlavorEnvironment { dev, staging, prod }

abstract final class AppFlavor {
  static late FlavorEnvironment environment;
  static late String baseUrl;
  static late String appName;

  static void initialize({
    required FlavorEnvironment env,
    required String apiBaseUrl,
    required String title,
  }) {
    environment = env;
    baseUrl = apiBaseUrl;
    appName = title;
  }
}
