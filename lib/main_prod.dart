import 'app/bootstrap.dart';
import 'app/flavors/app_flavor.dart';

void main() {
  AppFlavor.initialize(
    env: FlavorEnvironment.prod,
    apiBaseUrl: 'https://api.example.com',
    title: 'Building Utility Management',
  );
  bootstrap();
}
