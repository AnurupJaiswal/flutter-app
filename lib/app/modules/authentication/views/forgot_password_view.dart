import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/controllers/forgot_password_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller in memory so it survives across the 3 screens
    final controller = Get.put(ForgotPasswordController());

    return GetBuilder<ThemeService>(
      builder: (themeService) {
        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            title: "Forgot Password",
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
                    "Reset Password",
                    style: TS.displayLarge(
                        color: CC.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700),
                  ),
                  8.height,
                  Text(
                    "Enter the email associated with your account and we'll send an email with instructions to reset your password.",
                    style: TS.bodySmall(
                        color: CC.textSecondary,
                        fontWeight: FontWeight.w400,
                        height: 1.4),
                  ),
                  40.height,
                  Text(
                    "Email address",
                    style: TS.caption(
                        color: CC.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  8.height,
                  CW.commonTextFormField(
                    controller: controller.emailController,
                    hintText: "Enter your email",
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  Obx(() => controller.emailError.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            controller.emailError.value,
                            style: TS.caption(color: Colors.redAccent),
                          ),
                        )
                      : const SizedBox.shrink()),
                  40.height,
                  Obx(() => CW.commonBtn(
                        title: "Send OTP",
                        height: 50,
                        isLoading: controller.isSendingOtp.value,
                        onTap: controller.sendOtp,
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
