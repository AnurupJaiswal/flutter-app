import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────
// WelcomeView — Redesigned according to the latest reference
// ─────────────────────────────────────────────────────────────────
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  void _goToSignIn() => Get.toNamed(Routes.AUTHENTICATION);

  Future<void> _openSignupWebsite() async {
    const url = ApiEndpoints.signupUrl  ;
    final uri = Uri.parse(url);
    try {
      if (Platform.isAndroid) {
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
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (_) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: CC.isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: CC.isDark ? Brightness.dark : Brightness.light,
        ));

        return Scaffold(
          backgroundColor: CC.background,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHeader(),
                          16.height,
                          _buildCompactFeatureGrid(),
                          20.height,
                          _buildHero(),
                          24.height,
                          _buildBottomCta(),
                          16.height,
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Lala ',
                  style: TS.sectionTitle(
                    color: CC.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ).copyWith(height: 1.1),
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
              2.height,
              Text(
                'C R E A T E   P L A N   G R O W',
                style: TS.caption(
                  color: CC.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 7.5,
                ).copyWith(letterSpacing: 1.5),
              ),
            ],
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Material(
              color: CC.primary,
              child: InkWell(
                onTap: _goToSignIn,
                splashColor: CC.white.withValues(alpha: 0.20),
                highlightColor: CC.white.withValues(alpha: 0.10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Sign In',
                    style: TS.button(
                      color: CC.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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

  // ── Compact Feature Grid ─────────────────────────────────────────────
  Widget _buildCompactFeatureGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.3, // wider, horizontal layout
      children: [
        _compactFeatureCard('AI Scripts', 'Ideas to videos', Icons.movie_creation_outlined),
        _compactFeatureCard('Trend Radar', 'What\'s trending', Icons.trending_up_rounded),
        _compactFeatureCard('Analytics', 'Track & grow', Icons.bar_chart_rounded),
        _compactFeatureCard('Calendar', 'Plan with ease', Icons.calendar_today_rounded),
      ],
    );
  }

  Widget _compactFeatureCard(String title, String desc, IconData icon) {
    final bgColor = CC.isDark ? const Color(0xFF0F1520) : const Color(0xFFF7F8FA);
    final borderColor = CC.isDark ? const Color(0xFF182845) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        children: [
          Icon(icon, color: CC.primary, size: 20),
          10.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TS.bodyMedium(
                    color: CC.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                2.height,
                Text(
                  desc,
                  style: TS.caption(
                    color: CC.textSecondary,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero text block ──────────────────────────────────────────
  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BUILT FOR CREATORS',
          style: TS.caption(
            color: CC.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ).copyWith(letterSpacing: 1.5),
        ),
        16.height,
        RichText(
          text: TextSpan(
            text: 'AI tools,\ninsights,\nand more \u2014\n',
            style: TS.displayLarge(
              color: CC.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 34,
            ).copyWith(height: 1.15, letterSpacing: -1.0),
            children: [
              TextSpan(
                text: 'in just a few taps.',
                style: TS.displayLarge(
                  color: CC.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 34,
                ).copyWith(height: 1.15, letterSpacing: -1.0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Bottom CTA card ──────────────────────────────────────────
  Widget _buildBottomCta() {
    final bgColor = CC.isDark ? const Color(0xFF0C1017) : const Color(0xFFFAFAFA);
    final borderColor = CC.isDark ? const Color(0xFF1E3A6D).withValues(alpha: 0.5) : const Color(0xFFD6E6FF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CC.primary.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: CC.primary,
                    size: 22,
                  ),
                ),
              ),
              16.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create a Lala AI account',
                      style: TS.bodyMedium(
                        color: CC.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    4.height,
                    Text(
                      'and unlock all creator features.',
                      style: TS.caption(
                        color: CC.textSecondary,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          20.height,
          GestureDetector(
            onTap: _openSignupWebsite,
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: CC.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Get Started on Website',
                    style: TS.button(
                      color: CC.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  6.width,
                  const Icon(Icons.arrow_forward_rounded, color: CC.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer Metrics ───────────────────────────────────────────
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _footerItem(Icons.bolt_rounded, 'Create\nFaster'),
        _footerDivider(),
        _footerItem(Icons.bar_chart_rounded, 'Make Better\nContent'),
        _footerDivider(),
        _footerItem(Icons.group_rounded, 'Grow Your\nAudience'),
      ],
    );
  }

  Widget _footerItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: CC.textPrimary, size: 20),
        8.width,
        Text(
          text,
          style: TS.caption(
            color: CC.textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 10,
          ).copyWith(height: 1.2),
        ),
      ],
    );
  }

  Widget _footerDivider() {
    return Container(
      width: 1,
      height: 20,
      color: CC.textSecondary.withValues(alpha: 0.3),
    );
  }
}
