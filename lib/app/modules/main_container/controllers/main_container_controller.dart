import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/navigation/app_navigation_service.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/core/deep_link/deep_link_router.dart';
import 'package:lala_ai/app/modules/trending/controllers/trending_controller.dart';

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
    navigationService.reinitializeKeys();
    
    // Silently validate session and fetch user data in the background
    if (Get.isRegistered<AuthRepository>()) {
      Get.find<AuthRepository>().fetchAndSaveMe();
    } else {
      Get.put<AuthRepository>(ApiAuthRepository()).fetchAndSaveMe();
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Signal to DeepLinkRouter that MainContainer widget tree and navigators are fully mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkRouter.setAppReady(ready: true);
    });
  }

  void changeTab(int index) {
    if (currentIndex.value == index) {
      // Native Tab Reselection Behavior: Pop active tab stack back to root screen
      navigationService.popToTabRoot(index);
    } else {
      currentIndex.value = index;
      if (index == AppNavigationService.tabTrends && Get.isRegistered<TrendingController>()) {
        Get.find<TrendingController>().loadTrends();
      }
    }
  }

  Future<bool> handleWillPop() async {
    return await navigationService.handleSystemBack(
      currentIndex.value,
      (defaultTab) => currentIndex.value = defaultTab,
    );
  }
}
