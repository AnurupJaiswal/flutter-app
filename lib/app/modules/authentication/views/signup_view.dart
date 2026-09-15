import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/app/modules/authentication/controllers/auth_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.03),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: controller.isEmailSent.value
            ? _buildEmailSentView(context)
            : _buildEmailInputView(context),
      );
    });
  }

  /// State 1: Passwordless Email Entry with 3-Step Process Stepper
  Widget _buildEmailInputView(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey('email_input_view'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [

          // Main Form
          Form(
            key: controller.signupFormKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [


                // Brand Badge & Wordmark
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: CC.isDark ? const Color(0xFF00383D) : CC.tealSubtle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: CC.primary.withValues(alpha: 0.3), width: 0.7),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: CC.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    12.width,
                    RichText(
                      text: TextSpan(
                        text: 'Lala ',
                        style: TS.sectionTitle(
                          color: CC.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(
                            text: 'Ai',
                            style: TS.sectionTitle(
                              color: CC.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                20.height,

                // Title & Subtitle
                Text(
                  "Create your account",
                  style: TS.displayLarge(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                6.height,
                Text(
                  "Enter your email and we'll send you a secure sign-up link.",
                  style: TS.subHeading(color: CC.textSecondary, fontSize: 13.5),
                ),

                20.height,

                // 3-Step Process Stepper (Unboxed)
                Row(
                  children: [
                    // Step 1
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: CC.tealSubtle,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.mail_outline_rounded, color: CC.primary, size: 18),
                          ),
                          8.height,
                          Text(
                            "Get a secure\nlink via email",
                            textAlign: TextAlign.center,
                            style: TS.caption(color: CC.textSecondary, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),

                    // Connector
                    Container(
                      width: 20,
                      height: 1,
                      color: CC.stroke,
                      margin: const EdgeInsets.only(bottom: 24),
                    ),

                    // Step 2
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: CC.tealSubtle,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person_outline_rounded, color: CC.primary, size: 18),
                          ),
                          8.height,
                          Text(
                            "Complete\nyour setup",
                            textAlign: TextAlign.center,
                            style: TS.caption(color: CC.textSecondary, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),

                    // Connector
                    Container(
                      width: 20,
                      height: 1,
                      color: CC.stroke,
                      margin: const EdgeInsets.only(bottom: 24),
                    ),

                    // Step 3
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: CC.tealSubtle,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.auto_awesome_rounded, color: CC.primary, size: 18),
                          ),
                          8.height,
                          Text(
                            "Start using\n Lala Ai",
                            textAlign: TextAlign.center,
                            style: TS.caption(color: CC.textSecondary, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                24.height,

                // Email Field
                CW.commonTextFormField(
                  controller: controller.signupEmailController,
                  hintText: "you@domain.com",
                  labelText: "Email",
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => controller.signUp(),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Please enter your email address.";
                    }
                    if (!GetUtils.isEmail(val.trim())) {
                      return "Please enter a valid email address.";
                    }
                    return null;
                  },
                ),


                22.height,

                // Primary Action Button (Send Sign-up Link ->)
                Obx(() => CW.commonBtn(
                      title: "Send Sign-up Link",
                      height: 50,
                      isLoading: controller.isLoading.value,
                      onTap: controller.signUp,
                      lastWidget: const Icon(
                        Icons.arrow_forward_rounded,
                        color: CC.whiteText,
                        size: 18,
                      ),
                    )),

                18.height,

                // Terms of Service & Privacy Policy Notice
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 15,
                      color: CC.grey,
                    ),
                    8.width,
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: "By continuing, you agree to our ",
                          style: TS.caption(color: CC.textSecondary, fontSize: 11.5),
                          children: [
                            TextSpan(
                              text: "Terms of Service",
                              style: TS.caption(
                                color: CC.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.5,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Get.toNamed(Routes.TERMS_CONDITIONS),
                            ),
                            TextSpan(
                              text: " and ",
                              style: TS.caption(color: CC.textSecondary, fontSize: 11.5),
                            ),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TS.caption(
                                color: CC.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.5,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Get.toNamed(Routes.PRIVACY_POLICY),
                            ),
                            const TextSpan(text: "."),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                24.height,

                // Already have an account? Sign in Link
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TS.bodySmall(color: CC.textSecondary, fontSize: 13.5),
                      ),
                      GestureDetector(
                        onTap: () => controller.toggleTab(true),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "Sign in",
                            style: TS.bodySmall(
                              color: CC.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// State 2: Check Your Email UI
  Widget _buildEmailSentView(BuildContext context) {
    final userEmail = controller.signupEmailController.text.trim();
    final displayEmail = userEmail.isNotEmpty ? userEmail : "you@company.com";

    return KeyedSubtree(
      key: const ValueKey('email_sent_view'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [


          // Email Icon Badge
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: CC.tealSubtle,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CC.primary.withOpacityValue(0.3), width: 1),
              ),
              child: Center(
                child: Icon(
                  Icons.mark_email_read_rounded,
                  color: CC.primary,
                  size: 28,
                ),
              ),
            ),
          ),

          20.height,

          // Large Heading & Confirmation Text
          Text(
            "Check your email",
            style: TS.displayLarge(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          8.height,
          RichText(
            text: TextSpan(
              text: "We sent a secure link to\n",
              style: TS.subHeading(color: CC.textSecondary, fontSize: 14),
              children: [
                TextSpan(
                  text: displayEmail,
                  style: TS.body(
                    color: CC.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          32.height,

          // Primary Action: Open Email App
          Obx(() => CW.commonBtn(
                title: "Open Email App",
                height: 50,
                isLoading: controller.isLoading.value,
                onTap: controller.openEmailApp,
                leadingImage: const Icon(
                  Icons.open_in_new_rounded,
                  color: CC.whiteText,
                  size: 18,
                ),
              )),

          16.height,

          // Secondary Action: Resend Link
          CW.commonBtn(
            title: "Resend link",
            height: 48,
            isOutlined: true,
            onTap: controller.resendEmailLink,
            leadingImage: Icon(
              Icons.refresh_rounded,
              color: CC.textPrimary,
              size: 18,
            ),
          ),

          24.height,

          // Footer Action: Change Email
          Center(
            child: GestureDetector(
              onTap: controller.changeSignUpEmail,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "Use a different email",
                  style: TS.bodySmall(
                    color: CC.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
