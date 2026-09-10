import 'app/bootstrap.dart';
import 'app/flavors/app_flavor.dart';

void main() {
  AppFlavor.initialize(
    env: FlavorEnvironment.staging,
    apiBaseUrl: 'https://api.staging.example.com',
    title: 'Building Utility Management (Staging)',
  );
  bootstrap();
}
