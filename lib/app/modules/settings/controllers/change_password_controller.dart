import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/utils/app_toast.dart';

class ChangePasswordController extends GetxController {
  final AuthRepository _authRepository = Get.isRegistered<AuthRepository>()
      ? Get.find<AuthRepository>()
      : MockAuthRepository();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isCurrentPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final isLoading = false.obs;
  final isValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentPasswordController.addListener(_validateForm);
    newPasswordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void _validateForm() {
    final current = currentPasswordController.text;
    final newPass = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    isValid.value = current.isNotEmpty &&
        newPass.length >= 6 &&
        confirm == newPass;
  }

  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.value = !isCurrentPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Current password is required";
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "New password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your new password";
    }
    if (value != newPasswordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  Future<void> changePassword() async {
    if (!isValid.value) return;

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    final response = await _authRepository.changePassword(
      currentPassword: currentPasswordController.text,
      newPassword: newPasswordController.text,
    );

    isLoading.value = false;

    if (response.isSuccess) {
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      AppToast.success(response.message);
      Get.back(); // Go back to Settings
    } else {
      AppToast.error(response.message);
    }
  }
}
