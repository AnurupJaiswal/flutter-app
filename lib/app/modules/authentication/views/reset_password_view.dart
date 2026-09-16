import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/controllers/forgot_password_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class ResetPasswordView extends StatelessWidget {
  final String? token;
  const ResetPasswordView({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());
    
    final finalToken = token ?? Get.parameters['token'];
    if (finalToken != null && controller.tokenController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setToken(finalToken);
      });
    }

    return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            title: "Create Password",
            wantBackIcon: true,
            isNotHomepage: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  32.height,
                  Text(
                    "Create New Password",
                    style: TS.displayLarge(
                        color: CC.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700),
                  ),
                  8.height,
                  Text(
                    "Your new password must be different from previously used passwords.",
                    style: TS.bodySmall(
                        color: CC.textSecondary,
                        fontWeight: FontWeight.w400,
                        height: 1.4),
                  ),
                  40.height,
                  Text(
                    "Reset Token / Code",
                    style: TS.caption(
                        color: CC.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  8.height,
                  CW.commonTextFormField(
                    controller: controller.tokenController,
                    hintText: "Enter the reset token",
                    prefixIcon: Icons.vpn_key_outlined,
                  ),
                  24.height,
                  Text(
                    "New password",
                    style: TS.caption(
                        color: CC.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  8.height,
                  Obx(() => CW.commonTextFormField(
                        controller: controller.newPasswordController,
                        hintText: "Enter new password",
                        obscureText: !controller.isNewPasswordVisible.value,
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isNewPasswordVisible.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: CC.grey,
                            size: 18,
                          ),
                          onPressed: controller.toggleNewPasswordVisibility,
                        ),
                      )),
                  Obx(() => controller.newPasswordError.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            controller.newPasswordError.value,
                            style: TS.caption(color: Colors.redAccent),
                          ),
                        )
                      : const SizedBox.shrink()),
                  16.height,
                  Text(
                    "Confirm new password",
                    style: TS.caption(
                        color: CC.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  8.height,
                  Obx(() => CW.commonTextFormField(
                        controller: controller.confirmPasswordController,
                        hintText: "Re-enter new password",
                        obscureText: !controller.isConfirmPasswordVisible.value,
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordVisible.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: CC.grey,
                            size: 18,
                          ),
                          onPressed: controller.toggleConfirmPasswordVisibility,
                        ),
                      )),
                  Obx(() => controller.confirmPasswordError.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            controller.confirmPasswordError.value,
                            style: TS.caption(color: Colors.redAccent),
                          ),
                        )
                      : const SizedBox.shrink()),
                  40.height,
                  Obx(() => CW.commonBtn(
                        title: "Reset Password",
                        height: 50,
                        isLoading: controller.isResettingPassword.value,
                        onTap: controller.resetPassword,
                      )),
                ],
              ),
            ),
          ),
        );
  }
}
