import 'dart:async';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/routes/app_routes.dart';

class SplashController extends GetxController {
  final AuthRepository authRepository;
  bool _hasNavigated = false;
  Timer? _timer;

  SplashController({required this.authRepository});

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 2), () {
      if (!_hasNavigated) {
        checkSessionAndNavigate();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> checkSessionAndNavigate() async {
    if (_hasNavigated) return;
    try {
      _hasNavigated = true;
      _timer?.cancel();
      final hasValidSession = await authRepository.restoreSession();

      if (hasValidSession) {
        Get.offAllNamed(Routes.MAIN_CONTAINER);
      } else {
        Get.offAllNamed(Routes.WELCOME);
      }
    } catch (_) {
      if (!_hasNavigated) {
        _hasNavigated = true;
        Get.offAllNamed(Routes.WELCOME);
      }
    }
  }

  void skipSplash() {
    checkSessionAndNavigate();
  }
}
