import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/core/deep_link/deep_link_router.dart';

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
    bool hasValidSession = false;
    try {
      _hasNavigated = true;
      _timer?.cancel();
      hasValidSession = await authRepository.restoreSession();

      if (hasValidSession) {
        Get.offAllNamed(Routes.MAIN_CONTAINER);
      } else {
        Get.offAllNamed(Routes.WELCOME);
      }
    } catch (_) {
      if (!_hasNavigated) {
        _hasNavigated = true;
        await authRepository.clearSession();
        Get.offAllNamed(Routes.WELCOME);
      }
    } finally {
      // If user is unauthenticated and routed to Welcome, mark ready after frame.
      // If authenticated, MainContainerController.onReady marks ready once widget tree is mounted.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!hasValidSession) {
          DeepLinkRouter.setAppReady(ready: true);
        }
      });
    }
  }

  void skipSplash() {
    checkSessionAndNavigate();
  }
}
