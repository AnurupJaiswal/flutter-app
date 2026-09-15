import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/app/modules/authentication/views/verify_otp_view.dart';
import 'package:lala_ai/app/modules/authentication/views/reset_password_view.dart';
import 'package:lala_ai/networking/api_response.dart';
import 'dart:async';

class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepository = Get.isRegistered<AuthRepository>()
      ? Get.find<AuthRepository>()
      : ApiAuthRepository();

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isSendingOtp = false.obs;
  final isVerifyingOtp = false.obs;
  final isResettingPassword = false.obs;

  final emailError = "".obs;
  final otpError = "".obs;
  final newPasswordError = "".obs;
  final confirmPasswordError = "".obs;

  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final resendTimer = 0.obs;
  Timer? _timer;

  String? resetToken;

  @override
  void onClose() {
    _timer?.cancel();
    emailController.dispose();
    otpController.dispose();
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

  Future<void> sendOtp() async {
    emailError.value = "";
    final email = emailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      emailError.value = "Please enter a valid email address.";
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isSendingOtp.value = true;

    // MOCK API CALL FOR FLOW TESTING
    // final response = await _authRepository.sendForgotPasswordOtp(email);
    await Future.delayed(const Duration(seconds: 1));
    final response = ApiResponse.success(data: null, message: "OTP sent to your email.");

    isSendingOtp.value = false;

    if (response.isSuccess) {
      startResendTimer();
      AppToast.success(response.message.isNotEmpty ? response.message : "OTP sent to your email.");
      Get.to(() => const VerifyOtpView());
    } else {
      emailError.value = response.message.isNotEmpty ? response.message : "Failed to send OTP.";
    }
  }

  Future<void> verifyOtp() async {
    otpError.value = "";
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      otpError.value = "Please enter the OTP.";
      return;
    }
    if (otp.length != 6) {
      otpError.value = "Please enter a valid 6-digit OTP.";
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isVerifyingOtp.value = true;

    // MOCK API CALL FOR FLOW TESTING
    // final response = await _authRepository.verifyForgotPasswordOtp(
    //   emailController.text.trim(),
    //   otp,
    // );
    await Future.delayed(const Duration(seconds: 1));
    final response = ApiResponse.success(data: {'resetToken': 'mock_token_123'}, message: "OTP verified.");

    isVerifyingOtp.value = false;

    if (response.isSuccess && response.data != null) {
      // Extract token from data if backend matches our spec
      final dynamic data = response.data;
      if (data is Map && data['resetToken'] != null) {
        resetToken = data['resetToken'].toString();
      } else {
        // Fallback or handle differently if the backend just sets a cookie or returns it directly
        resetToken = data?.toString();
      }

      AppToast.success("OTP verified.");
      Get.off(() => const ResetPasswordView());
    } else {
      otpError.value = response.message.isNotEmpty ? response.message : "Invalid OTP.";
    }
  }

  void startResendTimer() {
    resendTimer.value = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> resendOtp() async {
    if (resendTimer.value > 0) return;
    
    otpError.value = "";
    final email = emailController.text.trim();
    isSendingOtp.value = true;
    // MOCK API CALL FOR FLOW TESTING
    // final response = await _authRepository.sendForgotPasswordOtp(email);
    await Future.delayed(const Duration(seconds: 1));
    final response = ApiResponse.success(data: null, message: "A new OTP has been sent.");
    isSendingOtp.value = false;

    if (response.isSuccess) {
      startResendTimer();
      AppToast.success("A new OTP has been sent.");
    } else {
      otpError.value = response.message.isNotEmpty ? response.message : "Failed to resend OTP.";
    }
  }

  Future<void> resetPassword() async {
    newPasswordError.value = "";
    confirmPasswordError.value = "";
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (newPass.isEmpty) {
      newPasswordError.value = "Please enter a new password.";
      return;
    }
    if (newPass.length < 6) {
      newPasswordError.value = "Password must be at least 6 characters.";
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
    if (resetToken == null || resetToken!.isEmpty) {
      AppToast.error("Reset token is missing. Please restart the process.");
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isResettingPassword.value = true;

    // MOCK API CALL FOR FLOW TESTING
    // final response = await _authRepository.resetPassword(resetToken!, newPass);
    await Future.delayed(const Duration(seconds: 1));
    final response = ApiResponse.success(data: null, message: "Password reset successfully. You can now log in.");

    isResettingPassword.value = false;

    if (response.isSuccess) {
      AppToast.success("Password reset successfully. You can now log in.");
      // Navigate back to Login. (Pop until the first route which is login)
      Get.until((route) => route.isFirst);
    } else {
      newPasswordError.value = response.message.isNotEmpty ? response.message : "Failed to reset password.";
    }
  }
}
