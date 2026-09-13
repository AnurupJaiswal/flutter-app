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
                      // Brand icon badge with entrance animation
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: 0.85 + (0.15 * value),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: CC.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                              width: 0.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: CC.isDark
                                    ? Colors.black.withValues(alpha: 0.35)
                                    : Colors.black.withValues(alpha: 0.08),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: CC.textPrimary,
                              size: 30,
                            ),
                          ),
                        ),
                      ),

                      24.height,

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