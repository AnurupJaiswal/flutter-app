import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/modules/settings/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => ApiAuthRepository());
    }
    Get.lazyPut<SettingsController>(
      () => SettingsController(authRepository: Get.find<AuthRepository>()),
    );
  }
}
