import 'app/bootstrap.dart';
import 'app/flavors/app_flavor.dart';

Future<void> main() async {
  // Default development API URL connects to localhost/127.0.0.1
  // For physical Android devices via USB, run: adb reverse tcp:8000 tcp:8000
  // For Android emulator without adb reverse, pass --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
  const defaultApiUrl = 'http://127.0.0.1:8000/api/v1';
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: defaultApiUrl);

  AppFlavor.initialize(
    env: FlavorEnvironment.dev,
    apiBaseUrl: apiBaseUrl,
    title: 'Building Utility Management (Dev)',
  );
  await bootstrap();
}
