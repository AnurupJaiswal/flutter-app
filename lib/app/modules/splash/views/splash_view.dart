import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/splash/controllers/splash_controller.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CC.background,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.skipSplash,
        child: SafeArea(
          child: Stack(
            children: [
              // Central content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [


                      // Brand wordmark
                      RichText(
                        text: TextSpan(
                          text: 'Lala ',
                          style: TS.displayLarge(
                            color: CC.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                          ).copyWith(letterSpacing: -0.6),
                          children: [
                            TextSpan(
                              text: 'Ai',
                              style: TS.displayLarge(
                                color: CC.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 30,
                              ).copyWith(letterSpacing: -0.6),
                            ),
                          ],
                        ),
                      ),

                      10.height,

                      // Tagline
                      Text(
                        "AI-Powered Creator Operating System",
                        textAlign: TextAlign.center,
                        style: TS.bodySmall(
                          color: CC.textSecondary,
                          fontWeight: FontWeight.w500,
                        ).copyWith(letterSpacing: 0.1),
                      ),

                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
