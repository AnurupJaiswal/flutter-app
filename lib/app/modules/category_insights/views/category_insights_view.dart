import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/category_insights_model.dart';
import 'package:lala_ai/app/modules/category_insights/controllers/category_insights_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

import 'package:lala_ai/utils/theme/theme_service.dart';

class CategoryInsightsView extends StatelessWidget {
  final bool isEmbedded;
  const CategoryInsightsView({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryInsightsController());

    return GetBuilder<ThemeService>(
      builder: (_) {
        final body = SafeArea(
      child: Obx(() {
        if (controller.userCategories.isEmpty) {
          return _buildEmptyState(context, controller);
        }

        final insights = controller.currentInsights;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Category Selector Header ─────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "YOUR CATEGORIES",
                      style: TS.caption(
                        color: CC.textSecondary,
                        fontWeight: FontWeight.w700,
                      ).copyWith(letterSpacing: 1.1),
                    ),
                    GestureDetector(
                      onTap: () => controller.manageCategories(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 2),
                        child: Row(
                          children: [
                            Icon(Icons.edit_note_rounded,
                                size: 16, color: CC.primary),
                            4.width,
                            Text(
                              "Manage Categories",
                              style: TS.caption(
                                color: CC.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              10.height,

              // Full-width edge-to-edge scrollable chips list
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  clipBehavior: Clip.none,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.userCategories.length,
                  separatorBuilder: (_, __) => 8.width,
                  itemBuilder: (context, index) {
                    final category = controller.userCategories[index];
                    final isSelected =
                        controller.selectedCategory.value == category;

                    return InkWell(
                      key: ValueKey(category),
                      onTap: () => controller.selectCategory(category),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? CC.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          category,
                          style: TS
                              .bodySmall(
                                color: isSelected
                                    ? CC.primary
                                    : CC.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              )
                              .copyWith(fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
              24.height,

              // Loading or Content State
              if (controller.isLoading.value)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      CW.skeletonCard(height: 140),
                      16.height,
                      CW.skeletonCard(height: 100),
                      16.height,
                      CW.skeletonCard(height: 100),
                    ],
                  ),
                )
              else if (insights == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildUnavailableState(),
                )
              else ...[
                // ── Selected Category Header & Freshness ─────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        controller.selectedCategory.value,
                        style: TS.displayLarge(
                          color: CC.textPrimary,
                          fontSize: 22,
                        ),
                      ),
                      10.width,
                      Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: CC.textSecondary,
                      ),
                      4.width,
                      Text(
                        insights.updatedTime,
                        style: TS.caption(
                          color: CC.textSecondary,
                        ).copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                16.height,

                // ── Category Overview Section ─────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildCategoryOverview(context, insights),
                ),
                24.height,

                // ── Shared Insights Section ───────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "SHARED INSIGHTS",
                    style: TS.caption(
                      color: CC.textSecondary,
                      fontWeight: FontWeight.w700,
                    ).copyWith(letterSpacing: 1.1),
                  ),
                ),
                12.height,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSharedInsightsList(insights),
                ),
              ],

              // Generous bottom padding to prevent cutoff by bottom nav & floaters
              100.height,
            ],
          ),
        );
      }),
    );
    
        if (isEmbedded) return body;

        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            isNotHomepage: true,
            title: "Category Insights",
          ),
          body: body,
        );
      },
    );
  }

  /// Category Overview: Trending Now & Popular Topics
  Widget _buildCategoryOverview(
      BuildContext context, CategoryInsightsModel insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            "${insights.categoryName.toUpperCase()} OVERVIEW",
            style: TS.caption(
              color: CC.primary,
              fontWeight: FontWeight.w800,
            ).copyWith(letterSpacing: 1.1),
          ),
          14.height,

          // Trending Now
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded,
                  color: Colors.orangeAccent, size: 16),
              6.width,
              Text(
                "Trending now",
                style: TS.bodySmall(
                  color: CC.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          8.height,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: insights.trendingNow.map((item) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: CC.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  item,
                  style: TS.bodySmall(
                    color: CC.textPrimary,
                    fontWeight: FontWeight.w500,
                  ).copyWith(fontSize: 12),
                ),
              );
            }).toList(),
          ),
          16.height,
          Divider(color: CC.stroke.withValues(alpha: 0.6), height: 1),
          16.height,

          // Popular Topics
          Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber, size: 16),
              6.width,
              Text(
                "Popular topics",
                style: TS.bodySmall(
                  color: CC.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          8.height,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: insights.popularTopics.map((topic) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CC.isDark
                      ? CC.whiteText.withValues(alpha: 0.05)
                      : CC.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  topic,
                  style: TS.bodySmall(
                    color: CC.textSecondary,
                    fontWeight: FontWeight.w500,
                  ).copyWith(fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ],
      );
  }

  /// Shared Insights Cards List
  Widget _buildSharedInsightsList(CategoryInsightsModel insights) {
    return Column(
      children: insights.sharedInsights.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final isLast = idx == insights.sharedInsights.length - 1;

        return Container(
          margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
          padding: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isLast ? Colors.transparent : CC.stroke.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CC.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: CC.textPrimary, size: 20),
              ),
              14.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: CC.tealSubtle,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.tag.toUpperCase(),
                        style: TS
                            .caption(
                              color: CC.primary,
                              fontWeight: FontWeight.w700,
                            )
                            .copyWith(fontSize: 9, letterSpacing: 0.8),
                      ),
                    ),
                    6.height,
                    Text(
                      item.title,
                      style: TS.bodySmall(
                        color: CC.textPrimary,
                        fontWeight: FontWeight.w700,
                      ).copyWith(fontSize: 14),
                    ),
                    4.height,
                    Text(
                      item.description,
                      style: TS.bodySmall(
                        color: CC.textSecondary,
                      ).copyWith(fontSize: 12, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// State when insights for selected category are preparing
  Widget _buildUnavailableState() {
    return CW.commonCard(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            size: 44,
            color: CC.textSecondary.withValues(alpha: 0.6),
          ),
          12.height,
          Text(
            "Insights aren't available yet",
            style: TS.sectionTitle(color: CC.textPrimary, fontSize: 16),
          ),
          6.height,
          Text(
            "We're preparing insights for this category.\nCheck back soon.",
            textAlign: TextAlign.center,
            style: TS.bodySmall(color: CC.textSecondary).copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  /// Empty state when user has no selected categories
  Widget _buildEmptyState(
      BuildContext context, CategoryInsightsController controller) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CC.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category_outlined,
                size: 48,
                color: CC.primary,
              ),
            ),
            20.height,
            Text(
              "Choose your categories",
              style: TS.displayLarge(color: CC.textPrimary, fontSize: 20),
            ),
            10.height,
            Text(
              "Select the categories that match your content to see relevant insights here.",
              textAlign: TextAlign.center,
              style: TS
                  .bodySmall(color: CC.textSecondary)
                  .copyWith(fontSize: 14, height: 1.4),
            ),
            24.height,
            ElevatedButton.icon(
              onPressed: () => controller.manageCategories(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: CC.primary,
                foregroundColor: CC.whiteText,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                "Choose Categories",
                style: TS.bodySmall(
                    color: CC.whiteText, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
