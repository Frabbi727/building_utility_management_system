import 'app/bootstrap.dart';
import 'app/flavors/app_flavor.dart';

Future<void> main() async {
  const defaultApiUrl = 'http://192.168.0.148:8000/api/v1';
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: defaultApiUrl);

  AppFlavor.initialize(
    env: FlavorEnvironment.dev,
    apiBaseUrl: apiBaseUrl,
    title: 'Building Utility Management (Dev)',
  );
  await bootstrap();
}
