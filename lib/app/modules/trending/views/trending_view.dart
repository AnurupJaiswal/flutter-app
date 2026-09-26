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
              onRefresh: () => controller.loadTrends(isRefresh: true),
              color: CC.primary,
              backgroundColor: CC.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search & Filters Bar
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

                    // Last updated & Refresh header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text("Last updated ${controller.lastUpdated.value}",
                            style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 11))),
                        TextButton.icon(
                          onPressed: () => controller.loadTrends(isRefresh: true),
                          icon: Icon(Icons.refresh_rounded, size: 14, color: CC.primary),
                          label: Text("Refresh",
                              style: TS.caption(color: CC.primary, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    10.height,

                    // Trend Cards List
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
                                  "Try searching for another keyword or hashtag",
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
                              key: ValueKey('trend_${list[i].id}_$i'),
                              context: context,
                              rank: i + 1,
                              trend: list[i],
                            ),
                            if (i < list.length - 1) 12.height,
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
                : CC.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Badges Row: Rank + Niche + Platform
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Rank Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isTop3
                          ? CC.primary.withValues(alpha: 0.12)
                          : CC.stroke.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (rank == 1) ...[
                          Icon(Icons.workspace_premium_rounded, size: 14, color: CC.primary),
                          4.width,
                        ],
                        Text(
                          "#$rank",
                          style: TS.caption(
                            color: isTop3 ? CC.primary : CC.textSecondary,
                            fontWeight: FontWeight.w800,
                          ).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (trend.category.isNotEmpty) ...[
                    8.width,
                    // Niche Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: CC.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.category_rounded, size: 12, color: CC.primary),
                          4.width,
                          Text(
                            trend.category,
                            style: TS.caption(
                              color: CC.primary,
                              fontWeight: FontWeight.w700,
                            ).copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (trend.source.isNotEmpty) ...[
                    8.width,
                    // Platform Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: CC.isDark
                            ? CC.whiteText.withValues(alpha: 0.06)
                            : CC.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trend.source.toLowerCase().contains('youtube')
                                ? Icons.play_circle_fill_rounded
                                : Icons.public_rounded,
                            size: 12,
                            color: CC.textSecondary,
                          ),
                          4.width,
                          Text(
                            trend.source,
                            style: TS.caption(
                              color: CC.textSecondary,
                              fontWeight: FontWeight.w600,
                            ).copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          12.height,

          // Title & Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trend.title,
                  style: TS.sectionTitle(
                    color: CC.textPrimary,
                    fontSize: 16,
                  ).copyWith(height: 1.25),
                ),
                if (trend.summary.isNotEmpty) ...[
                  8.height,
                  Text(
                    trend.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TS.bodySmall(
                      color: CC.textSecondary,
                    ).copyWith(fontSize: 13, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          14.height,

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: CC.stroke.withValues(alpha: 0.5),
          ),

          // Action Buttons Bar
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
                        ),
                      ),
                    ),
                  ),
                ),
                8.width,
                _actionSquareBtn(
                  icon: Icons.copy_rounded,
                  tooltip: "Copy Details",
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: "${trend.title}\n${trend.summary}"));
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
