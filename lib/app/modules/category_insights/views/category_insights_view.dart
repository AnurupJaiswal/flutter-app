import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/category_insights/controllers/category_insights_controller.dart';
import 'package:lala_ai/core/widgets/skeleton/app_skeleton.dart';
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
          child: RefreshIndicator(
            onRefresh: () => controller.fetchCategories(isRefresh: true),
            color: CC.primary,
            backgroundColor: CC.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title
                  Text(
                    "CHOOSE YOUR NICHES",
                    style: TS.caption(
                      color: CC.textSecondary,
                      fontWeight: FontWeight.w700,
                    ).copyWith(letterSpacing: 1.1, fontSize: 11.5),
                  ),
                  12.height,

                  // Categories List / Loader / Empty State
                  Obx(() {
                    if (controller.isLoading.value && controller.allAvailableCategories.isEmpty) {
                      return const CategoryInsightsSkeleton();
                    }

                    final list = controller.allAvailableCategories;
                    if (list.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.category_outlined, size: 44, color: CC.grey),
                              12.height,
                              Text(
                                "No categories found",
                                style: TS.sectionTitle(color: CC.textPrimary, fontSize: 15),
                              ),
                              4.height,
                              Text(
                                "Pull down to refresh",
                                style: TS.bodySmall(color: CC.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => 10.height,
                      itemBuilder: (context, index) {
                        final cat = list[index];
                        final icon = controller.getCategoryIcon(cat.name);

                        return Obx(() {
                          final isSelected = controller.isCategorySelected(cat);

                          return InkWell(
                            onTap: () => controller.toggleCategory(cat),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                              decoration: BoxDecoration(
                                color: CC.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Category Icon Avatar
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: CC.isDark
                                          ? CC.whiteText.withValues(alpha: 0.06)
                                          : CC.black.withValues(alpha: 0.04),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        icon,
                                        size: 21,
                                        color: CC.textPrimary,
                                      ),
                                    ),
                                  ),
                                  14.width,

                                  // Category Name & Description
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          cat.name,
                                          style: TS.sectionTitle(
                                            color: CC.textPrimary,
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (cat.description != null && cat.description!.trim().isNotEmpty) ...[
                                          3.height,
                                          Text(
                                            cat.description!.trim(),
                                            style: TS.caption(
                                              color: CC.textSecondary,
                                              fontSize: 11.5,
                                            ).copyWith(height: 1.3),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  12.width,

                                  // Modern Animated Toggle Switch
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeInOut,
                                    width: 46,
                                    height: 27,
                                    padding: const EdgeInsets.all(2.5),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? CC.primary
                                          : (CC.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: AnimatedAlign(
                                      duration: const Duration(milliseconds: 220),
                                      curve: Curves.easeInOut,
                                      alignment: isSelected ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: CC.whiteText,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.18),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );

        if (isEmbedded) return body;

        return Scaffold(
          backgroundColor: CC.background,
          appBar: CW.commonAppbar(
            isNotHomepage: true,
            title: "Categories",
          ),
          body: body,
        );
      },
    );
  }
}
