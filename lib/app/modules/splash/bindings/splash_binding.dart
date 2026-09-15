import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/modules/splash/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => ApiAuthRepository());
    }
    Get.lazyPut<SplashController>(
      () => SplashController(authRepository: Get.find<AuthRepository>()),
    );
  }
}
