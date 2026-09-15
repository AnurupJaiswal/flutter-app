import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/controllers/forgot_password_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';
import 'package:pinput/pinput.dart';

class VerifyOtpView extends StatelessWidget {
  const VerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgotPasswordController>();

    return GetBuilder<ThemeService>(
      builder: (themeService) {
        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            title: "Verify OTP",
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
                    "Check your email",
                    style: TS.displayLarge(
                        color: CC.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700),
                  ),
                  8.height,
                  Text(
                    "We've sent a 6-digit verification code to ${controller.emailController.text}",
                    style: TS.bodySmall(
                        color: CC.textSecondary,
                        fontWeight: FontWeight.w400,
                        height: 1.4),
                  ),
                  40.height,
                  Text(
                    "Verification code",
                    style: TS.caption(
                        color: CC.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  8.height,
                  Center(
                    child: Pinput(
                      length: 6,
                      controller: controller.otpController,
                      defaultPinTheme: PinTheme(
                        width: 45,
                        height: 55,
                        textStyle: TS.displayLarge(fontSize: 22, color: CC.textPrimary),
                        decoration: BoxDecoration(
                          color: CC.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: CC.stroke.withValues(alpha: 0.5)),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 45,
                        height: 55,
                        textStyle: TS.displayLarge(fontSize: 22, color: CC.textPrimary),
                        decoration: BoxDecoration(
                          color: CC.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: CC.primary),
                        ),
                      ),
                      errorPinTheme: PinTheme(
                        width: 45,
                        height: 55,
                        textStyle: TS.displayLarge(fontSize: 22, color: CC.textPrimary),
                        decoration: BoxDecoration(
                          color: CC.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ),
                  Obx(() => controller.otpError.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            controller.otpError.value,
                            style: TS.caption(color: Colors.redAccent),
                          ),
                        )
                      : const SizedBox.shrink()),
                  16.height,
                  Align(
                    alignment: Alignment.centerRight,
                    child: Obx(() => GestureDetector(
                      onTap: controller.resendTimer.value > 0 ? null : controller.resendOtp,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          controller.resendTimer.value > 0 
                              ? "Resend OTP in ${controller.resendTimer.value}s" 
                              : "Resend OTP",
                          style: TS.caption(
                            color: controller.resendTimer.value > 0 ? CC.textSecondary : CC.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )),
                  ),
                  24.height,
                  Obx(() => CW.commonBtn(
                        title: "Verify",
                        height: 50,
                        isLoading: controller.isVerifyingOtp.value,
                        onTap: controller.verifyOtp,
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
