import 'package:get/get.dart';
import 'package:lala_ai/app/navigation/app_navigation_service.dart';

class MainContainerController extends GetxController {
  final currentIndex = 0.obs;
  late final AppNavigationService navigationService;

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<AppNavigationService>()) {
      navigationService = Get.put(AppNavigationService());
    } else {
      navigationService = Get.find<AppNavigationService>();
    }
  }

  void changeTab(int index) {
    if (currentIndex.value == index) {
      // Native Tab Reselection Behavior: Pop active tab stack back to root screen
      navigationService.popToTabRoot(index);
    } else {
      currentIndex.value = index;
    }
  }

  Future<bool> handleWillPop() async {
    return await navigationService.handleSystemBack(
      currentIndex.value,
      (defaultTab) => currentIndex.value = defaultTab,
    );
  }
}
