import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/controllers/auth_controller.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => ApiAuthRepository());
    }
    Get.lazyPut<AuthController>(
      () => AuthController(authRepository: Get.find<AuthRepository>()),
    );
  }
}
