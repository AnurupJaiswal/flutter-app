import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────
// WelcomeView — single immersive screen with AI background image.
// Theme-aware: follows the same GetBuilder<ThemeService> + CC.*
// pattern used by HomeView, SettingsView, AuthenticationView.
// ─────────────────────────────────────────────────────────────────
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  void _goToSignIn() => Get.toNamed(Routes.AUTHENTICATION);

  Future<void> _openSignupWebsite() async {
    const url = 'https://lala.ai/signup';
    final uri = Uri.parse(url);
    try {
      if (Platform.isAndroid) {
        // Open specifically in Chrome; fall back to default browser
        final chromeIntent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: url,
          package: 'com.android.chrome',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        try {
          await chromeIntent.launch();
          return;
        } catch (_) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        // iOS: opens in Safari
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // ── Identical GetBuilder<ThemeService> wrapper used by all screens ──
    return GetBuilder<ThemeService>(
      builder: (_) {
        // Background image is always dark — status bar icons always light.
        // Brightness values are kept constant intentionally; the scrim
        // ensures readability in both dark and light app themes.
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ));

        // ── Theme-derived overlay opacities ─────────────────────────
        // Dark mode: deeper scrims. Light mode: slightly lighter scrims
        // so the image shows through more, acknowledging the lighter theme.
        final topScrims = CC.isDark
            ? const [Color(0xCC000000), Colors.transparent]
            : const [Color(0xAA000000), Colors.transparent];

        final bottomScrims = CC.isDark
            ? const [Colors.transparent, Color(0xDD000000), Color(0xFF000000)]
            : const [Colors.transparent, Color(0xCC000000), Color(0xEE000000)];

        // ── CTA card: same surface token as other cards in the app ───
        // On this screen the bg image is always dark, so we keep a dark
        // glass card in both modes but slightly more opaque in light mode.
        final ctaCardBg = CC.isDark
            ? const Color(0xCC0D0D0D)
            : const Color(0xEE111111);

        return Scaffold(
          // CC.background = black in dark mode, white in light mode.
          // Sits behind the full-screen image so rarely visible, but
          // correct for edge cases (image load delay, overscan, etc.)
          backgroundColor: CC.background,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. Background image ────────────────────────────
              Image.asset(
                'assets/images/welcome_bg.jpg',
                fit: BoxFit.cover,
              ),

              // ── 2. Gradient overlays ───────────────────────────
              // IgnorePointer: prevents transparent overlay Containers
              // from absorbing touch events (critical bug fix).
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: const Alignment(0, 0.35),
                      colors: topScrims,
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: const Alignment(0, 0.40),
                      end: Alignment.bottomCenter,
                      colors: bottomScrims,
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),

              // ── 3. Content ─────────────────────────────────────
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const Spacer(),
                    _buildHero(),
                    32.height,
                    _buildBottomCta(ctaCardBg),
                    24.height,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 14, 0),
      child: Row(
        children: [
          // Brand icon badge — CC.primary for tint, CC.white for bg tint
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              // Subtle primary-tinted badge: same pattern as HomeView logo
              color: CC.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: CC.primary.withValues(alpha: 0.33),
                width: 0.8,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                color: CC.primary,
                size: 18,
              ),
            ),
          ),
          10.width,
          // Brand wordmark — CC.white is a fixed constant (always white)
          // appropriate here since the bg is always the dark image
          RichText(
            text: TextSpan(
              text: 'Lala ',
              style: TS.sectionTitle(
                color: CC.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              children: [
                TextSpan(
                  text: 'Ai',
                  style: TS.sectionTitle(
                    color: CC.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Sign In button — CC.primary bg, CC.white text, InkWell ripple
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Material(
              color: CC.primary,
              child: InkWell(
                onTap: _goToSignIn,
                splashColor: CC.white.withValues(alpha: 0.20),
                highlightColor: CC.white.withValues(alpha: 0.10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),
                  child: Text(
                    'Sign In',
                    style: TS.button(
                      color: CC.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero text block ──────────────────────────────────────────
  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Feature pill tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _featureTag('AI Scripts', Icons.auto_awesome_rounded),
              _featureTag('Trend Radar', Icons.trending_up_rounded),
              _featureTag('Analytics', Icons.bar_chart_rounded),
              _featureTag('Calendar', Icons.calendar_month_rounded),
            ],
          ),
          20.height,
          // Main headline — CC.white (fixed constant, always white)
          Text(
            'AI tools, insights,\nand more \u2014 in\njust a few taps.',
            style: TS.displayLarge(
              color: CC.white,
              fontWeight: FontWeight.w700,
              fontSize: 32,
            ).copyWith(height: 1.16, letterSpacing: -0.8),
          ),
          14.height,
          // Sub-headline — CC.white at 73% opacity
          Text(
            'The AI-powered creator operating system\nbuilt for serious content creators.',
            style: TS.subHeading(
              color: CC.white.withValues(alpha: 0.73),
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ).copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _featureTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        // CC.primary tinted fill + border — same pattern as HomeView chips
        color: CC.primary.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CC.primary.withValues(alpha: 0.27),
          width: 0.7,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: CC.primary, size: 11),
          5.width,
          Text(
            label,
            style: TS.caption(
              color: CC.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom CTA card ──────────────────────────────────────────
  Widget _buildBottomCta(Color cardBg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _openSignupWebsite,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            // CC.borderSubtle adapts: dark=Color(0xFF262626), light=Color(0xFFE2E8F0)
            border: Border.all(color: CC.borderSubtle, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a Lala AI account and unlock\nall AI creator features.',
                style: TS.bodySmall(
                  color: CC.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ).copyWith(height: 1.5),
              ),
              6.height,
              Text(
                'Go to lala.ai/signup \u2192',
                // CC.primary = #108CFF in both dark and light mode
                style: TS.caption(
                  color: CC.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
