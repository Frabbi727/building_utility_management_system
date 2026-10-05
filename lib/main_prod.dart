import 'app/bootstrap.dart';
import 'app/flavors/app_flavor.dart';

Future<void> main() async {
  AppFlavor.initialize(
    env: FlavorEnvironment.prod,
    apiBaseUrl: 'https://api.example.com',
    title: 'Utility Notes',
  );
  await bootstrap();
}
