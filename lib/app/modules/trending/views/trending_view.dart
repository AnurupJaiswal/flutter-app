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

  static String formatCategoryName(String raw) {
    if (raw.isEmpty) return "";
    if (raw.toLowerCase().trim() == 'all') return 'All';
    return raw
        .replaceAll('_', ' & ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) {
          if (word == '&') return '&';
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  static String formatPlatformName(String raw) {
    if (raw.isEmpty) return "General";
    if (raw.toLowerCase().trim() == 'all') return 'All Platforms';
    return raw
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  static Widget _buildPlatformIcon(String platform, {double size = 14, bool isSelected = false, Color? defaultColor}) {
    final lower = platform.toLowerCase().trim();
    if (lower.contains('youtube')) {
      return Image.asset(
        'assets/icons/img_youtube.png',
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => Icon(
          Icons.play_circle_fill_rounded,
          size: size,
          color: const Color(0xFFFF0000),
        ),
      );
    } else if (lower.contains('instagram')) {
      return Image.asset(
        'assets/icons/img_instagram.png',
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/icons/instagram_icon.png',
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => Icon(
            Icons.camera_alt_rounded,
            size: size,
            color: const Color(0xFFE1306C),
          ),
        ),
      );
    } else if (lower.contains('reddit')) {
      return Icon(
        Icons.forum_rounded,
        size: size,
        color: isSelected ? CC.whiteText : const Color(0xFFFF4500),
      );
    } else {
      return Icon(
        Icons.public_rounded,
        size: size,
        color: isSelected ? CC.whiteText : (defaultColor ?? CC.primary),
      );
    }
  }

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
              color: CC.primary,
              backgroundColor: CC.surface,
              onRefresh: () async {
                await Future.wait([
                  controller.loadTrends(isRefresh: true),
                  controller.loadMyCategories(),
                ]);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // ── 1. Search Bar & Filters ──────────────────────────────
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        10.height,
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Obx(
                            () => CW.commonSearchField(
                              controller: controller.searchController,
                              hintText: "Search viral topics, hashtags, creators...",
                              onChanged: controller.onSearchChanged,
                              suffixIcon: controller.searchQuery.value.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.cancel_rounded, size: 18, color: CC.textSecondary),
                                      splashRadius: 18,
                                      onPressed: controller.clearSearch,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        12.height,

                        // Platform Filter Tabs
                        Obx(() {
                          final platforms = controller.platforms;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: platforms.map((plat) {
                                  final isSelected = controller.selectedPlatform.value.toLowerCase() == plat.toLowerCase();

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: InkWell(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        controller.setPlatform(plat);
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 180),
                                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: isSelected ? CC.primary : CC.surface,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isSelected
                                                ? CC.primary
                                                : CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildPlatformIcon(plat, size: 14, isSelected: isSelected),
                                            6.width,
                                            Text(
                                              formatPlatformName(plat),
                                              style: TS.caption(
                                                color: isSelected ? CC.whiteText : CC.textPrimary,
                                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                              ).copyWith(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        }),

                        // Category Filter Chips
                        Obx(() {
                          final categories = controller.availableCategories;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: categories.map((cat) {
                                  final isSelected = controller.selectedCategory.value.toLowerCase() == cat.toLowerCase();

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 7),
                                    child: InkWell(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        controller.setCategory(cat);
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 180),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5.5),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? CC.primary.withValues(alpha: CC.isDark ? 0.2 : 0.12)
                                              : CC.surface,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected
                                                ? CC.primary
                                                : CC.stroke.withValues(alpha: CC.isDark ? 0.3 : 0.5),
                                            width: isSelected ? 1.2 : 1,
                                          ),
                                        ),
                                        child: Text(
                                          formatCategoryName(cat),
                                          style: TS.caption(
                                            color: isSelected ? CC.primary : CC.textSecondary,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          ).copyWith(fontSize: 11.5),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // ── 2. Content: Loading Skeleton / Centered Empty State / Cards List ──
                  Obx(() {
                    if (controller.isLoading.value && controller.trends.isEmpty) {
                      return const SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverToBoxAdapter(
                          child: TrendSkeleton(itemCount: 4),
                        ),
                      );
                    }

                    final list = controller.filteredTrends;
                    if (list.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyTrendsState(context),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == 0) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF10B981),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      6.width,
                                      Text(
                                        "TRENDING FEED",
                                        style: TS.caption(
                                          color: CC.textSecondary,
                                          fontWeight: FontWeight.w800,
                                        ).copyWith(fontSize: 11, letterSpacing: 0.6),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "${list.length} Active Topics",
                                        style: TS.caption(color: CC.textSecondary).copyWith(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  10.height,
                                  _trendCard(
                                    key: ValueKey('trend_${list[0].id}'),
                                    context: context,
                                    rank: 1,
                                    trend: list[0],
                                  ),
                                  if (list.length > 1) 14.height,
                                ],
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _trendCard(
                                key: ValueKey('trend_${list[index].id}'),
                                context: context,
                                rank: index + 1,
                                trend: list[index],
                              ),
                            );
                          },
                          childCount: list.length,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Modern Trend Card ──────────────────────────────────────────────────────
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
      stageColor = const Color(0xFFF59E0B); // Flame / Amber
      stageIcon = Icons.local_fire_department_rounded;
      stageText = "PEAKING";
    } else {
      // Default: RISING
      stageColor = const Color(0xFF2563EB); // Royal Blue
      stageIcon = Icons.trending_up_rounded;
      stageText = "RISING";
    }

    final platformName = trend.platform.toUpperCase();
    Color platformColor;
    String displayPlatform;
    if (platformName.contains('YOUTUBE')) {
      platformColor = const Color(0xFFFF0000);
      displayPlatform = "YouTube";
    } else if (platformName.contains('REDDIT')) {
      platformColor = const Color(0xFFFF4500);
      displayPlatform = "Reddit";
    } else if (platformName.contains('INSTAGRAM')) {
      platformColor = const Color(0xFFE1306C);
      displayPlatform = "Instagram";
    } else {
      platformColor = CC.primary;
      displayPlatform = formatPlatformName(trend.platform);
    }

    final rawCat = controller.getCategoryDisplayName(trend.category);
    final categoryDisplay = formatCategoryName(rawCat);

    return Container(
      key: key,
      decoration: BoxDecoration(
        color: CC.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
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
          // ── 1. Top Badges & Lifecycle Status ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Rank & Platform
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rank Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isTop3
                            ? CC.primary.withValues(alpha: 0.12)
                            : CC.stroke.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
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
                            ).copyWith(fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    6.width,
                    // Platform Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: platformColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPlatformIcon(trend.platform, size: 12),
                          4.width,
                          Text(
                            displayPlatform,
                            style: TS.caption(
                              color: CC.textPrimary,
                              fontWeight: FontWeight.w600,
                            ).copyWith(fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    if (categoryDisplay.isNotEmpty) ...[
                      6.width,
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: CC.isDark
                              ? CC.whiteText.withValues(alpha: 0.06)
                              : CC.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          categoryDisplay,
                          style: TS.caption(
                            color: CC.textSecondary,
                            fontWeight: FontWeight.w600,
                          ).copyWith(fontSize: 10.5),
                        ),
                      ),
                    ],
                  ],
                ),

                // Right: Lifecycle Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: stageColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
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
                        ).copyWith(fontSize: 9.5, letterSpacing: 0.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          12.height,

          // ── 2. Topic Title & AI Summary ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trend.name,
                  style: TS.sectionTitle(
                    color: CC.textPrimary,
                    fontSize: 16,
                  ).copyWith(
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                if (trend.summary.isNotEmpty) ...[
                  6.height,
                  Text(
                    trend.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TS.bodySmall(
                      color: CC.textSecondary,
                    ).copyWith(fontSize: 12.5, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          12.height,

          // ── 3. Metrics HUD Strip ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: CC.isDark ? CC.searchBackground : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CC.stroke.withValues(alpha: CC.isDark ? 0.3 : 0.45),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // 1. Score
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Trend Score",
                          style: TS.caption(
                            color: CC.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                        2.height,
                        Row(
                          children: [
                            Icon(Icons.bolt_rounded, size: 14, color: CC.primary),
                            3.width,
                            Text(
                              trend.score.toStringAsFixed(1),
                              style: TS.sectionTitle(
                                color: CC.primary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    height: 22,
                    width: 1,
                    color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.5),
                  ),
                  12.width,
                  // 2. Growth
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Growth",
                          style: TS.caption(
                            color: CC.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                        2.height,
                        Row(
                          children: [
                            Icon(
                              trend.growthScore >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              size: 14,
                              color: trend.growthScore >= 0 ? const Color(0xFF10B981) : CC.error,
                            ),
                            3.width,
                            Text(
                              "${trend.growthScore > 0 ? '+' : ''}${trend.growthScore.toStringAsFixed(1)}%",
                              style: TS.sectionTitle(
                                color: trend.growthScore >= 0 ? const Color(0xFF10B981) : CC.error,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    height: 22,
                    width: 1,
                    color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.5),
                  ),
                  12.width,
                  // 3. Velocity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Velocity",
                          style: TS.caption(
                            color: CC.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                        2.height,
                        Row(
                          children: [
                            Icon(Icons.speed_rounded, size: 14, color: CC.textSecondary),
                            3.width,
                            Text(
                              trend.velocityScore.toStringAsFixed(1),
                              style: TS.sectionTitle(
                                color: CC.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          12.height,

          // ── 4. Action Buttons Footer ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () => Get.find<MainContainerController>()
                          .changeTab(AppNavigationService.tabStudio),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CC.primary,
                        foregroundColor: CC.whiteText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(
                        "Create in Studio",
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
              color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.5),
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

  // ── Centered Empty State (Matches UI Spec) ─────────────────────────────────
  Widget _buildEmptyTrendsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Search Icon Bubble ──
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: CC.isDark
                    ? CC.searchBackground
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.search_rounded,
                  size: 38,
                  color: CC.textPrimary,
                ),
              ),
            ),
            20.height,

            // ── Title ──
            Text(
              "No trends found",
              style: TS.sectionTitle(
                color: CC.textPrimary,
                fontSize: 18,
              ).copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            8.height,

            // ── Description ──
            Text(
              "Try selecting a different platform or category\nto explore trending topics.",
              style: TS.bodySmall(
                color: CC.textSecondary,
              ).copyWith(fontSize: 13.5, height: 1.45),
              textAlign: TextAlign.center,
            ),
            30.height,
          ],
        ),
      ),
    );
  }
}
