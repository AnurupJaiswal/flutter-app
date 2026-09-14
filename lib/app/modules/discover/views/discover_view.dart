import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/category_insights/views/category_insights_view.dart';
import 'package:lala_ai/app/modules/competitor/views/competitor_view.dart';
import 'package:lala_ai/app/modules/discover/controllers/discover_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class DiscoverView extends GetView<DiscoverController> {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CC.background,
      appBar: CW.commonAppbar(
        isNotHomepage: false,
        wantBackIcon: false,
        title: "Discover",
      ),
      body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Obx(() => Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: CC.isDark ? const Color(0xFF101010) : CC.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CC.isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _modeTab("CREATORS", 0)),
                      Expanded(child: _modeTab("CATEGORIES", 1)),
                    ],
                  ),
                )),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.activeTab.value == 0) {
                    return const _CreatorTab();
                  } else {
                    return const _NicheTab();
                  }
                }),
              ),
            ],
          ),
        ),
      );
  }

  Widget _modeTab(String title, int index) {
    final isSelected = controller.activeTab.value == index;
    return GestureDetector(
      onTap: () => controller.activeTab.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? CC.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TS.caption(
            color: isSelected ? Colors.white : CC.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CreatorTab extends StatelessWidget {
  const _CreatorTab();

  @override
  Widget build(BuildContext context) {
    return const CompetitorView(isEmbedded: true);
  }
}

class _NicheTab extends StatelessWidget {
  const _NicheTab();

  @override
  Widget build(BuildContext context) {
    return const CategoryInsightsView(isEmbedded: true);
  }
}
