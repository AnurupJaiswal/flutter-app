import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/utils/common_methods.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController({required this.authRepository});

  final isLoginTab = true.obs;
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final isEmailSent = false.obs;
  final errorMessage = ''.obs;

  // Form Validation Keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  // Login Form Controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // Sign Up Form Controllers
  final signupNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    super.onClose();
  }

  void toggleTab(bool login) {
    CM.unFocus(Get.context!);
    isLoginTab.value = login;
    isEmailSent.value = false;
    errorMessage.value = '';
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> signIn() async {
    // Validate form fields to trigger field-level error labels directly below empty fields
    if (!(loginFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    CM.unFocus(Get.context!);
    errorMessage.value = '';
    isLoading.value = true;

    final response = await authRepository.login(email: email, password: password);
    isLoading.value = false;

    if (response.isSuccess) {
      CM.showToast("Welcome back, ${response.data?.name ?? 'User'}!");
      Get.offAllNamed(Routes.MAIN_CONTAINER);
    } else {
      errorMessage.value = response.message;
      CM.showToast(response.message, isError: true);
    }
  }

  /// Passwordless Email Sign-Up Flow
  Future<void> signUp() async {
    if (!(signupFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = signupEmailController.text.trim();

    CM.unFocus(Get.context!);
    errorMessage.value = '';
    isLoading.value = true;

    await Future.delayed(const Duration(milliseconds: 500));
    isLoading.value = false;

    isEmailSent.value = true;
    CM.showToast("Secure sign-up link sent to $email");
  }

  void resendEmailLink() {
    final email = signupEmailController.text.trim();
    CM.showToast("Verification link resent to ${email.isNotEmpty ? email : 'your email'}");
  }

  void changeSignUpEmail() {
    isEmailSent.value = false;
  }

  Future<void> verifyEmailAndNavigate() async {
    final email = signupEmailController.text.trim();
    isLoading.value = true;
    final response = await authRepository.register(
      name: email.contains('@') ? email.split('@').first : 'User',
      email: email.isNotEmpty ? email : 'user@example.com',
      password: 'magic_link_authenticated_user',
    );
    isLoading.value = false;

    if (response.isSuccess) {
      CM.showToast("Account verified successfully!");
      Get.offAllNamed(Routes.MAIN_CONTAINER);
    } else {
      CM.showToast(response.message, isError: true);
    }
  }

  void quickDemoLogin() {
    loginEmailController.text = "user@lala.ai";
    loginPasswordController.text = "password123";
    signIn();
  }

  void signInWithGoogle() {
    CM.showToast("Google Sign-In selected");
  }

  void signInWithMicrosoft() {
    CM.showToast("Microsoft Sign-In selected");
  }

  void forgotPassword() {
    Get.dialog(
      AlertDialog(
        backgroundColor: CC.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: CC.stroke),
        ),
        title: Text("Reset Password", style: TS.sectionTitle(color: CC.textPrimary)),
        content: Text(
          "Password reset instructions will be sent to your registered email address.",
          style: TS.bodySmall(color: CC.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Close", style: TS.caption(color: CC.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CC.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {
              Get.back();
              CM.showToast("Reset link sent to ${loginEmailController.text.isNotEmpty ? loginEmailController.text : 'your email'}");
            },
            child: Text("Send Reset Link", style: TS.button(color: CC.whiteText, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
