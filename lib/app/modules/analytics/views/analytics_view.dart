import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/analytics/controllers/analytics_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AnalyticsController>()
        ? Get.find<AnalyticsController>()
        : Get.put(AnalyticsController());

    return GetBuilder<ThemeService>(
      builder: (themeService) {
        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            titleWidget: Row(
              children: [
                Icon(Icons.analytics_rounded, color: CC.primary, size: 20),
                8.width,
                Text("Channel Analytics", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16)),
              ],
            ),
            wantBackIcon: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Header Controls: Platform Selector & Account Card ────
                  _buildHeaderControls(controller),
                  20.height,

                  // ── 1. Overall Channel Score (Compact Hero Section) ──────────
                  _buildSectionHeader("OVERALL CHANNEL SCORE"),
                  8.height,
                  _buildOverallScoreCard(controller),
                  20.height,

                  // ── 2. Key Performance Metrics Grid ──────────────────────────
                  _buildSectionHeader("KEY PERFORMANCE METRICS"),
                  8.height,
                  _buildKeyMetricsGrid(controller),
                  20.height,

                  // ── 3. Audience Growth Graph ──────────────────────────────────
                  _buildSectionHeader("AUDIENCE GROWTH"),
                  8.height,
                  _buildAudienceGrowthCard(controller),
                  20.height,

                  // ── 4. Views Graph ───────────────────────────────────────────
                  _buildSectionHeader("VIEWS OVER TIME"),
                  8.height,
                  _buildViewsGraphCard(controller),
                  20.height,

                  // ── 5. Engagement Graph ──────────────────────────────────────
                  _buildSectionHeader("ENGAGEMENT & INTERACTIONS"),
                  8.height,
                  _buildEngagementGraphCard(controller),
                  20.height,

                  // ── 6. Content Activity ──────────────────────────────────────
                  _buildSectionHeader("CONTENT ACTIVITY & CONSISTENCY"),
                  8.height,
                  _buildContentActivityCard(controller),
                  20.height,

                  // ── 7. Top Performing Content ────────────────────────────────
                  _buildSectionHeader("TOP PERFORMING CONTENT"),
                  8.height,
                  _buildTopPerformingList(controller),
                  32.height,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TS.caption(
        color: CC.textSecondary,
        fontWeight: FontWeight.w700,
      ).copyWith(letterSpacing: 1.1, fontSize: 11),
    );
  }

  // ── Header Controls: Platform Switcher & Connected Account Profile Card ──────
  Widget _buildHeaderControls(AnalyticsController controller) {
    return Column(
      children: [
        // Tab Switcher Bar (Instagram vs YouTube)
        Obx(() {
          final selPlatform = controller.selectedPlatform.value;

          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: CC.isDark ? CC.darkBg2 : CC.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: CC.isDark ? CC.black.withValues(alpha: 0.4) : CC.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _platformTab(
                    title: "Instagram",
                    icon: CW.instagramIcon(size: 20),
                    isSelected: selPlatform == "Instagram",
                    onTap: () => controller.setPlatform("Instagram"),
                  ),
                ),
                4.width,
                Expanded(
                  child: _platformTab(
                    title: "YouTube",
                    icon: CW.youtubeIcon(size: 20),
                    isSelected: selPlatform == "YouTube",
                    onTap: () => controller.setPlatform("YouTube"),
                  ),
                ),
              ],
            ),
          );
        }),
        12.height,

        // Account Profile & Date Range Bar
        Obx(() {
          final acc = controller.accountDetails;
          final selRange = controller.selectedDateRange.value;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CC.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: CC.isDark ? CC.black.withValues(alpha: 0.3) : CC.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Profile Avatar with Status Badge
                    Stack(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: CC.primary, width: 1.5),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              acc["avatar"] as String,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(Icons.person, color: CC.primary),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                              border: Border.all(color: CC.surface, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    12.width,

                    // Account Handle & Connected Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  acc["name"] as String,
                                  style: TS.sectionTitle(color: CC.textPrimary, fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              4.width,
                              Icon(Icons.verified_rounded, color: CC.primary, size: 15),
                            ],
                          ),
                          3.height,
                          Text(
                            "${acc['handle']} • Connected",
                            style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                12.height,

                // Date Range Segmented Selector
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: CC.isDark ? CC.whiteText.withValues(alpha: 0.05) : CC.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: controller.dateRangeOptions.map((range) {
                      final isSelected = selRange == range;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => controller.setDateRange(range),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? CC.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                range,
                                style: TS
                                    .caption(
                                      color: isSelected ? CC.whiteText : CC.textSecondary,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    )
                                    .copyWith(fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _platformTab({
    required String title,
    required Widget icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? CC.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            8.width,
            Text(
              title,
              style: TS
                  .bodySmall(
                    color: isSelected ? CC.whiteText : CC.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  )
                  .copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. Overall Channel Score Hero Card ────────────────────────────────────
  Widget _buildOverallScoreCard(AnalyticsController controller) {
    return Obx(() {
      final scoreData = controller.channelScoreData;
      final score = scoreData["score"] as int;
      final status = scoreData["status"] as String;
      final subtitle = scoreData["subtitle"] as String;
      final breakdown = scoreData["breakdown"] as List<Map<String, dynamic>>;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CC.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6), width: 1),
          boxShadow: [
            BoxShadow(
              color: CC.isDark ? CC.black.withValues(alpha: 0.35) : CC.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "$score",
                        style: TS.displayLarge(
                          color: CC.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 34,
                        ),
                      ),
                      Text(
                        "/100",
                        style: TS.sectionTitle(color: CC.textSecondary, fontSize: 16),
                      ),
                      10.width,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TS.caption(
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w700,
                          ).copyWith(fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CC.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome_rounded, color: CC.primary, size: 20),
                ),
              ],
            ),
            8.height,
            Text(
              subtitle,
              style: TS.bodySmall(color: CC.textSecondary).copyWith(fontSize: 13, height: 1.45),
            ),
            16.height,

            // 4 Subtle Progress Bar Indicators
            Column(
              children: breakdown.map((item) {
                final title = item["title"] as String;
                final val = item["value"] as double;
                final label = item["label"] as String;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(title, style: TS.caption(color: CC.textPrimary, fontWeight: FontWeight.w600)),
                          Text(label, style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      5.height,
                      Container(
                        height: 7,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: CC.isDark ? CC.whiteText.withValues(alpha: 0.08) : CC.black.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final barColor = val > 0.8 ? CC.primary : (val > 0.7 ? Colors.teal : Colors.amber);
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: constraints.maxWidth * val,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  IconData _getMetricIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('follower') || t.contains('subscriber')) return Icons.people_alt_outlined;
    if (t.contains('view')) return Icons.play_circle_outline_rounded;
    if (t.contains('like')) return Icons.favorite_border_rounded;
    if (t.contains('consistency')) return Icons.event_repeat_rounded;
    if (t.contains('comment')) return Icons.chat_bubble_outline_rounded;
    if (t.contains('content') || t.contains('post')) return Icons.video_library_outlined;
    if (t.contains('engagement')) return Icons.bolt_rounded;
    return Icons.bar_chart_rounded;
  }

  Color _getMetricColor(String title) {
    final t = title.toLowerCase();
    if (t.contains('follower') || t.contains('subscriber')) return CC.primary;
    if (t.contains('view')) return Colors.teal;
    if (t.contains('like')) return const Color(0xFFE1306C);
    if (t.contains('consistency')) return const Color(0xFFFFB300);
    if (t.contains('comment')) return Colors.purpleAccent;
    if (t.contains('content') || t.contains('post')) return Colors.amber.shade700;
    if (t.contains('engagement')) return Colors.deepOrangeAccent;
    return CC.primary;
  }

  // ── 2. Key Performance Metrics Grid ───────────────────────────────────────
  Widget _buildKeyMetricsGrid(AnalyticsController controller) {
    return Obx(() {
      final metrics = controller.keyMetrics;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: metrics.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
        ),
        itemBuilder: (context, index) {
          final m = metrics[index];
          final title = m["title"] as String;
          final val = m["value"] as String;
          final change = m["change"] as String;
          final isUp = m["isUp"] as bool;
          final iconData = _getMetricIcon(title);
          final iconColor = _getMetricColor(title);

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CC.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: CC.isDark ? CC.black.withValues(alpha: 0.25) : CC.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Custom Icon Container + Growth Badge Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(iconData, color: iconColor, size: 19),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: isUp ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            size: 10,
                            color: isUp ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                          ),
                          2.width,
                          Text(
                            change,
                            style: TS.caption(
                              color: isUp ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                              fontWeight: FontWeight.w700,
                            ).copyWith(fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Bottom Section: Prominent Stat Value & Clean Title Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        val,
                        style: TS.displayLarge(
                          color: CC.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    3.height,
                    Text(
                      title,
                      style: TS.caption(color: CC.textSecondary).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  // ── 3. Audience Growth Card ───────────────────────────────────────────────
  Widget _buildAudienceGrowthCard(AnalyticsController controller) {
    return Obx(() {
      final growth = controller.audienceGrowthData;
      final start = growth["start"] as String;
      final end = growth["end"] as String;
      final gain = growth["gain"] as String;
      final points = (growth["points"] as List).cast<double>();
      final labels = (growth["timeLabels"] as List).cast<String>();

      return _styledCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Followers", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12)),
                      4.height,
                      Text(
                        "$start → $end",
                        style: TS.sectionTitle(color: CC.textPrimary, fontSize: 17),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                8.width,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    gain,
                    style: TS.caption(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w700).copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
            16.height,

            // Smooth Line Chart
            SizedBox(
              height: 130,
              width: double.infinity,
              child: CustomPaint(
                painter: _SmoothLineChartPainter(
                  dataPoints: points,
                  lineColor: CC.primary,
                  gradientFill: true,
                ),
              ),
            ),
            10.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels.map((l) => Text(l, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11))).toList(),
            ),
          ],
        ),
      );
    });
  }

  // ── 4. Views Graph Card ───────────────────────────────────────────────────
  Widget _buildViewsGraphCard(AnalyticsController controller) {
    return Obx(() {
      final views = controller.viewsData;
      final total = views["totalViews"] as String;
      final avg = views["avgViews"] as String;
      final change = views["change"] as String;
      final insight = views["insight"] as String;
      final points = (views["points"] as List).cast<double>();
      final labels = (views["timeLabels"] as List).cast<String>();

      return _styledCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Views", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12)),
                      4.height,
                      Text(total, style: TS.sectionTitle(color: CC.textPrimary, fontSize: 22)),
                    ],
                  ),
                ),
                8.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        change,
                        style: TS.caption(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w700).copyWith(fontSize: 11),
                      ),
                    ),
                    4.height,
                    Text("Avg: $avg", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
                  ],
                ),
              ],
            ),
            16.height,

            // Area Chart
            SizedBox(
              height: 130,
              width: double.infinity,
              child: CustomPaint(
                painter: _SmoothLineChartPainter(
                  dataPoints: points,
                  lineColor: Colors.teal,
                  gradientFill: true,
                ),
              ),
            ),
            10.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels.map((l) => Text(l, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11))).toList(),
            ),
            14.height,

            // Insight Description (Un-nested)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_rounded, color: CC.primary, size: 15),
                6.width,
                Expanded(
                  child: Text(
                    insight,
                    style: TS.caption(color: CC.textSecondary, fontWeight: FontWeight.w500).copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ── 5. Engagement Graph Card ──────────────────────────────────────────────
  Widget _buildEngagementGraphCard(AnalyticsController controller) {
    return Obx(() {
      final eng = controller.engagementData;
      final avgRate = eng["avgRate"] as String;
      final likesCount = eng["likesCount"] as String;
      final commentsCount = eng["commentsCount"] as String;
      final likesPts = (eng["likesPoints"] as List).cast<double>();
      final commentsPts = (eng["commentsPoints"] as List).cast<double>();
      final labels = (eng["timeLabels"] as List).cast<String>();

      return _styledCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Average Engagement Rate",
                        style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.height,
                      Text(avgRate, style: TS.sectionTitle(color: CC.textPrimary, fontSize: 22)),
                    ],
                  ),
                ),
                8.width,
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CC.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "$likesCount likes · $commentsCount comments",
                      style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            16.height,

            // Dual Line Chart
            SizedBox(
              height: 130,
              width: double.infinity,
              child: CustomPaint(
                painter: _DualLineChartPainter(
                  line1Points: likesPts,
                  line2Points: commentsPts,
                  color1: CC.primary,
                  color2: Colors.purpleAccent,
                ),
              ),
            ),
            10.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels.map((l) => Text(l, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11))).toList(),
            ),
            12.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem(CC.primary, "Likes Trend"),
                18.width,
                _legendItem(Colors.purpleAccent, "Comments Trend"),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        6.width,
        Text(label, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
      ],
    );
  }

  // ── 6. Content Activity Card ──────────────────────────────────────────────
  Widget _buildContentActivityCard(AnalyticsController controller) {
    return Obx(() {
      final act = controller.contentActivityData;
      final total = act["total"] as String;
      final avg = act["avg"] as String;
      final best = act["best"] as String;
      final bars = (act["weeklyBars"] as List<Map<String, dynamic>>);

      return _styledCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        total,
                        style: TS.sectionTitle(color: CC.textPrimary, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      3.height,
                      Text(
                        avg,
                        style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                8.width,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Consistent",
                    style: TS.caption(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w700).copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
            16.height,

            // Weekly Bars
            SizedBox(
              height: 115,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: bars.map((b) {
                  final week = b["week"] as String;
                  final count = b["count"] as int;
                  final label = b["label"] as String;
                  final ratio = (count / 5.0).clamp(0.2, 1.0);

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          label,
                          style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 10),
                        ),
                        6.height,
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 26,
                          height: ratio * 70,
                          decoration: BoxDecoration(
                            color: count >= 4 ? CC.primary : CC.primary.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        8.height,
                        Text(
                          week,
                          style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            12.height,

            // Best performing week callout (Un-nested)
            Row(
              children: [
                Text(
                  "🔥 $best",
                  style: TS.caption(color: CC.textSecondary, fontWeight: FontWeight.w500).copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ── 7. Top Performing Content List ─────────────────────────────────────────
  Widget _buildTopPerformingList(AnalyticsController controller) {
    return Obx(() {
      final posts = controller.topPerformingContent;

      return Column(
        children: posts.map((p) {
          final rank = p["rank"] as String;
          final title = p["title"] as String;
          final platform = p["platform"] as String;
          final views = p["views"] as String;
          final likes = p["likes"] as String;
          final comments = p["comments"] as String;
          final engagement = p["engagement"] as String;
          final thumb = p["thumbnail"] as String;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CC.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6), width: 1),
              boxShadow: [
                BoxShadow(
                  color: CC.isDark ? CC.black.withValues(alpha: 0.25) : CC.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Rank circle
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: rank == "01"
                        ? CC.primary
                        : (CC.isDark ? CC.whiteText.withValues(alpha: 0.08) : CC.black.withValues(alpha: 0.05)),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      rank,
                      style: TS
                          .caption(
                            color: rank == "01" ? CC.whiteText : CC.textPrimary,
                            fontWeight: FontWeight.w700,
                          )
                          .copyWith(fontSize: 11),
                    ),
                  ),
                ),
                8.width,

                // Thumbnail preview
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Image.asset(
                          thumb,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: CC.stroke,
                            child: Icon(Icons.movie_rounded, color: CC.primary, size: 20),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 3,
                      bottom: 3,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: CC.black.withValues(alpha: 0.54),
                          shape: BoxShape.circle,
                        ),
                        child: platform == "YouTube" ? CW.youtubeIcon(size: 10) : CW.instagramIcon(size: 10),
                      ),
                    ),
                  ],
                ),
                10.width,

                // Title & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TS.sectionTitle(color: CC.textPrimary, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.height,
                      Row(
                        children: [
                          Text(
                            views,
                            style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 11),
                          ),
                          4.width,
                          Text("•", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 10)),
                          4.width,
                          Expanded(
                            child: Text(
                              "$likes likes · $comments comments",
                              style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                6.width,

                // Engagement Rate Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: CC.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    engagement,
                    style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 10.5),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  // ── Reusable Card Shell ────────────────────────────────────────────────────
  Widget _styledCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CC.isDark ? CC.black.withValues(alpha: 0.35) : CC.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Custom Painter: Smooth Curved Line/Area Chart ────────────────────────────
class _SmoothLineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final bool gradientFill;

  _SmoothLineChartPainter({
    required this.dataPoints,
    required this.lineColor,
    required this.gradientFill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    // Padding on left & right so the graph line smoothly curves inside the canvas on both sides
    const paddingX = 12.0;
    final usableWidth = size.width - (paddingX * 2);
    final dx = usableWidth / (dataPoints.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < dataPoints.length; i++) {
      final x = paddingX + (i * dx);
      final normalizedY = (dataPoints[i] - minVal) / range;
      final y = size.height - (normalizedY * (size.height - 30) + 15);
      points.add(Offset(x, y));
    }

    // Smooth Bezier Curve Path with organic spline control points
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final p0 = i > 0 ? points[i - 1] : p1;
      final p3 = i < points.length - 2 ? points[i + 2] : p2;

      final cp1 = Offset(p1.dx + (p2.dx - p0.dx) / 4, p1.dy + (p2.dy - p0.dy) / 4);
      final cp2 = Offset(p2.dx - (p3.dx - p1.dx) / 4, p2.dy - (p3.dy - p1.dy) / 4);

      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    if (gradientFill) {
      final areaPath = Path.from(linePath)
        ..lineTo(points.last.dx, size.height - 4)
        ..cubicTo(
          points.last.dx, size.height,
          points.last.dx - 8, size.height,
          points.last.dx - 12, size.height,
        )
        ..lineTo(points.first.dx + 12, size.height)
        ..cubicTo(
          points.first.dx + 8, size.height,
          points.first.dx, size.height,
          points.first.dx, size.height - 4,
        )
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.35),
            lineColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(areaPath, fillPaint);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // Glowing Start Indicator Dot (Left side)
    final firstPt = points.first;
    canvas.drawCircle(firstPt, 5, Paint()..color = lineColor.withValues(alpha: 0.25));
    canvas.drawCircle(firstPt, 3.5, Paint()..color = lineColor);

    // Glowing End Indicator Dot (Right side)
    final lastPt = points.last;
    canvas.drawCircle(lastPt, 7, Paint()..color = lineColor.withValues(alpha: 0.35));
    canvas.drawCircle(lastPt, 4.5, Paint()..color = lineColor);
    canvas.drawCircle(lastPt, 2, Paint()..color = CC.whiteText);
  }

  @override
  bool shouldRepaint(covariant _SmoothLineChartPainter oldDelegate) => true;
}

// ── Custom Painter: Dual Line Chart for Engagement Trends ─────────────────────
class _DualLineChartPainter extends CustomPainter {
  final List<double> line1Points;
  final List<double> line2Points;
  final Color color1;
  final Color color2;

  _DualLineChartPainter({
    required this.line1Points,
    required this.line2Points,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawLine(canvas, size, line1Points, color1);
    _drawLine(canvas, size, line2Points, color2);
  }

  void _drawLine(Canvas canvas, Size size, List<double> dataPoints, Color color) {
    if (dataPoints.isEmpty) return;

    // Padding on left & right so curves exist on both sides
    const paddingX = 12.0;
    final usableWidth = size.width - (paddingX * 2);
    final dx = usableWidth / (dataPoints.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < dataPoints.length; i++) {
      final x = paddingX + (i * dx);
      final normalizedY = (dataPoints[i] / 100.0).clamp(0.0, 1.0);
      final y = size.height - (normalizedY * (size.height - 30) + 15);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final p0 = i > 0 ? points[i - 1] : p1;
      final p3 = i < points.length - 2 ? points[i + 2] : p2;

      final cp1 = Offset(p1.dx + (p2.dx - p0.dx) / 4, p1.dy + (p2.dy - p0.dy) / 4);
      final cp2 = Offset(p2.dx - (p3.dx - p1.dx) / 4, p2.dy - (p3.dy - p1.dy) / 4);

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);

    for (final pt in points) {
      canvas.drawCircle(pt, 3.5, Paint()..color = color);
      canvas.drawCircle(pt, 1.8, Paint()..color = CC.whiteText);
    }
  }

  @override
  bool shouldRepaint(covariant _DualLineChartPainter oldDelegate) => true;
}
