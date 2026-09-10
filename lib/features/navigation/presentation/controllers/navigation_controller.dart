import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    if (index >= 0 && index < 4) {
      currentIndex.value = index;
    }
  }
}
