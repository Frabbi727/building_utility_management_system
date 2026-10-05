import 'app/bootstrap.dart';
import 'app/flavors/app_flavor.dart';

Future<void> main() async {
  const defaultApiUrl = 'https://utility.techrealify.com/api/v1';
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: defaultApiUrl);

  AppFlavor.initialize(
    env: FlavorEnvironment.prod,
    apiBaseUrl: apiBaseUrl,
    title: 'Utility Notes',
  );
  await bootstrap();
}
