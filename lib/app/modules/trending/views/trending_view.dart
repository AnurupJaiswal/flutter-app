import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/profile/views/profile_view.dart';
import 'package:lala_ai/app/data/models/trend_model.dart';
import 'package:lala_ai/app/modules/main_container/controllers/main_container_controller.dart';
import 'package:lala_ai/app/modules/trending/controllers/trending_controller.dart';
import 'package:lala_ai/app/navigation/app_navigation_service.dart';
import 'package:lala_ai/core/widgets/skeleton/app_skeleton.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class TrendingView extends GetView<TrendingController> {
  const TrendingView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeService>(
      builder: (_) {
        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            isNotHomepage: false,
            wantBackIcon: false,
            title: "Discover Trends",
            actions: [
              IconButton(
                icon: Icon(Icons.person_outline_rounded, color: CC.textPrimary, size: 22),
                splashRadius: 20,
                onPressed: () => Get.to(() => const ProfileView()),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              displacement: 36,
              strokeWidth: 2.5,
              onRefresh: () => controller.loadTrends(isRefresh: true),
              color: CC.primary,
              backgroundColor: CC.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    Obx(
                      () => CW.commonSearchField(
                        controller: controller.searchController,
                        hintText: "Search viral topics, hashtags, creators...",
                        onChanged: controller.onSearchChanged,
                        suffixIcon: controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close_rounded, size: 18, color: CC.grey),
                                splashRadius: 16,
                                onPressed: controller.clearSearch,
                              )
                            : null,
                      ),
                    ),
                    12.height,

                    // Category Filter Pills
                    Obx(() {
                      final categories = controller.availableCategories;
                      if (categories.length <= 1) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: categories.map((cat) {
                              final isSelected = controller.selectedCategory.value.toLowerCase() == cat.toLowerCase();
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    controller.setCategory(cat);
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? CC.primary : CC.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? CC.primary
                                            : CC.stroke.withValues(alpha: CC.isDark ? 0.4 : 0.6),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      cat.capitalizeFirst ?? cat,
                                      style: TS.caption(
                                        color: isSelected ? CC.whiteText : CC.textPrimary,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ).copyWith(fontSize: 13),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }),

                    // Active Trends Feed Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                              "Active Trends Feed (${controller.filteredTrends.length})",
                              style: TS.caption(color: CC.textSecondary).copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                            )),
                        TextButton.icon(
                          onPressed: () => controller.loadTrends(isRefresh: true),
                          icon: Icon(Icons.refresh_rounded, size: 14, color: CC.primary),
                          label: Text(
                            "Refresh",
                            style: TS.caption(color: CC.primary, fontWeight: FontWeight.w600),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    10.height,

                    // Trends List
                    Obx(() {
                      if (controller.isLoading.value && controller.trends.isEmpty) {
                        return const TrendSkeleton(itemCount: 4);
                      }

                      final list = controller.filteredTrends;
                      if (list.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded, size: 48, color: CC.grey),
                                12.height,
                                Text(
                                  "No trends found",
                                  style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16),
                                ),
                                4.height,
                                Text(
                                  "Try searching for another keyword or category",
                                  style: TS.bodySmall(color: CC.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          for (int i = 0; i < list.length; i++) ...[
                            _trendCard(
                              key: ValueKey('trend_${list[i].id}'),
                              context: context,
                              rank: i + 1,
                              trend: list[i],
                            ),
                            if (i < list.length - 1) 14.height,
                          ],
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _trendCard({Key? key, required BuildContext context, required int rank, required TrendModel trend}) {
    final bool isTop3 = rank <= 3;
    final stage = trend.lifecycleStage.toUpperCase();

    Color stageColor;
    IconData stageIcon;
    String stageText;
    if (stage == 'EMERGING') {
      stageColor = const Color(0xFF10B981); // Emerald Green
      stageIcon = Icons.eco_rounded;
      stageText = "EMERGING";
    } else if (stage == 'PEAKING') {
      stageColor = const Color(0xFFF59E0B); // Amber / Flame
      stageIcon = Icons.local_fire_department_rounded;
      stageText = "PEAKING";
    } else {
      // Default: RISING
      stageColor = const Color(0xFF2563EB); // Royal Blue
      stageIcon = Icons.trending_up_rounded;
      stageText = "RISING";
    }

    final platformName = trend.platform.toUpperCase();
    IconData platformIcon;
    Color platformColor;
    String displayPlatform;
    if (platformName.contains('YOUTUBE')) {
      platformIcon = Icons.play_circle_fill_rounded;
      platformColor = const Color(0xFFFF0000);
      displayPlatform = "YouTube";
    } else if (platformName.contains('REDDIT')) {
      platformIcon = Icons.forum_rounded;
      platformColor = const Color(0xFFFF4500);
      displayPlatform = "Reddit";
    } else if (platformName.contains('INSTAGRAM')) {
      platformIcon = Icons.camera_alt_rounded;
      platformColor = const Color(0xFFE1306C);
      displayPlatform = "Instagram";
    } else {
      platformIcon = Icons.public_rounded;
      platformColor = CC.primary;
      displayPlatform = trend.platform.isNotEmpty 
          ? (trend.platform[0].toUpperCase() + trend.platform.substring(1).toLowerCase())
          : "General";
    }

    final categoryDisplay = trend.category.isNotEmpty
        ? (trend.category[0].toUpperCase() + trend.category.substring(1).toLowerCase())
        : "";

    return Container(
      key: key,
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.55),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CC.isDark
                ? CC.black.withValues(alpha: 0.35)
                : CC.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Header Row: Badges (Rank + Platform + Category) + Lifecycle Stage ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                // Rank Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: isTop3
                        ? CC.primary.withValues(alpha: 0.12)
                        : CC.stroke.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (rank == 1) ...[
                        Icon(Icons.workspace_premium_rounded, size: 12, color: CC.primary),
                        3.width,
                      ],
                      Text(
                        "#$rank",
                        style: TS.caption(
                          color: isTop3 ? CC.primary : CC.textSecondary,
                          fontWeight: FontWeight.w800,
                        ).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                6.width,

                // Platform Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: platformColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(platformIcon, size: 12, color: platformColor),
                      4.width,
                      Text(
                        displayPlatform,
                        style: TS.caption(
                          color: CC.textPrimary,
                          fontWeight: FontWeight.w600,
                        ).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),

                if (categoryDisplay.isNotEmpty) ...[
                  6.width,
                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: CC.isDark
                          ? CC.whiteText.withValues(alpha: 0.06)
                          : CC.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      categoryDisplay,
                      style: TS.caption(
                        color: CC.textSecondary,
                        fontWeight: FontWeight.w600,
                      ).copyWith(fontSize: 11),
                    ),
                  ),
                ],

                const Spacer(),

                // Lifecycle Stage Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: stageColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: stageColor.withValues(alpha: 0.25), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(stageIcon, size: 11, color: stageColor),
                      3.width,
                      Text(
                        stageText,
                        style: TS.caption(
                          color: stageColor,
                          fontWeight: FontWeight.w800,
                        ).copyWith(fontSize: 10, letterSpacing: 0.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          14.height,

          // ── Topic Title & AI Summary ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trend.name,
                  style: TS.sectionTitle(
                    color: CC.textPrimary,
                    fontSize: 17,
                  ).copyWith(
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                if (trend.summary.isNotEmpty) ...[
                  8.height,
                  Text(
                    trend.summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TS.bodySmall(
                      color: CC.textSecondary,
                    ).copyWith(fontSize: 13, height: 1.45),
                  ),
                ],
              ],
            ),
          ),
          14.height,

          // ── 3-Column Intelligence Metrics Micro-Cards ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _metricBox(
                  icon: Icons.bolt_rounded,
                  iconColor: CC.primary,
                  label: "Trend Score",
                  value: trend.score.toStringAsFixed(1),
                  valueColor: CC.primary,
                ),
                8.width,
                _metricBox(
                  icon: Icons.trending_up_rounded,
                  iconColor: const Color(0xFF10B981),
                  label: "Growth",
                  value: "${trend.growthScore > 0 ? '+' : ''}${trend.growthScore.toStringAsFixed(1)}%",
                  valueColor: trend.growthScore >= 0 ? const Color(0xFF10B981) : Colors.red,
                ),
                8.width,
                _metricBox(
                  icon: Icons.speed_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  label: "Velocity",
                  value: trend.velocityScore.toStringAsFixed(1),
                  valueColor: CC.textPrimary,
                ),
              ],
            ),
          ),
          14.height,

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: CC.stroke.withValues(alpha: CC.isDark ? 0.3 : 0.4),
          ),

          // ── Action Buttons Footer ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.find<MainContainerController>()
                          .changeTab(AppNavigationService.tabStudio),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CC.primary,
                        foregroundColor: CC.whiteText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      icon: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                      ),
                      label: Text(
                        "Use in Studio",
                        style: TS.bodySmall(
                          color: CC.whiteText,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: 13),
                      ),
                    ),
                  ),
                ),
                8.width,
                _actionSquareBtn(
                  icon: Icons.copy_rounded,
                  tooltip: "Copy Details",
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(
                        text: "${trend.name}\nPlatform: ${trend.platform} | Stage: ${trend.lifecycleStage} | Score: ${trend.score}\nGrowth: ${trend.growthScore}% | Velocity: ${trend.velocityScore}\n${trend.summary}"));
                    AppToast.success("Trend details copied!");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricBox({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: CC.isDark
              ? CC.whiteText.withValues(alpha: 0.035)
              : CC.black.withValues(alpha: 0.025),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: CC.stroke.withValues(alpha: CC.isDark ? 0.25 : 0.4),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: iconColor),
                4.width,
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TS.caption(color: CC.textSecondary).copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
            4.height,
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TS.bodySmall(
                  color: valueColor,
                  fontWeight: FontWeight.w800,
                ).copyWith(fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionSquareBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: CC.isDark
                ? CC.whiteText.withValues(alpha: 0.05)
                : CC.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: CC.stroke.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: CC.textPrimary,
          ),
        ),
      ),
    );
  }
}
