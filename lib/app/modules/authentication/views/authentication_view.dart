import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/controllers/auth_controller.dart';
import 'package:lala_ai/app/modules/authentication/views/login_view.dart';
import 'package:lala_ai/app/modules/authentication/views/signup_view.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class AuthenticationView extends GetView<AuthController> {
  const AuthenticationView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (themeService) {
        return Obx(() {
          final isLogin = controller.isLoginTab.value;
          final isEmailSent = controller.isEmailSent.value;

          return PopScope(
            canPop: isLogin && !isEmailSent,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (isEmailSent) {
                controller.changeSignUpEmail();
              } else if (!isLogin) {
                controller.toggleTab(true);
              }
            },
            child: Scaffold(
              backgroundColor: CC.surface,
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.02),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: isLogin
                              ? const LoginView(key: ValueKey('login_view'))
                              : const SignupView(key: ValueKey('signup_view')),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
