import 'app/bootstrap.dart';
import 'app/flavors/app_flavor.dart';

Future<void> main() async {
  AppFlavor.initialize(
    env: FlavorEnvironment.dev,
    apiBaseUrl: 'https://api.dev.example.com',
    title: 'Building Utility Management (Dev)',
  );
  await bootstrap();
}
