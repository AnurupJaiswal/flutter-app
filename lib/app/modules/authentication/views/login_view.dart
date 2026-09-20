import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/controllers/auth_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/constants.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.loginFormKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Brand Logo & Wordmark
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: CC.tealSubtle,
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
                  style: TS.sectionTitle(color: CC.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                  children: [
                    TextSpan(
                      text: 'Ai',
                      style: TS.sectionTitle(color: CC.primary, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),

          24.height,

          // 2. Large Bold Heading & Subtitle (Netflix Style)
          Text(
            "Sign In",
            style: TS.displayLarge(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          6.height,
          Text(
            "Sign in to continue to your workspace",
            style: TS.subHeading(color: CC.textSecondary, fontSize: 13.5),
          ),

          28.height,

          // 3. Email Field
          CW.commonTextFormField(
            controller: controller.loginEmailController,
            hintText: "name@company.com",
            labelText: "Email",
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
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

          18.height,

          // 4. Password Field
          Obx(() => CW.commonTextFormField(
                controller: controller.loginPasswordController,
                hintText: "••••••••",
                labelText: "Password",
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: controller.isPasswordHidden.value,
                textInputAction: TextInputAction.done,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordHidden.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: CC.grey,
                    size: 18,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Please enter your password.";
                  }
                  if (val.length < AppConstants.minPasswordLength) {
                    return "Password must be at least ${AppConstants.minPasswordLength} characters.";
                  }
                  return null;
                },
                onFieldSubmitted: (_) => controller.signIn(),
              )),

          10.height,

          // 5. Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: controller.forgotPassword,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "Forgot password?",
                  style: TS.caption(
                    color: CC.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          ),

          24.height,

          // 6. Primary Sign In Action Button (Full-width)
          Obx(() => CW.commonBtn(
                title: "Sign In",
                height: 50,
                isLoading: controller.isLoading.value,
                onTap: controller.signIn,
              )),


        ],
      ),
    );
  }
}
