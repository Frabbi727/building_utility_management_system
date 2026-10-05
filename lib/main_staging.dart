import 'app/bootstrap.dart';
import 'app/flavors/app_flavor.dart';

Future<void> main() async {
  AppFlavor.initialize(
    env: FlavorEnvironment.staging,
    apiBaseUrl: 'https://api.staging.example.com',
    title: 'Utility Notes (Staging)',
  );
  await bootstrap();
}
