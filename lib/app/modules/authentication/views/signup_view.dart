import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/controllers/auth_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey('signup_view_simple'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Brand Wordmark
          RichText(
            text: TextSpan(
              text: 'Lala ',
              style: TS.sectionTitle(
                color: CC.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(
                  text: 'Ai',
                  style: TS.sectionTitle(
                    color: CC.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          32.height,

          // Title & Subtitle
          Text(
            "Create Your Account",
            style: TS.displayLarge(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          12.height,
          Text(
            "New users need to create their account on our website.",
            style: TS.subHeading(color: CC.textSecondary, fontSize: 14.5),
          ),

          32.height,

          // Primary Action Button (Sign Up on Website)
          CW.commonBtn(
            title: "Sign Up on Website",
            height: 50,
            onTap: controller.openSignupWebsite,
            leadingImage: const Icon(
              Icons.open_in_browser_rounded,
              color: CC.whiteText,
              size: 20,
            ),
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
    );
  }
}
