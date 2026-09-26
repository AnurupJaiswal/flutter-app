import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/analytics/views/analytics_view.dart';
import 'package:lala_ai/app/modules/home/controllers/home_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';
import 'package:lala_ai/app/modules/connect_accounts/views/connect_accounts_view.dart';
import 'package:lala_ai/app/modules/connect_accounts/widgets/connect_account_hero_widget.dart';
import 'package:lala_ai/app/modules/profile/views/profile_view.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/core/widgets/skeleton/app_skeleton.dart';
import 'package:lala_ai/networking/api_service.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (_) => Scaffold(
        backgroundColor: CC.background,
        appBar: CW.commonAppbar(
          isNotHomepage: false,
          wantBackIcon: false,
          titleWidget: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(Icons.auto_awesome_rounded, color: CC.primary, size: 20),
                ),
              ),
              10.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Lala Ai", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(
                    "Create. Grow. Smarter.",
                    style: TS.caption(color: CC.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.notifications_none_rounded, color: CC.textPrimary, size: 22),
                  splashRadius: 20,
                  onPressed: () {},
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B30),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.person_outline_rounded, color: CC.textPrimary, size: 22),
              splashRadius: 20,
              onPressed: () => Get.to(() => const ProfileView()),
            ),
          ],
        ),
        body: SafeArea(
          child: Obx(() {
            // 1. Initial Load: show full-screen shimmer skeleton while fetching first API call
            if (controller.isDashboardLoading.value && !controller.isRefreshing.value) {
              return _buildInitialShimmerLoading();
            }

            final hasChannels = controller.hasAnyChannels;

            // 2. If no channels are connected after initial load, show connected prompt page
            if (!hasChannels) {
              return RefreshIndicator(
                onRefresh: controller.refreshDashboard,
                color: CC.primary,
                backgroundColor: CC.surface,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInitialEmptyState(),
                            32.height,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            // 3. Connected Dashboard: Keep existing data visible during pull-to-refresh & re-audit
            return RefreshIndicator(
              onRefresh: controller.refreshDashboard,
              color: CC.primary,
              backgroundColor: CC.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(context),
                    24.height,
                    _buildHealthScoreSection(),
                    24.height,
                    _buildSwotAuditSection(),
                    24.height,
                    _buildActionableToDosSection(context),
                    100.height, // padding so floating bubble doesn't overlap
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Obx(() {
      final name = controller.creatorName.value.isNotEmpty
          ? controller.creatorName.value
          : ApiService.effectiveDisplayName;

      final current = controller.selectedChannel.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hey, $name",
              style: TS.displayLarge(fontSize: 22, fontWeight: FontWeight.w700)),
          8.height,
          if (controller.availableChannels.isNotEmpty)
            _buildChannelDropdownSelector(context, current)
          else
            Text("No channels connected",
                style: TS.bodySmall(color: CC.textSecondary).copyWith(fontSize: 11)),
        ],
      );
    });
  }

  Widget _buildChannelDropdownSelector(BuildContext context, ChannelOption? current) {
    final platform = current?.platform ?? 'YOUTUBE';
    final handle = current?.handle ?? (platform == 'YOUTUBE' ? 'YouTube Channel' : 'Instagram Profile');
    final formattedHandle = handle.startsWith('@') ? handle : "@$handle";
    final isYt = platform == 'YOUTUBE';
    final statusColor = current?.statusColor ?? const Color(0xFF22C55E);

    return GestureDetector(
      onTap: () => _showChannelSelectorBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: CC.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6), width: 1),
          boxShadow: [
            BoxShadow(
              color: CC.isDark ? CC.black.withValues(alpha: 0.25) : CC.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isYt ? CW.youtubeIcon(size: 16) : CW.instagramIcon(size: 16),
            8.width,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                formattedHandle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TS.caption(color: CC.textPrimary, fontWeight: FontWeight.w700).copyWith(fontSize: 12),
              ),
            ),
            6.width,
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            4.width,
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: CC.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showChannelSelectorBottomSheet(BuildContext context) {
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
                      "Choose a channel to inspect its audit score, SWOT analysis, and recommendations.",
                      style: TS.caption(color: CC.textSecondary),
                    ),
                    16.height,
                    ...controller.availableChannels.map((ch) {
                      final isSelected = controller.selectedChannel.value?.id.toString() == ch.id.toString();
                      final isYt = ch.platform == 'YOUTUBE';
                      final displayHandle = ch.handle.startsWith('@') ? ch.handle : "@${ch.handle}";
                      final statusColor = ch.statusColor;
                      final statusText = ch.statusDisplay;

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
                                  ch.name.isNotEmpty ? ch.name : displayHandle,
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
                            Navigator.pop(ctx);
                            controller.selectChannel(ch);
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
                          "Manage / Connect Channels",
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

  // ─── Health Score & Statistics Section ─────────────────────────────────────
  Widget _buildHealthScoreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsView())),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Channel Health Audit", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16)),
                    4.width,
                    Icon(Icons.chevron_right_rounded, size: 18, color: CC.textSecondary),
                  ],
                ),
              ),
            ),
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
        12.height,
        Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsView())),
              behavior: HitTestBehavior.opaque,
              child: Container(
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
                if (controller.isAuditing.value && !controller.hasAuditData.value) {
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
                    16.height,
                    Divider(height: 1, color: CC.stroke),
                    14.height,
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsView())),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: CC.stroke),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Detailed Analytics",
                                  style: TS.caption(color: CC.textPrimary, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ),
                        10.width,
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Get.toNamed(Routes.CHAT_HOME),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: CC.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome_rounded, size: 14, color: CC.primary),
                                  6.width,
                                  Text(
                                    "Ask Pixo",
                                    style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          );
        }),
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

  // ─── Channel Audit & SWOT Explanation Section ─────────────────────────────
  Widget _buildSwotAuditSection() {
    final categories = [
      {"key": "Strengths", "label": "Strengths"},
      {"key": "Weaknesses", "label": "Weakness"},
      {"key": "Opportunities", "label": "Oppty"},
      {"key": "Threats", "label": "Threats"},
    ];

    IconData getSwotIcon(String iconName) {
      switch (iconName) {
        case "thumb_up":
          return Icons.thumb_up_alt_outlined;
        case "check_circle":
          return Icons.check_circle_outline_rounded;
        case "warning":
          return Icons.warning_amber_rounded;
        case "find_in_page":
          return Icons.find_in_page_outlined;
        case "trending_up":
          return Icons.trending_up_rounded;
        case "schedule":
          return Icons.schedule_rounded;
        case "shield":
          return Icons.shield_outlined;
        case "timelapse":
        default:
          return Icons.timelapse_rounded;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("SWOT Audit & Action Items", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16)),
            Icon(Icons.analytics_outlined, color: CC.textPrimary, size: 20),
          ],
        ),
        12.height,
        // Equal width tab pills across row
        Obx(() => Row(
          children: categories.map((cat) {
            final key = cat["key"]!;
            final label = cat["label"]!;
            final isSelected = controller.selectedSwotCategory.value == key;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedSwotCategory.value = key,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? CC.primary : CC.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? CC.primary : CC.stroke,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.caption(
                      color: isSelected ? CC.whiteText : CC.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ).copyWith(fontSize: 11),
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        12.height,
        // SWOT Cards List with Convert to To-Do Action
        Obx(() {
          final cat = controller.selectedSwotCategory.value;
          final items = controller.swotItems[cat] ?? [];

          if (items.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: CC.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 32, color: CC.grey),
                  8.height,
                  Text("No $cat detected yet", style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600)),
                  4.height,
                  Text("Run a channel audit above to generate insights.", textAlign: TextAlign.center, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
                ],
              ),
            );
          }

          return Column(
            children: items.map((item) {
              final title = item['title'] as String;
              final desc = item['desc'] as String;
              final actionable = item['actionable'] as String? ?? title;
              final tag = item['tag'] as String? ?? "Audit";
              final iconName = item['icon'] as String? ?? "timelapse";

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CC.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: CC.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(getSwotIcon(iconName), color: CC.textPrimary, size: 20),
                        ),
                        12.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w700)),
                              3.height,
                              Text(desc, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11, height: 1.3)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    12.height,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: CC.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: CC.primary.withValues(alpha: 0.15), width: 0.8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, size: 14, color: CC.primary),
                          8.width,
                          Expanded(
                            child: Text(
                              actionable,
                              style: TS.caption(color: CC.textPrimary, fontWeight: FontWeight.w500).copyWith(fontSize: 11),
                            ),
                          ),
                          8.width,
                          GestureDetector(
                            onTap: () => controller.convertRecommendationToToDo(
                              title: actionable,
                              subtitle: "Recommendation from $title",
                              tag: tag,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: CC.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_rounded, size: 12, color: CC.whiteText),
                                  2.width,
                                  Text(
                                    "To-Do",
                                    style: TS.caption(color: CC.whiteText, fontWeight: FontWeight.w700).copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }





  // ─── Actionable Creator To-Dos Section ────────────────────────────────────
  Widget _buildActionableToDosSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Creator To-Dos", style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16)),
            Obx(() {
              final done = controller.toDoItems.where((i) => (i['isDone'] as bool)).length;
              final total = controller.toDoItems.length;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$done/$total Completed",
                  style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 10),
                ),
              );
            }),
          ],
        ),
        6.height,
        Text("AI-generated tasks to boost your channel reach", style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
        10.height,
        // Progress bar
        Obx(() {
          final done = controller.toDoItems.where((i) => (i['isDone'] as bool)).length;
          final total = controller.toDoItems.isEmpty ? 1 : controller.toDoItems.length;
          final progress = controller.toDoItems.isEmpty ? 0.0 : (done / total);
          return Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: CC.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: constraints.maxWidth * progress,
                    height: 6,
                    decoration: BoxDecoration(
                      color: CC.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          );
        }),
        12.height,
        Obx(() {
          if (controller.toDoItems.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: CC.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.checklist_rounded, size: 32, color: CC.grey),
                  8.height,
                  Text("No active To-Dos", style: TS.bodySmall(color: CC.textPrimary, fontWeight: FontWeight.w600)),
                  4.height,
                  Text("Tap '+ To-Do' on any audit recommendation above to add tasks.", textAlign: TextAlign.center, style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11)),
                ],
              ),
            );
          }

          return Column(
            children: controller.toDoItems.map((item) {
              final id = item['id'] as int;
              final title = item['title'] as String? ?? "";
              final subtitle = item['subtitle'] as String? ?? "";
              final isDone = item['isDone'] as bool? ?? false;
              final tag = item['tag'] as String? ?? "";

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDone ? CC.surface.withValues(alpha: 0.5) : CC.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDone
                        ? CC.stroke.withValues(alpha: 0.2)
                        : CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => _showToDoDetailsBottomSheet(context, item),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Checkbox
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => controller.toggleToDoItem(id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isDone ? CC.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDone ? CC.primary : CC.grey.withValues(alpha: 0.6),
                                  width: 1.8,
                                ),
                              ),
                              child: isDone
                                  ? const Center(
                                      child: Icon(Icons.check_rounded, color: CC.whiteText, size: 15),
                                    )
                                  : null,
                            ),
                          ),
                          // Title & Subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  style: TS.bodySmall(
                                    color: isDone ? CC.textSecondary : CC.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ).copyWith(
                                    fontSize: 13,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                    decorationColor: CC.textSecondary,
                                  ),
                                ),
                                if (subtitle.isNotEmpty) ...[
                                  3.height,
                                  Text(
                                    subtitle,
                                    style: TS.caption(
                                      color: CC.textSecondary.withValues(alpha: 0.8),
                                    ).copyWith(fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          10.width,
                          // Tag
                          if (tag.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? CC.stroke.withValues(alpha: 0.2)
                                    : CC.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag,
                                style: TS.caption(
                                  color: isDone ? CC.textSecondary : CC.primary,
                                  fontWeight: FontWeight.w700,
                                ).copyWith(fontSize: 10),
                              ),
                            ),
                            6.width,
                          ],
                          // Delete Button
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => controller.removeToDoItem(id),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: CC.textSecondary.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  void _showToDoDetailsBottomSheet(BuildContext context, Map<String, dynamic> item) {
    final id = item['id'] as int;

    CW.showCustomBottomSheet(
      context: context,
      title: "Task Details",
      titleIcon: Icons.task_alt_rounded,
      children: [
        Obx(() {
          final currentItem = controller.toDoItems.firstWhereOrNull((i) => i['id'] == id) ?? item;
          final title = currentItem['title'] as String? ?? "";
          final subtitle = currentItem['subtitle'] as String? ?? "";
          final details = currentItem['details'] as String? ?? subtitle;
          final isDone = currentItem['isDone'] as bool? ?? false;
          final tag = currentItem['tag'] as String? ?? "";

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tag & Status Row
              if (tag.isNotEmpty) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: CC.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TS.caption(color: CC.primary, fontWeight: FontWeight.w700).copyWith(fontSize: 11),
                      ),
                    ),
                    8.width,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: isDone
                            ? Colors.green.withValues(alpha: 0.14)
                            : CC.stroke.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isDone ? "Completed" : "Pending",
                        style: TS.caption(
                          color: isDone ? Colors.green : CC.textSecondary,
                          fontWeight: FontWeight.w600,
                        ).copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
                12.height,
              ],

              // Title
              Text(
                title,
                style: TS.sectionTitle(
                  color: CC.textPrimary,
                  fontSize: 16,
                ).copyWith(
                  height: 1.3,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  decorationColor: CC.textSecondary,
                ),
              ),
              if (details.isNotEmpty && details != title) ...[
                10.height,
                Text(
                  details,
                  style: TS.bodySmall(color: CC.textSecondary).copyWith(
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
              24.height,

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CW.commonBtn(
                      title: isDone ? "Mark as Incomplete" : "Mark as Completed",
                      color: isDone ? CC.darkPopUpBack : CC.primary,
                      textColor: isDone ? CC.textPrimary : CC.whiteText,
                      onTap: () {
                        controller.toggleToDoItem(id);
                      },
                    ),
                  ),
                  12.width,
                  GestureDetector(
                    onTap: () {
                      CW.dismissBottomSheet();
                      controller.removeToDoItem(id);
                    },
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              8.height,
            ],
          );
        }),
      ],
    );
  }

  Widget _buildInitialShimmerLoading() {
    return const DashboardSkeleton();
  }

  Widget _buildInitialEmptyState() {
    return ConnectAccountHeroWidget(
      onConnectAccountTap: () => Get.to(() => const ConnectAccountsView()),
      onConnectPlatform: (platform) async {
        Get.to(() => const ConnectAccountsView());
      },
      onConnectInstagram: () => Get.to(() => const ConnectAccountsView()),
      onConnectYouTube: () => Get.to(() => const ConnectAccountsView()),
    );
  }
}
