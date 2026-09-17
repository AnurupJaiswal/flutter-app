import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/settings/controllers/change_password_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  late final ChangePasswordController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ChangePasswordController>()
        ? Get.find<ChangePasswordController>()
        : Get.put(ChangePasswordController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<ChangePasswordController>()) {
      Get.delete<ChangePasswordController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ThemeService>(
      builder: (_) {
        return Scaffold(
          backgroundColor: CC.background,
      appBar: CW.commonAppbar(
        isNotHomepage: true,
        title: "Change Password",
        wantBackIcon: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => CW.commonTextFormField(
                    controller: controller.currentPasswordController,
                    hintText: "Current password",
                    labelText: "Current Password",
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: !controller.isCurrentPasswordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isCurrentPasswordVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: CC.textSecondary,
                        size: 20,
                      ),
                      onPressed: controller.toggleCurrentPasswordVisibility,
                    ),
                  )),
              20.height,
              Obx(() => CW.commonTextFormField(
                    controller: controller.newPasswordController,
                    hintText: "New password (min. 6 characters)",
                    labelText: "New Password",
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: !controller.isNewPasswordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isNewPasswordVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: CC.textSecondary,
                        size: 20,
                      ),
                      onPressed: controller.toggleNewPasswordVisibility,
                    ),
                  )),
              20.height,
              Obx(() => CW.commonTextFormField(
                    controller: controller.confirmPasswordController,
                    hintText: "Confirm new password",
                    labelText: "Confirm New Password",
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: CC.textSecondary,
                        size: 20,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                  )),
              32.height,
              Obx(() => CW.commonBtn(
                    title: controller.isLoading.value ? "Updating..." : "Update Password",
                    color: controller.isValid.value && !controller.isLoading.value
                        ? CC.primary
                        : CC.primary.withValues(alpha: 0.5),
                    onTap: controller.isValid.value && !controller.isLoading.value
                        ? () => controller.changePassword(context)
                        : null,
                    isLoading: controller.isLoading.value,
                  )),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}
