import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ConnectAccountHeroWidget
///
/// Implements the complete redesigned Lala AI account connection UI:
/// - Single primary "Connect Account" CTA with blue-purple gradient.
/// - Modal platform selection sheet (Instagram & YouTube).
/// - Central orbital hero illustration with 4 non-interactive floating badges.
/// - 3 compact benefits columns.
/// - Supported platforms badge row.
/// - Security assurance pill.
/// ─────────────────────────────────────────────────────────────────────────────
class ConnectAccountHeroWidget extends StatelessWidget {
  final VoidCallback? onConnectAccountTap;
  final Future<void> Function(String platform)? onConnectPlatform;
  final VoidCallback? onConnectInstagram;
  final VoidCallback? onConnectYouTube;
  final bool isConnecting;
  final bool isLoading;
  final String? connectingPlatform;

  const ConnectAccountHeroWidget({
    super.key,
    this.onConnectAccountTap,
    this.onConnectPlatform,
    this.onConnectInstagram,
    this.onConnectYouTube,
    this.isConnecting = false,
    this.isLoading = false,
    this.connectingPlatform,
  });

  bool get _activeLoading => isConnecting || isLoading;

  /// Opens the redesigned platform-selection bottom sheet
  static void showPlatformSelectionSheet({
    required BuildContext context,
    Future<void> Function(String platform)? onSelectPlatform,
    VoidCallback? onSelectInstagram,
    VoidCallback? onSelectYouTube,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return GetBuilder<ThemeService>(
          builder: (_) => Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            decoration: BoxDecoration(
              color: CC.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: CC.isDark
                    ? CC.stroke.withValues(alpha: 0.35)
                    : CC.stroke.withValues(alpha: 0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: CC.isDark
                      ? CC.black.withValues(alpha: 0.6)
                      : CC.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: CC.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Title & Subtitle
                  Text(
                    "Connect a platform",
                    textAlign: TextAlign.center,
                    style: TS.sectionTitle(
                      color: CC.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  6.height,
                  Text(
                    "Choose the account you want to connect",
                    textAlign: TextAlign.center,
                    style: TS.caption(
                      color: CC.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  22.height,

                  // Instagram Option Card
                  _platformOptionCard(
                    title: "Instagram",
                    subtitle: "Connect your Instagram account",
                    brandIcon: CW.instagramIcon(size: 28),
                    gradientColors: [
                      const Color(0xFF833AB4).withValues(alpha: 0.12),
                      const Color(0xFFFD1D1D).withValues(alpha: 0.08),
                      const Color(0xFFF77737).withValues(alpha: 0.12),
                    ],
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      if (onSelectInstagram != null) {
                        onSelectInstagram();
                      } else if (onSelectPlatform != null) {
                        onSelectPlatform("Instagram");
                      }
                    },
                  ),
                  12.height,

                  // YouTube Option Card
                  _platformOptionCard(
                    title: "YouTube",
                    subtitle: "Connect your YouTube channel",
                    brandIcon: CW.youtubeIcon(size: 28),
                    gradientColors: [
                      const Color(0xFFFF0000).withValues(alpha: 0.12),
                      const Color(0xFFFF3333).withValues(alpha: 0.08),
                    ],
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      if (onSelectYouTube != null) {
                        onSelectYouTube();
                      } else if (onSelectPlatform != null) {
                        onSelectPlatform("YouTube");
                      }
                    },
                  ),
                  16.height,

                  // Cancel Button
                  CW.commonBtn(
                    title: "Cancel",
                    isOutlined: true,
                    height: 46,
                    onTap: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _platformOptionCard({
    required String title,
    required String subtitle,
    required Widget brandIcon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CC.isDark ? CC.darkBg2 : CC.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CC.isDark
              ? CC.stroke.withValues(alpha: 0.35)
              : CC.stroke.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CC.isDark
                ? CC.black.withValues(alpha: 0.35)
                : CC.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: brandIcon),
                ),
                14.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TS.sectionTitle(
                          color: CC.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      2.height,
                      Text(
                        subtitle,
                        style: TS.caption(
                          color: CC.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: CC.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        16.height,

        // ── 1. Main Heading & Subtitle ──────────────────────────────
        _buildHeadingSection(),
        20.height,

        // ── 2. Hero Orbital Illustration ────────────────────────────
        _buildHeroIllustration(context),
        24.height,

        // ── 3. ONE Primary CTA ("Connect Account") ───────────────────
        _buildPrimaryCtaButton(context),
        20.height,

        // ── 4. 3-Step Horizontal Flow (Connect → Analyze → Grow) ────
        _buildThreeStepFlow(),
      ],
    );
  }

  // ── Heading Section ───────────────────────────────────────────────
  Widget _buildHeadingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Connect your",
          textAlign: TextAlign.center,
          style: TS.displayLarge(
            color: CC.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ).copyWith(letterSpacing: -0.5, height: 1.15),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF8A2BE2),
              Color(0xFF6366F1),
              Color(0xFF00A3FF),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            "social account",
            textAlign: TextAlign.center,
            style: TS.displayLarge(
              color: const Color(0xFF6366F1),
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ).copyWith(letterSpacing: -0.5, height: 1.15),
          ),
        ),
        10.height,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Connect your Instagram or YouTube to start viewing your content performance and analytics.",
            textAlign: TextAlign.center,
            style: TS.bodySmall(
              color: CC.textSecondary,
              fontSize: 13.5,
            ).copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }

  // ── Hero Orbital Illustration ─────────────────────────────────────
  Widget _buildHeroIllustration(BuildContext context) {
    const double orbitRadius = 64.0;
    const double cardSize = 52.0;
    const double cardGap = (orbitRadius * 2) - cardSize; // Exactly aligns card centers to (-orbitRadius, 0) and (+orbitRadius, 0)

    return SizedBox(
      height: 230,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Orbital Dotted Rings & Glow Background
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(width, 220),
                  painter: _OrbitalRingsPainter(
                    isDark: CC.isDark,
                    orbitRadius: orbitRadius,
                  ),
                ),
              ),

              // ── Center Group: Instagram Card + YouTube Card Centered Directly On Orbit Line ──
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Instagram Frosted Card (Centered on left equator of the circle)
                    _platformCard(
                      size: cardSize,
                      child: CW.instagramIcon(size: 26),
                      accentGlow: const Color(0xFFE1306C).withValues(alpha: 0.22),
                      angle: -0.04,
                    ),
                    SizedBox(width: cardGap),

                    // YouTube Frosted Card (Centered on right equator of the circle)
                    _platformCard(
                      size: cardSize,
                      child: CW.youtubeIcon(size: 26),
                      accentGlow: const Color(0xFFFF0000).withValues(alpha: 0.22),
                      angle: 0.04,
                    ),
                  ],
                ),
              ),

              // ── 4 Floating Badges (Pills) ──────────────────────────
              // 1. Top Left: "Track Performance"
              Positioned(
                top: 6,
                left: math.max(8, width * 0.04),
                child: _floatingBadgePill(
                  icon: Icons.bar_chart_rounded,
                  iconColor: const Color(0xFF0084FF),
                  title: "Track Performance",
                ),
              ),

              // 2. Top Right: "Get Insights"
              Positioned(
                top: 6,
                right: math.max(8, width * 0.04),
                child: _floatingBadgePill(
                  icon: Icons.pie_chart_outline_rounded,
                  iconColor: const Color(0xFFA855F7),
                  title: "Get Insights",
                ),
              ),

              // 3. Bottom Left: "Grow Faster"
              Positioned(
                bottom: 6,
                left: math.max(10, width * 0.05),
                child: _floatingBadgePill(
                  icon: Icons.trending_up_rounded,
                  iconColor: const Color(0xFF06B6D4),
                  title: "Grow Faster",
                ),
              ),

              // 4. Bottom Right: "Reach More People"
              Positioned(
                bottom: 6,
                right: math.max(10, width * 0.05),
                child: _floatingBadgePill(
                  icon: Icons.groups_rounded,
                  iconColor: const Color(0xFF0084FF),
                  title: "Reach More People",
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _platformCard({
    required Widget child,
    required Color accentGlow,
    required double angle,
    double size = 52.0,
  }) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: CC.isDark ? const Color(0xFF18181B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: CC.isDark
                ? CC.stroke.withValues(alpha: 0.4)
                : const Color(0xFFE2E8F0),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: accentGlow,
              blurRadius: 12,
              spreadRadius: 0.5,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: CC.isDark
                  ? CC.black.withValues(alpha: 0.5)
                  : const Color(0xFF64748B).withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _floatingBadgePill({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: CC.isDark ? const Color(0xFF1E2430) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CC.isDark
              ? CC.stroke.withValues(alpha: 0.35)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CC.isDark
                ? CC.black.withValues(alpha: 0.4)
                : const Color(0xFF64748B).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          6.width,
          Text(
            title,
            style: TS.caption(
              color: CC.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── ONE Primary CTA Button ────────────────────────────────────────
  Widget _buildPrimaryCtaButton(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00A3FF),
            Color(0xFF6366F1),
            Color(0xFFA855F7),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.38),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: _activeLoading
              ? null
              : () {
                  if (onConnectAccountTap != null) {
                    onConnectAccountTap!();
                  } else {
                    showPlatformSelectionSheet(
                      context: context,
                      onSelectPlatform: onConnectPlatform,
                      onSelectInstagram: onConnectInstagram,
                      onSelectYouTube: onConnectYouTube,
                    );
                  }
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (_activeLoading) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: Text(
                      connectingPlatform != null
                          ? "Connecting $connectingPlatform..."
                          : "Connecting Account...",
                      textAlign: TextAlign.center,
                      style: TS.button(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ] else ...[
                  // Link Icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.link_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Connect Account",
                      textAlign: TextAlign.center,
                      style: TS.button(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 4. 3-Step Horizontal Flow (Connect → Analyze → Grow) ───────────
  Widget _buildThreeStepFlow() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 3-Step Flow Row (Frameless & responsive)
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _flowStepPill(
                title: "Connect",
                icon: Icons.link_rounded,
                accentColor: const Color(0xFF0084FF),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: CC.textSecondary.withValues(alpha: 0.5),
                ),
              ),
              _flowStepPill(
                title: "Analyze",
                icon: Icons.auto_graph_rounded,
                accentColor: const Color(0xFF6366F1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: CC.textSecondary.withValues(alpha: 0.5),
                ),
              ),
              _flowStepPill(
                title: "Grow",
                icon: Icons.rocket_launch_rounded,
                accentColor: const Color(0xFFA855F7),
              ),
            ],
          ),
        ),
        12.height,

        // Small Caption
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Connect your platform and let Lala turn your content data into actionable insights.",
            textAlign: TextAlign.center,
            style: TS.caption(
              color: CC.textSecondary,
              fontSize: 12,
            ).copyWith(height: 1.35),
          ),
        ),
      ],
    );
  }

  Widget _flowStepPill({
    required String title,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: CC.isDark ? const Color(0xFF1E2430) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: CC.isDark ? 0.35 : 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CC.isDark
                ? CC.black.withValues(alpha: 0.25)
                : accentColor.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accentColor),
          5.width,
          Text(
            title,
            style: TS.caption(
              color: CC.textPrimary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Orbital Rings CustomPainter for the central hero illustration
/// ─────────────────────────────────────────────────────────────────────────────
class _OrbitalRingsPainter extends CustomPainter {
  final bool isDark;
  final double orbitRadius;

  _OrbitalRingsPainter({
    required this.isDark,
    this.orbitRadius = 64.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final primaryGlow = isDark
        ? const Color(0xFF0084FF).withValues(alpha: 0.12)
        : const Color(0xFF0084FF).withValues(alpha: 0.08);

    // Radial background glow behind center
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryGlow,
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: orbitRadius + 36));
    canvas.drawCircle(center, orbitRadius + 36, glowPaint);

    // Outer Dashed / Dotted Orbit Ring
    final ringPaint = Paint()
      ..color = isDark
          ? const Color(0xFF0084FF).withValues(alpha: 0.22)
          : const Color(0xFF0084FF).withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    _drawDashedCircle(canvas, center, orbitRadius, ringPaint);

    // Small planetary orbit dots on the orbital line
    final dotPaint1 = Paint()
      ..color = const Color(0xFF0084FF).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final dotPaint2 = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final dotPaint3 = Paint()
      ..color = const Color(0xFF06B6D4).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    // Dot at ~50 deg (bottom-right arc)
    canvas.drawCircle(
      Offset(
        center.dx + orbitRadius * math.cos(math.pi * 0.28),
        center.dy + orbitRadius * math.sin(math.pi * 0.28),
      ),
      3.5,
      dotPaint1,
    );

    // Dot at ~130 deg (bottom-left arc)
    canvas.drawCircle(
      Offset(
        center.dx + orbitRadius * math.cos(math.pi * 0.72),
        center.dy + orbitRadius * math.sin(math.pi * 0.72),
      ),
      4.0,
      dotPaint2,
    );

    // Dot at ~230 deg (top-left arc)
    canvas.drawCircle(
      Offset(
        center.dx + orbitRadius * math.cos(math.pi * 1.28),
        center.dy + orbitRadius * math.sin(math.pi * 1.28),
      ),
      3.0,
      dotPaint3,
    );

    // Dot at ~310 deg (top-right arc)
    canvas.drawCircle(
      Offset(
        center.dx + orbitRadius * math.cos(math.pi * 1.72),
        center.dy + orbitRadius * math.sin(math.pi * 1.72),
      ),
      3.5,
      dotPaint1,
    );
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const int dashCount = 36;
    const double dashAngle = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          i * dashAngle,
          dashAngle * 0.65,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitalRingsPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.orbitRadius != orbitRadius;
  }
}
