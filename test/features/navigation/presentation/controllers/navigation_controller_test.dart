import 'package:building_utility_management_system/features/navigation/presentation/controllers/navigation_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NavigationController controller;

  setUp(() {
    controller = NavigationController();
  });

  test('initial tab index should be 0', () {
    expect(controller.currentIndex.value, 0);
  });

  test('changeTab updates currentIndex', () {
    controller.changeTab(2);
    expect(controller.currentIndex.value, 2);

    controller.changeTab(3);
    expect(controller.currentIndex.value, 3);
  });
}
