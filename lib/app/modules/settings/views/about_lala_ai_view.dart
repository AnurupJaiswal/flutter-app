import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AboutLalaAiView — Dedicated About page showcasing Lala AI's mission,
/// vision, core creator capabilities, website, social handles, and share flow.
/// ─────────────────────────────────────────────────────────────────────────────
class AboutLalaAiView extends StatelessWidget {
  const AboutLalaAiView({super.key});

  static const String _dummyShareMessage = '''
Boost your content creation with Lala AI!

Spot viral trends before they peak, generate high-converting video scripts, and scale your channel faster.

Android (Google Play):
https://play.google.com/store/apps/details?id=com.lalaai.app

iOS (App Store):
https://apps.apple.com/app/lala-ai/id123456789
''';

  Future<void> _shareApp() async {
    final text = _dummyShareMessage.trim();
    try {
      await Share.share(
        text,
        subject: "Lala AI - AI Co-Pilot for Creators",
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      AppToast.success("App download links copied to clipboard!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CC.isDark;

    return GetBuilder<ThemeService>(
      builder: (_) {
        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            isNotHomepage: true,
            title: "About Lala AI",
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  12.height,
                  // ── App Brand Hero Header ────────────────────────────────
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: CC.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CC.primary.withValues(alpha: 0.25),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: CC.textPrimary,
                        size: 42,
                      ),
                    ),
                  ),
                  16.height,
                  Text(
                    "Lala AI",
                    style: TS.displayLarge(
                      color: CC.textPrimary,
                      fontWeight: FontWeight.w700,
                    ).copyWith(fontSize: 26),
                  ),
                  6.height,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CC.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Version 1.0.0",
                      style: TS.caption(
                        color: CC.primary,
                        fontWeight: FontWeight.w600,
                      ).copyWith(fontSize: 12),
                    ),
                  ),
                  16.height,
                  Text(
                    "Empowering content creators with real-time trend intelligence and AI-driven content automation.",
                    textAlign: TextAlign.center,
                    style: TS.bodySmall(color: CC.textSecondary).copyWith(
                      height: 1.45,
                      fontSize: 14,
                    ),
                  ),
                  20.height,

                  // ── Share Lala AI Button ────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _shareApp,
                      icon: const Icon(Icons.share_rounded, size: 18, color: CC.whiteText),
                      label: Text(
                        "Share Lala AI",
                        style: TS.bodyMedium(
                          color: CC.whiteText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CC.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  28.height,

                  // ── Connect & Official Links ────────────────────────────
                  _buildSectionHeader("Connect & Official Links"),
                  12.height,
                  Container(
                    decoration: BoxDecoration(
                      color: CC.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: CC.stroke.withValues(alpha: isDark ? 0.35 : 0.6),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? CC.black.withValues(alpha: 0.45)
                              : CC.black.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: CC.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.language_rounded, color: CC.textPrimary, size: 18),
                          ),
                          title: Text("Official Website", style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600)),
                          subtitle: Text("https://lala-ai-green.vercel.app", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
                          trailing: Icon(Icons.open_in_new_rounded, color: CC.grey, size: 16),
                          onTap: () async {
                            final url = Uri.parse("https://lala-ai-green.vercel.app");
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else {
                              AppToast.info("Opening https://lala-ai-green.vercel.app...");
                            }
                          },
                        ),
                        Divider(height: 1, thickness: 0.6, color: CC.stroke, indent: 60),
                        ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: CC.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.camera_alt_outlined, color: CC.textPrimary, size: 18),
                          ),
                          title: Text("Instagram", style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600)),
                          subtitle: Text("@lala.ai.official", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
                          trailing: Icon(Icons.open_in_new_rounded, color: CC.grey, size: 16),
                          onTap: () async {
                            final url = Uri.parse("https://instagram.com");
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else {
                              AppToast.info("Opening Instagram...");
                            }
                          },
                        ),
                        Divider(height: 1, thickness: 0.6, color: CC.stroke, indent: 60),
                        ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: CC.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.play_circle_outline_rounded, color: CC.textPrimary, size: 18),
                          ),
                          title: Text("YouTube Channel", style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600)),
                          subtitle: Text("Lala AI Official", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
                          trailing: Icon(Icons.open_in_new_rounded, color: CC.grey, size: 16),
                          onTap: () async {
                            final url = Uri.parse("https://youtube.com");
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else {
                              AppToast.info("Opening YouTube...");
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  28.height,

                  // ── Mission & Vision Section ────────────────────────────
                  _buildSectionHeader("Mission & Vision"),
                  12.height,
                  _buildInfoCard(
                    isDark: isDark,
                    icon: Icons.track_changes_rounded,
                    title: "Our Mission",
                    description: "To empower digital creators, storytellers, and brand strategists with real-time trend intelligence and AI content automation, eliminating creative block and accelerating production.",
                  ),
                  12.height,
                  _buildInfoCard(
                    isDark: isDark,
                    icon: Icons.visibility_outlined,
                    title: "Our Vision",
                    description: "To become the ultimate global creator co-pilot platform, enabling over 10 million creators to build sustainable channels and achieve viral reach across YouTube, Instagram, and beyond.",
                  ),
                  28.height,

                  // ── Core Features Section ────────────────────────────────
                  _buildSectionHeader("Core Capabilities"),
                  12.height,
                  _buildFeatureCard(
                    context,
                    icon: Icons.trending_up_rounded,
                    title: "Real-Time Trend Surges",
                    description: "Discover viral topics across platforms before they peak in popularity.",
                  ),
                  12.height,
                  _buildFeatureCard(
                    context,
                    icon: Icons.auto_awesome_outlined,
                    title: "AI Script & Hook Studio",
                    description: "Generate structured video scripts, hooks, and captions in seconds.",
                  ),
                  12.height,
                  _buildFeatureCard(
                    context,
                    icon: Icons.insights_rounded,
                    title: "Competitor Intelligence",
                    description: "Track channel growth benchmarks and analyze rival content strategies.",
                  ),
                  12.height,
                  _buildFeatureCard(
                    context,
                    icon: Icons.calendar_month_outlined,
                    title: "Content Planner & Calendar",
                    description: "Organize drafts, schedule posts, and maintain a consistent posting rhythm.",
                  ),
                  32.height,
                  Text(
                    "© 2026 Lala AI Inc. All rights reserved.",
                    style: TS.caption(color: CC.grey).copyWith(fontSize: 11),
                  ),
                  16.height,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: TS.caption(
          color: CC.primary,
          fontWeight: FontWeight.w700,
        ).copyWith(fontSize: 11, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildInfoCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CC.stroke.withValues(alpha: isDark ? 0.35 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? CC.black.withValues(alpha: 0.45)
                : CC.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: CC.textPrimary, size: 18),
          ),
          14.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TS.bodySmall(
                    color: CC.textPrimary,
                    fontWeight: FontWeight.w700,
                  ).copyWith(fontSize: 14),
                ),
                4.height,
                Text(
                  description,
                  style: TS.bodySmall(color: CC.textSecondary).copyWith(
                    height: 1.45,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDark = CC.isDark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CC.stroke.withValues(alpha: isDark ? 0.35 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? CC.black.withValues(alpha: 0.4)
                : CC.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: CC.textPrimary, size: 20),
          ),
          14.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TS.bodySmall(
                    color: CC.textPrimary,
                    fontWeight: FontWeight.w600,
                  ).copyWith(fontSize: 14),
                ),
                3.height,
                Text(
                  description,
                  style: TS.caption(color: CC.textSecondary).copyWith(
                    fontSize: 12,
                    height: 1.3,
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
