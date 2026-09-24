import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/utils/constants.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepository = Get.isRegistered<AuthRepository>()
      ? Get.find<AuthRepository>()
      : ApiAuthRepository();

  final emailController = TextEditingController();
  final tokenController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isSendingLink = false.obs;
  final isResettingPassword = false.obs;
  final linkSent = false.obs;

  final emailError = "".obs;
  final newPasswordError = "".obs;
  final confirmPasswordError = "".obs;

  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  String? resetToken;

  @override
  void onClose() {
    emailController.dispose();
    tokenController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  /// Called from the ForgotPasswordView (Email entry)
  Future<void> requestPasswordReset() async {
    emailError.value = "";
    final email = emailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      emailError.value = "Please enter a valid email address.";
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isSendingLink.value = true;

    final response = await _authRepository.forgotPassword(email);

    isSendingLink.value = false;

    if (response.isSuccess) {
      linkSent.value = true;
      AppToast.success(response.message.isNotEmpty ? response.message : "Password reset link sent.");
    } else {
      AppToast.error(response.message.isNotEmpty ? response.message : "Failed to send reset link.");
    }
  }

  /// Sets the token received from the deep link
  void setToken(String token) {
    tokenController.text = token;
  }

  /// Called from the ResetPasswordView
  Future<void> resetPassword() async {
    newPasswordError.value = "";
    confirmPasswordError.value = "";
    final token = tokenController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (token.isEmpty) {
      AppToast.error("Reset token is missing. Please enter the token or restart the process from the email link.");
      return;
    }
    if (newPass.length < AppConstants.minPasswordLength) {
      newPasswordError.value = "Password must be at least ${AppConstants.minPasswordLength} characters.";
      return;
    }
    if (confirmPass.isEmpty) {
      confirmPasswordError.value = "Please confirm your password.";
      return;
    }
    if (newPass != confirmPass) {
      confirmPasswordError.value = "Passwords do not match.";
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isResettingPassword.value = true;

    final response = await _authRepository.resetPassword(
      token: token,
      newPassword: newPass,
    );

    isResettingPassword.value = false;

    if (response.isSuccess) {
      AppToast.success("Password reset successfully. You can now log in.");
      // Navigate back to Login. (Pop until the first route which is login)
      Get.until((route) => route.isFirst);
    } else {
      AppToast.error(response.message.isNotEmpty ? response.message : "Failed to reset password.");
    }
  }
}
