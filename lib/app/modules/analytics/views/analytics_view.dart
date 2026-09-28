import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/analytics/controllers/analytics_controller.dart';
import 'package:lala_ai/app/modules/connect_accounts/views/connect_accounts_view.dart';
import 'package:lala_ai/core/widgets/skeleton/app_skeleton.dart';
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
      builder: (_) {
        return Scaffold(
      backgroundColor: CC.background,
      appBar: CW.commonAppbar(
        titleWidget: Row(
          children: [
            Icon(Icons.analytics_rounded, color: CC.primary, size: 20),
            8.width,
            Text(
              "Channel Analytics",
              style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16),
            ),
          ],
        ),
        wantBackIcon: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.refreshAnalytics(),
          notificationPredicate: (notification) =>
              !controller.isLoading.value &&
              defaultScrollNotificationPredicate(notification),
          color: CC.primary,
          backgroundColor: CC.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Obx(() {
              if (!controller.hasAnyChannels) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 180,
                  ),
                  child: Center(
                    child: _buildNoChannelsConnected(context),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Channel Selector & Profile Header Card ──────────
                  _buildHeaderControls(context, controller),
                  20.height,

                  if (controller.isLoading.value && !controller.isRefreshing.value) ...[
                    _buildLoadingPlaceholder(),
                  ] else ...[
                    // ── 1. Channel Health Audit (Score & 4 Pillars Breakdown) ────
                    _buildHealthScoreSection(context, controller),
                    20.height,

                        // ── 2. Key Performance Metrics Grid ────────────────────
                        _buildSectionHeader("KEY PERFORMANCE METRICS"),
                        8.height,
                        _buildKeyMetricsGrid(controller),
                        20.height,

                        // ── 3. Audience Growth Graph ────────────────────────────
                        _buildSectionHeader("AUDIENCE GROWTH"),
                        8.height,
                        _buildAudienceGrowthCard(controller),
                        20.height,

                        // ── 4. Views Graph ─────────────────────────────────────
                        _buildSectionHeader("VIEWS OVER TIME"),
                        8.height,
                        _buildViewsGraphCard(controller),
                        20.height,

                        // ── 5. Engagement Graph ────────────────────────────────
                        _buildSectionHeader("ENGAGEMENT & INTERACTIONS"),
                        8.height,
                        _buildEngagementGraphCard(controller),
                        20.height,

                        // ── 6. Content Activity ────────────────────────────────
                        _buildSectionHeader("CONTENT ACTIVITY & CONSISTENCY"),
                        8.height,
                        _buildContentActivityCard(controller),
                        20.height,

                        // ── 7. Top Performing Content ──────────────────────────
                        _buildSectionHeader("TOP PERFORMING CONTENT"),
                        8.height,
                        _buildTopPerformingList(controller),
                        32.height,
                      ],
                    ],
                  );
                }),
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

  // ── Header Controls: Channel Selector & Account Card ───────────────────────
  Widget _buildHeaderControls(BuildContext context, AnalyticsController controller) {
    final channels = controller.availableChannels;
    final current = controller.selectedChannel.value;
    final isIg = controller.selectedPlatform.value == "Instagram";
    final channelName = current?.name ?? controller.accountDetails["name"] as String;
    final rawHandle = current?.handle ?? controller.accountDetails["handle"] as String;
    final handle = rawHandle.startsWith('@') ? rawHandle : "@$rawHandle";

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
          // Channel Selector Row (Clickable to open bottom sheet)
          GestureDetector(
            onTap: () => _showChannelSelectorBottomSheet(context, controller),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                // Platform Brand Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isIg
                        ? const Color(0xFFE1306C).withValues(alpha: 0.1)
                        : const Color(0xFFFF0000).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isIg
                          ? const Color(0xFFE1306C).withValues(alpha: 0.25)
                          : const Color(0xFFFF0000).withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: isIg
                        ? CW.instagramIcon(size: 24)
                        : CW.youtubeIcon(size: 24),
                  ),
                ),
                12.width,

                // Account Name, Platform & Switch Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              channelName,
                              style: TS.sectionTitle(color: CC.textPrimary, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          6.width,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (current?.statusColor ?? const Color(0xFF22C55E)).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: (current?.statusColor ?? const Color(0xFF22C55E)).withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: current?.statusColor ?? const Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                4.width,
                                Text(
                                  current?.statusDisplay ?? "Connected",
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: current?.statusColor ?? const Color(0xFF22C55E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (channels.length > 1) ...[
                            6.width,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: CC.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "${channels.length} Channels",
                                style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 9.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                      3.height,
                      Text(
                        "${current?.platform ?? (isIg ? 'INSTAGRAM' : 'YOUTUBE')} • $handle",
                        style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Dropdown Switcher Chevron
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CC.searchBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.keyboard_arrow_down_rounded, color: CC.textPrimary, size: 20),
                ),
              ],
            ),
          ),
          14.height,

          // Date Range Segmented Selector (7 Days, 30 Days, 90 Days)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: CC.searchBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: controller.dateRangeOptions.map((range) {
                final isSelected = controller.selectedDateRange.value == range;
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
  }

  void _showChannelSelectorBottomSheet(BuildContext context, AnalyticsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CC.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: CC.stroke,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    16.height,
                    Text(
                      "Select Active Channel",
                      style: TS.sectionTitle(color: CC.textPrimary, fontSize: 18),
                    ),
                    4.height,
                    Text(
                      "Choose a channel to inspect its performance metrics and growth curves.",
                      style: TS.caption(color: CC.textSecondary),
                    ),
                    16.height,
                    ...controller.availableChannels.map((chan) {
                      final isSelected = chan.id.toString() == controller.selectedChannel.value?.id.toString();
                      final isYt = chan.platform == 'YOUTUBE';
                      final displayHandle = chan.handle.startsWith('@') ? chan.handle : "@${chan.handle}";
                      final statusColor = chan.statusColor;
                      final statusText = chan.statusDisplay;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? CC.primary.withValues(alpha: 0.08) : CC.searchBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? CC.primary : CC.stroke.withValues(alpha: 0.4),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isYt
                                  ? const Color(0xFFFF0000).withValues(alpha: 0.08)
                                  : const Color(0xFFE1306C).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isYt
                                    ? const Color(0xFFFF0000).withValues(alpha: 0.2)
                                    : const Color(0xFFE1306C).withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: isYt ? CW.youtubeIcon(size: 22) : CW.instagramIcon(size: 22),
                            ),
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  chan.name.isNotEmpty ? chan.name : displayHandle,
                                  style: TS.bodySmall(
                                    color: CC.textPrimary,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              8.width,
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    4.width,
                                    Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              displayHandle,
                              style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11),
                            ),
                          ),
                          trailing: isSelected
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: CC.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                                )
                              : Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: CC.stroke.withValues(alpha: CC.isDark ? 0.4 : 0.7),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                          onTap: () {
                            controller.selectChannel(chan);
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                    }),
                    12.height,
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: CC.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(Icons.add_rounded, color: CC.primary, size: 18),
                        label: Text(
                          "Connect Another Channel",
                          style: TS.bodySmall(color: CC.primary, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Get.to(() => const ConnectAccountsView());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoChannelsConnected(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CC.stroke.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.hub_rounded, size: 40, color: CC.primary),
          ),
          16.height,
          Text(
            "No Channels Connected",
            style: TS.sectionTitle(color: CC.textPrimary, fontSize: 18),
          ),
          8.height,
          Text(
            "Connect your YouTube or Instagram account to inspect real-time growth curves, engagement stats, and video performance.",
            style: TS.bodySmall(color: CC.textSecondary),
            textAlign: TextAlign.center,
          ),
          20.height,
          CW.commonBtn(
            title: "Connect Channels",
            onTap: () => Get.to(() => const ConnectAccountsView()),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return CW.skeletonList(itemCount: 4, itemHeight: 90, padding: EdgeInsets.zero);
  }


  // ── 1. Channel Health Audit (Score & 4 Pillars Breakdown) ──────────────────
  Widget _buildHealthScoreSection(BuildContext context, AnalyticsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader("CHANNEL HEALTH AUDIT"),
            Obx(() => GestureDetector(
              onTap: controller.isAuditing.value ? null : () => controller.runChannelAudit(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CC.primary.withValues(alpha: 0.25), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.isAuditing.value) ...[
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: CC.primary),
                      ),
                      6.width,
                      Text("Auditing...", style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 11)),
                    ] else ...[
                      Icon(Icons.refresh_rounded, size: 14, color: CC.primary),
                      4.width,
                      Text("Run Audit", style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 11)),
                    ],
                  ],
                ),
              ),
            )),
          ],
        ),
        8.height,
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: CC.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
              width: 1,
            ),
          ),
          child: Obx(() {
            if (controller.isLoading.value || controller.isAuditing.value) {
              return SkeletonShimmer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SkeletonCircle(size: 72),
                        18.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SkeletonBox(width: 160, height: 16),
                              8.height,
                              const SkeletonBox(width: double.infinity, height: 11),
                              6.height,
                              const SkeletonBox(width: 140, height: 11),
                            ],
                          ),
                        ),
                      ],
                    ),
                    16.height,
                    Row(
                      children: [
                        Expanded(child: const SkeletonBox(height: 38, borderRadius: BorderRadius.all(Radius.circular(8)))),
                        6.width,
                        Expanded(child: const SkeletonBox(height: 38, borderRadius: BorderRadius.all(Radius.circular(8)))),
                        6.width,
                        Expanded(child: const SkeletonBox(height: 38, borderRadius: BorderRadius.all(Radius.circular(8)))),
                        6.width,
                        Expanded(child: const SkeletonBox(height: 38, borderRadius: BorderRadius.all(Radius.circular(8)))),
                      ],
                    ),
                  ],
                ),
              );
            }

            final hasAudit = controller.hasAuditData.value;
            final score = controller.healthScore.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // RepaintBoundary isolates circular meter repaints
                    RepaintBoundary(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: CircularProgressIndicator(
                              value: hasAudit && score > 0 ? (score / 100) : 0.0,
                              strokeWidth: 7,
                              backgroundColor: CC.primary.withValues(alpha: 0.12),
                              color: score >= 80
                                  ? CC.success
                                  : (score >= 60 ? CC.primary : CC.error),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                hasAudit ? "$score" : "--",
                                style: TS.sectionTitle(color: CC.textPrimary, fontSize: 20),
                              ),
                              Text(
                                "/100",
                                style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    18.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasAudit
                                ? (score >= 80
                                    ? "Channel Health: Excellent ($score%)"
                                    : (score >= 50 ? "Channel Health: Good ($score%)" : "Channel Health: Needs Work ($score%)"))
                                : "Channel Health: Pending Audit",
                            style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w700),
                          ),
                          4.height,
                          Text(
                            hasAudit
                                ? (controller.lastSyncedText.value.isNotEmpty
                                    ? "Audit score calculated from retention, SEO metadata, and upload pacing. ${controller.lastSyncedText.value}."
                                    : "Audit score calculated from your live channel metrics.")
                                : "No audit data yet. Tap 'Run Audit' above to calculate your score.",
                            style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                16.height,
                // 4-pillar audit sub-scores breakdown
                Row(
                  children: [
                    _buildScorePill(
                        "Engagement",
                        hasAudit ? "${controller.engagementScore.value}%" : "--",
                        Icons.thumb_up_alt_outlined),
                    6.width,
                    _buildScorePill(
                        "Consistency",
                        hasAudit ? "${controller.consistencyScore.value}%" : "--",
                        Icons.calendar_month_outlined),
                    6.width,
                    _buildScorePill(
                        "Growth",
                        hasAudit ? "${controller.growthScore.value}%" : "--",
                        Icons.trending_up_rounded),
                    6.width,
                    _buildScorePill(
                        "Reach",
                        hasAudit ? "${controller.reachScore.value}%" : "--",
                        Icons.remove_red_eye_outlined),
                  ],
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildScorePill(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: CC.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: CC.primary.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 13, color: CC.primary),
            4.height,
            Text(
              value,
              style: TS.caption(color: CC.textPrimary, fontWeight: FontWeight.w700).copyWith(fontSize: 11),
            ),
            2.height,
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Key Performance Metrics Grid ───────────────────────────────────────
  Widget _buildKeyMetricsGrid(AnalyticsController controller) {
    final metrics = controller.keyMetrics;

    if (metrics.isEmpty) {
      return _buildNoDataState("No key metrics recorded for this channel.");
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 10) / 2;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: metrics.map((metric) {
            final title = metric["title"] as String;
            final value = metric["value"] as String;
            final change = metric["change"] as String;
            final isUp = metric["isUp"] as bool? ?? true;
            final isNegative = change.trim().startsWith('-') || !isUp;
            final trendColor = isNegative ? CC.error : CC.success;
            final trendIcon = isNegative ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

            return SizedBox(
              width: itemWidth,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CC.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12),
                    ),
                    8.height,
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _formatCleanNumber(value),
                        style: TS.sectionTitle(color: CC.textPrimary, fontSize: 20),
                      ),
                    ),
                    if (change.trim().isNotEmpty) ...[
                      6.height,
                      Row(
                        children: [
                          Icon(
                            trendIcon,
                            color: trendColor,
                            size: 14,
                          ),
                          4.width,
                          Expanded(
                            child: Text(
                              change,
                              style: TS.caption(
                                color: trendColor,
                                fontWeight: FontWeight.w700,
                              ).copyWith(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ── 3. Audience Growth Card ───────────────────────────────────────────────
  Widget _buildAudienceGrowthCard(AnalyticsController controller) {
    final growth = controller.audienceGrowthData;
    final end = growth["end"] as String;
    final gain = growth["gain"] as String;
    final isUp = growth["isUp"] as bool? ?? true;
    final isGainNegative = gain.trim().startsWith('-') || !isUp;
    final gainColor = isGainNegative ? CC.error : CC.success;
    final gainIcon = isGainNegative ? Icons.trending_down_rounded : Icons.trending_up_rounded;
    final labels = (growth["timeLabels"] as List).cast<String>();
    final points = (growth["points"] as List).cast<double>();

    if (points.isEmpty) {
      return _buildNoDataState("No audience growth data recorded yet.");
    }

    return _styledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Audience", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12)),
                    4.height,
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(_formatCleanNumber(end), style: TS.sectionTitle(color: CC.textPrimary, fontSize: 22)),
                    ),
                  ],
                ),
              ),
              if (gain.trim().isNotEmpty) ...[
                10.width,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: gainColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(gainIcon, color: gainColor, size: 16),
                      4.width,
                      Text(gain, style: TS.caption(color: gainColor, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          16.height,
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _SmoothLineChartPainter(
                dataPoints: points,
                lineColor: CC.primary,
              ),
            ),
          ),
          8.height,
          _buildTimeLabelsRow(labels),
        ],
      ),
    );
  }

  // ── 4. Views Graph Card ───────────────────────────────────────────────────
  Widget _buildViewsGraphCard(AnalyticsController controller) {
    final v = controller.viewsData;
    final rawTotalViews = v["totalViews"] as String;
    final totalViews = _formatCleanNumber(rawTotalViews);
    final change = v["change"] as String;
    final isUp = v["isUp"] as bool? ?? true;
    final isChangeNegative = change.trim().startsWith('-') || !isUp;
    final changeColor = isChangeNegative ? CC.error : CC.success;
    final changeIcon = isChangeNegative ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final insight = v["insight"] as String;
    final labels = (v["timeLabels"] as List).cast<String>();
    final points = (v["points"] as List).cast<double>();

    if (points.isEmpty) {
      return _buildNoDataState("No view data recorded yet.");
    }

    return _styledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Views", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12)),
                    4.height,
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(totalViews, style: TS.sectionTitle(color: CC.textPrimary, fontSize: 22)),
                    ),
                  ],
                ),
              ),
              if (change.trim().isNotEmpty) ...[
                10.width,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(changeIcon, color: changeColor, size: 14),
                      4.width,
                      Text(change, style: TS.caption(color: changeColor, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (insight.trim().isNotEmpty) ...[
            8.height,
            Text(insight, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
          ],
          16.height,
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _SmoothLineChartPainter(
                dataPoints: points,
                lineColor: Colors.teal,
              ),
            ),
          ),
          8.height,
          _buildTimeLabelsRow(labels),
        ],
      ),
    );
  }

  // ── 5. Engagement Graph Card ──────────────────────────────────────────────
  Widget _buildEngagementGraphCard(AnalyticsController controller) {
    final eng = controller.engagementData;
    final avgRate = eng["avgRate"] as String;
    final likesCount = eng["likesCount"] as String;
    final commentsCount = eng["commentsCount"] as String;
    final likesPts = (eng["likesPoints"] as List).cast<double>();
    final commentsPts = (eng["commentsPoints"] as List).cast<double>();
    final labels = (eng["timeLabels"] as List).cast<String>();

    if (likesPts.isEmpty && commentsPts.isEmpty) {
      return _buildNoDataState("No engagement interactions recorded yet.");
    }

    return _styledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Average Engagement Rate", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12)),
                  4.height,
                  Text(avgRate, style: TS.sectionTitle(color: CC.textPrimary, fontSize: 22)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _legendDot(CC.primary, "Likes (${_formatCleanNumber(likesCount)})"),
                  10.width,
                  _legendDot(Colors.purpleAccent, "Comments (${_formatCleanNumber(commentsCount)})"),
                ],
              ),
            ],
          ),
          8.height,
          Text(
            "Likes and comments interaction trends over the selected period.",
            style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11),
          ),
          16.height,
          SizedBox(
            height: 140,
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
          8.height,
          _buildTimeLabelsRow(labels),
        ],
      ),
    );
  }

  // ── 6. Content Activity Card ──────────────────────────────────────────────
  Widget _buildContentActivityCard(AnalyticsController controller) {
    final activity = controller.contentActivityData;
    final total = activity["total"] as String;
    final avg = activity["avg"] as String;
    final best = activity["best"] as String;
    final weeklyBars = (activity["weeklyBars"] as List).cast<Map<String, dynamic>>();

    if (weeklyBars.isEmpty) {
      return _buildNoDataState("No content activity recorded yet.");
    }

    return _styledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(total, style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16)),
          4.height,
          Text("$avg • $best", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
          16.height,
          LayoutBuilder(
            builder: (context, constraints) {
              const double barWidth = 36.0;
              final double totalWidthNeeded = weeklyBars.length * (barWidth + 14);
              final bool shouldScroll = totalWidthNeeded > constraints.maxWidth;

              final barsWidget = Row(
                mainAxisAlignment: shouldScroll ? MainAxisAlignment.start : MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weeklyBars.map((bar) {
                  final week = bar["week"] as String;
                  final count = (bar["count"] as num).toInt();
                  final height = (count * 15.0).clamp(20.0, 100.0);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        Text(
                          "$count",
                          style: TS.caption(
                            color: count > 0 ? CC.primary : CC.textSecondary,
                            fontWeight: FontWeight.w700,
                          ).copyWith(fontSize: 11),
                        ),
                        6.height,
                        Container(
                          width: barWidth,
                          height: height,
                          decoration: BoxDecoration(
                            color: count > 0
                                ? CC.primary
                                : (CC.isDark
                                    ? CC.primary.withValues(alpha: 0.25)
                                    : const Color(0xFFD8EAFF)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        8.height,
                        Text(week, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 10)),
                      ],
                    ),
                  );
                }).toList(),
              );

              return shouldScroll
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: barsWidget,
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: barsWidget,
                    );
            },
          ),
        ],
      ),
    );
  }

  // ── 7. Top Performing Content List ────────────────────────────────────────
  Widget _buildTopPerformingList(AnalyticsController controller) {
    final items = controller.topPerformingContent;

    if (items.isEmpty) {
      return _buildNoDataState("No top content recorded yet.");
    }

    return Column(
      children: items.map((item) {
        final rank = item["rank"] as String;
        final title = item["title"] as String;
        final rawViews = item["views"];
        final rawLikes = item["likes"];
        final rawComments = item["comments"];
        final engagement = item["engagement"] as String;
        final thumbnail = (item["thumbnail"] as String?) ?? '';

        final int viewsCount = int.tryParse(rawViews.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final int likesCount = int.tryParse(rawLikes.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final int commentsCount = int.tryParse(rawComments.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

        final viewsStr = "${_formatCleanNumber(viewsCount.toString())} ${viewsCount == 1 ? 'view' : 'views'}";
        final likesStr = "${_formatCleanNumber(likesCount.toString())} ${likesCount == 1 ? 'like' : 'likes'}";
        final commentsStr = "${_formatCleanNumber(commentsCount.toString())} ${commentsCount == 1 ? 'comment' : 'comments'}";

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CC.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              thumbnail.isNotEmpty && thumbnail.startsWith("http")
                  ? CW.networkImage(
                      url: thumbnail,
                      width: 50,
                      height: 38,
                      borderRadius: BorderRadius.circular(8),
                      errorWidget: _buildRankBadge(rank),
                    )
                  : _buildRankBadge(rank),

              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.height,
                    Text(
                      "$viewsStr • $likesStr • $commentsStr",
                      style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 10.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              10.width,
              Builder(
                builder: (context) {
                  final isNegative = engagement.trim().startsWith('-');
                  final engColor = isNegative ? CC.error : CC.success;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: engColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      engagement,
                      style: TS.caption(color: engColor, fontWeight: FontWeight.w700).copyWith(fontSize: 10),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRankBadge(String rank) {
    return Container(
      color: CC.primary.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          rank,
          style: TS.caption(color: CC.primary, fontWeight: FontWeight.w800).copyWith(fontSize: 11),
        ),
      ),
    );
  }

  String _formatCleanNumber(String raw) {
    final clean = raw.trim();
    final d = double.tryParse(clean.replaceAll(',', ''));
    if (d != null) {
      if (d == d.toInt()) {
        final intVal = d.toInt();
        return intVal.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
      }
    }
    return clean;
  }

  String _formatDateLabel(String raw) {
    final trimmed = raw.trim();
    final dt = DateTime.tryParse(trimmed);
    if (dt != null) {
      const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return "${dt.day} ${months[dt.month - 1]}";
    }
    return trimmed;
  }

  Widget _buildTimeLabelsRow(List<String> labels) {
    if (labels.isEmpty) return const SizedBox.shrink();

    List<String> displayLabels;
    if (labels.length <= 4) {
      displayLabels = labels.map(_formatDateLabel).toList();
    } else {
      final int count = 4;
      final step = (labels.length - 1) / (count - 1);
      final sampled = <String>[];
      for (int i = 0; i < count; i++) {
        final index = (i * step).round().clamp(0, labels.length - 1);
        final label = _formatDateLabel(labels[index]);
        if (!sampled.contains(label)) {
          sampled.add(label);
        }
      }
      displayLabels = sampled.isNotEmpty
          ? sampled
          : [_formatDateLabel(labels.first), _formatDateLabel(labels.last)];
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: displayLabels
          .map((l) => Text(
                l,
                style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 10),
              ))
          .toList(),
    );
  }

  Widget _buildNoDataState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CC.stroke.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Text(
          message,
          style: TS.caption(color: CC.textSecondary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _styledCard({required Widget child}) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
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
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }


  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        4.width,
        Text(label, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 10.5)),
      ],
    );
  }
}

// ── Custom Painter: Smooth Gradient Line Chart ────────────────────────────────
class _SmoothLineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;

  _SmoothLineChartPainter({
    required this.dataPoints,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    // Draw background dashed gridlines
    _drawGridLines(canvas, size);

    final minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final isFlat = (maxVal - minVal) == 0;
    final range = isFlat ? 1.0 : (maxVal - minVal);

    const paddingX = 14.0;
    final usableWidth = size.width - (paddingX * 2);
    final dx = dataPoints.length > 1 ? usableWidth / (dataPoints.length - 1) : 0.0;
    final points = <Offset>[];

    for (int i = 0; i < dataPoints.length; i++) {
      final x = paddingX + (i * dx);
      final double y;
      if (isFlat) {
        y = size.height * 0.60;
      } else {
        final normalizedY = (dataPoints[i] - minVal) / range;
        y = size.height - (normalizedY * (size.height - 36) + 18);
      }
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

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

    if (points.length > 1) {
      final areaPath = Path.from(linePath)
        ..lineTo(points.last.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.28),
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

    final firstPt = points.first;
    canvas.drawCircle(firstPt, 5, Paint()..color = lineColor.withValues(alpha: 0.25));
    canvas.drawCircle(firstPt, 3.5, Paint()..color = lineColor);

    final lastPt = points.last;
    canvas.drawCircle(lastPt, 7, Paint()..color = lineColor.withValues(alpha: 0.35));
    canvas.drawCircle(lastPt, 4.5, Paint()..color = lineColor);
    canvas.drawCircle(lastPt, 2, Paint()..color = CC.whiteText);
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = (CC.isDark ? CC.stroke.withValues(alpha: 0.15) : CC.stroke.withValues(alpha: 0.45))
      ..strokeWidth = 1.0;

    const count = 3;
    for (int i = 1; i <= count; i++) {
      final y = size.height * (i / (count + 1));
      _drawDashedLine(canvas, Offset(8, y), Offset(size.width - 8, y), gridPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(
        Offset(startX, p1.dy),
        Offset((startX + dashWidth).clamp(p1.dx, p2.dx), p1.dy),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
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
    _drawGridLines(canvas, size);
    _drawLine(canvas, size, line1Points, color1, offsetFraction: 0.58);
    _drawLine(canvas, size, line2Points, color2, offsetFraction: 0.65);
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = (CC.isDark ? CC.stroke.withValues(alpha: 0.15) : CC.stroke.withValues(alpha: 0.45))
      ..strokeWidth = 1.0;

    const count = 3;
    for (int i = 1; i <= count; i++) {
      final y = size.height * (i / (count + 1));
      _drawDashedLine(canvas, Offset(8, y), Offset(size.width - 8, y), gridPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(
        Offset(startX, p1.dy),
        Offset((startX + dashWidth).clamp(p1.dx, p2.dx), p1.dy),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  void _drawLine(Canvas canvas, Size size, List<double> dataPoints, Color color, {double offsetFraction = 0.60}) {
    if (dataPoints.isEmpty) return;

    final minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final isFlat = (maxVal - minVal) == 0;
    final range = isFlat ? 1.0 : (maxVal - minVal);

    const paddingX = 12.0;
    final usableWidth = size.width - (paddingX * 2);
    final dx = dataPoints.length > 1 ? usableWidth / (dataPoints.length - 1) : 0.0;
    final points = <Offset>[];

    for (int i = 0; i < dataPoints.length; i++) {
      final x = paddingX + (i * dx);
      final double y;
      if (isFlat) {
        y = size.height * offsetFraction;
      } else {
        final normalizedY = (dataPoints[i] - minVal) / range;
        y = size.height - (normalizedY * (size.height - 36) + 18);
      }
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

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

    if (points.length <= 10) {
      for (final pt in points) {
        canvas.drawCircle(pt, 3.5, Paint()..color = color);
        canvas.drawCircle(pt, 1.8, Paint()..color = CC.whiteText);
      }
    } else {
      final firstPt = points.first;
      final lastPt = points.last;
      canvas.drawCircle(firstPt, 4.0, Paint()..color = color);
      canvas.drawCircle(firstPt, 2.0, Paint()..color = CC.whiteText);
      canvas.drawCircle(lastPt, 5.0, Paint()..color = color);
      canvas.drawCircle(lastPt, 2.5, Paint()..color = CC.whiteText);
    }
  }

  @override
  bool shouldRepaint(covariant _DualLineChartPainter oldDelegate) => true;
}
