import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/profile/views/profile_view.dart';
import 'package:lala_ai/app/modules/category_insights/views/category_insights_view.dart';
import 'package:lala_ai/app/modules/competitor/views/competitor_view.dart';
import 'package:lala_ai/app/modules/discover/controllers/discover_controller.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<DiscoverController>()) {
      _currentTab = Get.find<DiscoverController>().activeTab.value.clamp(0, 1);
    }
  }

  void _onTabChanged(int index) {
    if (_currentTab == index) return;
    setState(() => _currentTab = index);
    if (Get.isRegistered<DiscoverController>()) {
      Get.find<DiscoverController>().activeTab.value = index;
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
            title: "Discover",
            actions: [
              IconButton(
                icon: Icon(Icons.person_outline_rounded, color: CC.textPrimary, size: 22),
                splashRadius: 20,
                onPressed: () => Get.to(() => const ProfileView()),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ── Native Mobile Segmented Control ─────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: CC.isDark ? CC.searchBackground : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CC.stroke.withValues(alpha: CC.isDark ? 0.3 : 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildSegmentButton("CREATORS", 0)),
                        Expanded(child: _buildSegmentButton("CATEGORIES", 1)),
                      ],
                    ),
                  ),
                ),

                // ── Preserved Screen View via IndexedStack ───────────────────
                Expanded(
                  child: IndexedStack(
                    index: _currentTab,
                    children: const [
                      CompetitorView(isEmbedded: true),
                      CategoryInsightsView(isEmbedded: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSegmentButton(String title, int index) {
    final bool isSelected = _currentTab == index;

    return GestureDetector(
      onTap: () => _onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? (CC.isDark ? CC.primary : CC.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: CC.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TS.caption(
            color: isSelected ? CC.whiteText : CC.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ).copyWith(fontSize: 12.5, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
