import 'package:get/get.dart';
import 'package:lala_ai/app/data/repositories/analytics_repository.dart';
import 'package:lala_ai/app/data/repositories/discover_repository.dart';
import 'package:lala_ai/app/data/repositories/saved_repository.dart';
import 'package:lala_ai/app/data/repositories/trend_repository.dart';
import 'package:lala_ai/app/modules/analytics/controllers/analytics_controller.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/modules/chat/controllers/chat_controller.dart';
import 'package:lala_ai/app/modules/chat/data/chat_repository.dart';
import 'package:lala_ai/app/modules/discover/controllers/discover_controller.dart';
import 'package:lala_ai/app/modules/home/controllers/home_controller.dart';
import 'package:lala_ai/app/modules/main_container/controllers/main_container_controller.dart';
import 'package:lala_ai/app/modules/saved/controllers/saved_controller.dart';
import 'package:lala_ai/app/modules/settings/controllers/settings_controller.dart';
import 'package:lala_ai/app/modules/trending/controllers/trending_controller.dart';

class MainContainerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainContainerController>(() => MainContainerController());

    // Repositories
    Get.lazyPut<TrendRepository>(() => MockTrendRepository());
    Get.put<AnalyticsRepository>(MockAnalyticsRepository(), permanent: true);
    Get.lazyPut<DiscoverRepository>(() => MockDiscoverRepository());
    Get.lazyPut<SavedRepository>(() => MockSavedRepository());

    if (!Get.isRegistered<ChatRepository>()) {
      Get.lazyPut<ChatRepository>(() => MockChatRepository());
    }

    // Controllers
    Get.lazyPut<HomeController>(() => HomeController(trendRepository: Get.find()));
    Get.lazyPut<TrendingController>(() => TrendingController(trendRepository: Get.find()));
    Get.lazyPut<AnalyticsController>(() => AnalyticsController());
    Get.lazyPut<DiscoverController>(() => DiscoverController(
          discoverRepository: Get.find(),
          savedRepository: Get.find(),
        ));
    Get.lazyPut<SavedController>(() => SavedController(savedRepository: Get.find()));
    Get.lazyPut<ChatController>(() => ChatController(repository: Get.find()));

    if (!Get.isRegistered<SettingsController>()) {
      Get.lazyPut<SettingsController>(() => SettingsController(
            authRepository: Get.isRegistered<AuthRepository>()
                ? Get.find<AuthRepository>()
                : MockAuthRepository(),
          ));
    }
  }
}
