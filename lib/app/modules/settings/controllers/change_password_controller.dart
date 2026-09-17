import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/utils/app_toast.dart';

class ChangePasswordController extends GetxController {
  final AuthRepository _authRepository = Get.isRegistered<AuthRepository>()
      ? Get.find<AuthRepository>()
      : ApiAuthRepository();

  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  final isCurrentPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final isLoading = false.obs;
  final isValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
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
    final current = currentPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

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
    if (value == null || value.trim().isEmpty) {
      return "Current password is required";
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "New password is required";
    }
    if (value.trim().length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please confirm your new password";
    }
    if (value.trim() != newPasswordController.text.trim()) {
      return "Passwords do not match";
    }
    return null;
  }

  Future<bool> changePassword([BuildContext? context]) async {
    if (!isValid.value) return false;

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    final response = await _authRepository.changePassword(
      currentPassword: currentPasswordController.text.trim(),
      newPassword: newPasswordController.text.trim(),
    );

    isLoading.value = false;

    if (response.isSuccess) {
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      final msg = response.message.isNotEmpty
          ? response.message
          : "Password changed successfully";

      if (context != null && context.mounted) {
        Navigator.of(context).pop(true);
      } else if (Get.context != null && Navigator.canPop(Get.context!)) {
        Navigator.of(Get.context!).pop(true);
      } else {
        Get.back();
      }

      AppToast.success(msg);
      return true;
    } else {
      final msg = response.message.isNotEmpty
          ? response.message
          : "Failed to update password. Please check your current password.";
      AppToast.error(msg);
      return false;
    }
  }
}
